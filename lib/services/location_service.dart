import 'dart:convert';

import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:http/http.dart' as http;

class NearbyPlace {
  final String id;
  final String name;
  final String type;
  final double latitude;
  final double longitude;
  final double distanceMeters;

  const NearbyPlace({
    required this.id,
    required this.name,
    required this.type,
    required this.latitude,
    required this.longitude,
    required this.distanceMeters,
  });
}

class LocationService {
  static const List<String> _overpassEndpoints = [
    'https://overpass-api.de/api/interpreter',
    'https://overpass.kumi.systems/api/interpreter',
    'https://lz4.overpass-api.de/api/interpreter',
  ];

  Future<bool> requestPermission() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return false;

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) return false;
    }
    if (permission == LocationPermission.deniedForever) return false;
    return true;
  }

  Future<Position?> getCurrentPosition() async {
    try {
      final hasPermission = await requestPermission();
      if (!hasPermission) return null;
      return await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );
    } catch (e) {
      return null;
    }
  }

  Stream<Position> getPositionStream() {
    const settings = LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 10,
    );
    return Geolocator.getPositionStream(locationSettings: settings);
  }

  Future<String> getAddressFromCoordinates(double lat, double lng) async {
    try {
      final placemarks = await placemarkFromCoordinates(lat, lng);
      if (placemarks.isEmpty) {
        return 'Unknown area';
      }
      final place = placemarks.first;
      final parts = [
        place.name,
        place.street,
        place.subLocality,
        place.locality,
        place.administrativeArea,
        place.country,
      ].where((p) => p != null && p.isNotEmpty).toList();

      if (parts.isEmpty) {
        return 'Unknown area';
      }

      return parts.join(', ');
    } catch (e) {
      return 'Unknown area';
    }
  }

  Future<List<Location>> searchAddress(String query) async {
    try {
      return await locationFromAddress(query);
    } catch (e) {
      return [];
    }
  }

  Future<double> distanceBetween(
    double lat1,
    double lng1,
    double lat2,
    double lng2,
  ) async {
    return Geolocator.distanceBetween(lat1, lng1, lat2, lng2);
  }

  Future<List<NearbyPlace>> fetchNearbyFuelAndGarages(
    double lat,
    double lng, {
    int radiusMeters = 3000,
    int maxResults = 20,
  }) async {
    final query = '''
[out:json][timeout:12];
(
  node["amenity"="fuel"](around:$radiusMeters,$lat,$lng);
  node["amenity"="car_repair"](around:$radiusMeters,$lat,$lng);
  node["shop"="car_repair"](around:$radiusMeters,$lat,$lng);
);
out body;
''';

    final decoded = await _fetchNearbyRaw(lat, lng, query);
    final elements = (decoded['elements'] as List<dynamic>? ?? const [])
        .whereType<Map<String, dynamic>>();

    final places = <NearbyPlace>[];
    for (final el in elements) {
      final tags = (el['tags'] as Map?)?.cast<String, dynamic>() ?? {};
      final latVal = (el['lat'] ?? (el['center'] as Map?)?['lat']) as num?;
      final lngVal = (el['lon'] ?? (el['center'] as Map?)?['lon']) as num?;
      if (latVal == null || lngVal == null) continue;

      final amenity = (tags['amenity'] ?? '').toString();
      final shop = (tags['shop'] ?? '').toString();
      final type = amenity == 'fuel' ? 'fuel' : 'garage';
      if (type == 'garage' &&
          !(shop == 'car_repair' || amenity == 'car_repair')) {
        continue;
      }

      final pLat = latVal.toDouble();
      final pLng = lngVal.toDouble();
      final dist = Geolocator.distanceBetween(lat, lng, pLat, pLng);

      places.add(
        NearbyPlace(
          id: '${el['type']}-${el['id']}',
          name: (tags['name'] ?? (type == 'fuel' ? 'Fuel Station' : 'Garage'))
              .toString(),
          type: type,
          latitude: pLat,
          longitude: pLng,
          distanceMeters: dist,
        ),
      );
    }

    places.sort((a, b) => a.distanceMeters.compareTo(b.distanceMeters));
    if (places.length > maxResults) {
      return places.take(maxResults).toList();
    }
    return places;
  }

  Future<Map<String, dynamic>> _fetchNearbyRaw(
    double lat,
    double lng,
    String overpassQuery,
  ) async {
    String? lastError;

    for (final endpoint in _overpassEndpoints) {
      try {
        final response = await http.post(
          Uri.parse(endpoint),
          headers: {'Content-Type': 'application/x-www-form-urlencoded'},
          body: {'data': overpassQuery},
        ).timeout(const Duration(seconds: 20));

        if (response.statusCode == 200) {
          return jsonDecode(response.body) as Map<String, dynamic>;
        }
        lastError = 'Endpoint returned ${response.statusCode}';
      } catch (e) {
        lastError = e.toString();
      }
    }

    final fallback = await _fetchNearbyFromNominatim(lat, lng);
    if (fallback != null) return fallback;

    throw Exception(
      'Nearby services request failed. Check internet and try again. ${lastError ?? ''}',
    );
  }

  Future<Map<String, dynamic>?> _fetchNearbyFromNominatim(
    double lat,
    double lng,
  ) async {
    try {
      final d = 0.03;
      final left = (lng - d).toStringAsFixed(6);
      final right = (lng + d).toStringAsFixed(6);
      final top = (lat + d).toStringAsFixed(6);
      final bottom = (lat - d).toStringAsFixed(6);
      final box = '$left,$top,$right,$bottom';

      Future<List<dynamic>> search(String q) async {
        final uri = Uri.https('nominatim.openstreetmap.org', '/search', {
          'q': q,
          'format': 'jsonv2',
          'limit': '10',
          'bounded': '1',
          'viewbox': box,
        });
        final resp = await http.get(uri).timeout(const Duration(seconds: 15));
        if (resp.statusCode != 200) return [];
        return (jsonDecode(resp.body) as List<dynamic>?) ?? [];
      }

      final fuels = await search('fuel station');
      final garages = await search('garage car repair');

      final elements = <Map<String, dynamic>>[];
      for (final item in fuels) {
        if (item is! Map<String, dynamic>) continue;
        elements.add({
          'type': 'node',
          'id': item['place_id'] ?? item['osm_id'],
          'lat': double.tryParse(item['lat'].toString()),
          'lon': double.tryParse(item['lon'].toString()),
          'tags': {
            'amenity': 'fuel',
            'name': item['name'] ?? item['display_name'] ?? 'Fuel Station',
          },
        });
      }
      for (final item in garages) {
        if (item is! Map<String, dynamic>) continue;
        elements.add({
          'type': 'node',
          'id': item['place_id'] ?? item['osm_id'],
          'lat': double.tryParse(item['lat'].toString()),
          'lon': double.tryParse(item['lon'].toString()),
          'tags': {
            'shop': 'car_repair',
            'name': item['name'] ?? item['display_name'] ?? 'Garage',
          },
        });
      }

      return {'elements': elements};
    } catch (_) {
      return null;
    }
  }
}
