import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:http/http.dart' as http;

import 'web_places_bridge_stub.dart'
    if (dart.library.js_interop) 'web_places_bridge.dart';

class NearbyPlace {
  final String id;
  final String name;
  final String address;
  final String type;
  final double latitude;
  final double longitude;
  final double distanceMeters;

  const NearbyPlace({
    required this.id,
    required this.name,
    required this.address,
    required this.type,
    required this.latitude,
    required this.longitude,
    required this.distanceMeters,
  });
}

class LocationService {
  static const String _placesNearbyPath = '/maps/api/place/nearbysearch/json';

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
        return await _reverseGeocodeWithGoogle(lat, lng);
      }

      return parts.join(', ');
    } catch (e) {
      return await _reverseGeocodeWithGoogle(lat, lng);
    }
  }

  Future<String> _reverseGeocodeWithGoogle(double lat, double lng) async {
    final apiKey = dotenv.env['GOOGLEMAP_API_KEY']?.trim();
    if (apiKey == null || apiKey.isEmpty) {
      return 'Unknown area';
    }

    final uri = Uri.https('maps.googleapis.com', '/maps/api/geocode/json', {
      'latlng': '$lat,$lng',
      'key': apiKey,
    });

    try {
      final response = await http.get(uri).timeout(const Duration(seconds: 20));
      if (response.statusCode != 200) return 'Unknown area';

      final decoded = jsonDecode(response.body) as Map<String, dynamic>;
      final status = (decoded['status'] ?? '').toString();
      if (status != 'OK') return 'Unknown area';

      final results = decoded['results'] as List<dynamic>? ?? const [];
      if (results.isEmpty) return 'Unknown area';

      final first = results.first as Map<String, dynamic>;
      final formatted = (first['formatted_address'] ?? '').toString().trim();
      return formatted.isEmpty ? 'Unknown area' : formatted;
    } catch (_) {
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
    final apiKey = dotenv.env['GOOGLEMAP_API_KEY']?.trim();
    if (apiKey == null || apiKey.isEmpty) {
      throw Exception('GOOGLEMAP_API_KEY is missing in .env');
    }

    final placeById = <String, NearbyPlace>{};

    final fuel = kIsWeb
        ? await _fetchNearbyByTypeV1(
            lat: lat,
            lng: lng,
            radiusMeters: radiusMeters,
            includedType: 'gas_station',
            mappedType: 'fuel',
          )
        : await _fetchNearbyByType(
            lat: lat,
            lng: lng,
            radiusMeters: radiusMeters,
            apiKey: apiKey,
            type: 'gas_station',
            mappedType: 'fuel',
          );
    for (final place in fuel) {
      placeById[place.id] = place;
    }

    final garages = kIsWeb
        ? await _fetchNearbyByTypeV1(
            lat: lat,
            lng: lng,
            radiusMeters: radiusMeters,
            includedType: 'car_repair',
            mappedType: 'garage',
          )
        : await _fetchNearbyByType(
            lat: lat,
            lng: lng,
            radiusMeters: radiusMeters,
            apiKey: apiKey,
            type: 'car_repair',
            mappedType: 'garage',
          );
    for (final place in garages) {
      placeById[place.id] = place;
    }

    final places = placeById.values.toList()
      ..sort((a, b) => a.distanceMeters.compareTo(b.distanceMeters));

    if (places.length > maxResults) {
      return places.take(maxResults).toList();
    }
    return places;
  }

  Future<List<NearbyPlace>> _fetchNearbyByType({
    required double lat,
    required double lng,
    required int radiusMeters,
    required String apiKey,
    required String type,
    required String mappedType,
  }) async {
    final uri = Uri.https('maps.googleapis.com', _placesNearbyPath, {
      'location': '$lat,$lng',
      'radius': '$radiusMeters',
      'type': type,
      'key': apiKey,
    });

    final response = await http.get(uri).timeout(const Duration(seconds: 20));
    if (response.statusCode != 200) {
      throw Exception(
        'Google Places request failed (${response.statusCode}) for $type',
      );
    }

    final decoded = jsonDecode(response.body) as Map<String, dynamic>;
    final status = (decoded['status'] ?? '').toString();
    if (status != 'OK' && status != 'ZERO_RESULTS') {
      final errorMessage = (decoded['error_message'] ?? '').toString();
      throw Exception(
        'Google Places returned $status${errorMessage.isNotEmpty ? ': $errorMessage' : ''}',
      );
    }

    final results = (decoded['results'] as List<dynamic>? ?? const [])
        .whereType<Map<String, dynamic>>();

    final places = <NearbyPlace>[];
    for (final result in results) {
      final geometry = (result['geometry'] as Map?)?.cast<String, dynamic>();
      final location =
          (geometry?['location'] as Map?)?.cast<String, dynamic>() ?? {};

      final latVal = (location['lat'] as num?)?.toDouble();
      final lngVal = (location['lng'] as num?)?.toDouble();
      if (latVal == null || lngVal == null) continue;

      final placeId = (result['place_id'] ?? '').toString();
      if (placeId.isEmpty) continue;

      places.add(
        NearbyPlace(
          id: placeId,
          name: (result['name'] ??
                  (mappedType == 'fuel' ? 'Fuel Station' : 'Garage'))
              .toString(),
          address: (result['vicinity'] ?? result['formatted_address'] ?? '')
              .toString(),
          type: mappedType,
          latitude: latVal,
          longitude: lngVal,
          distanceMeters: Geolocator.distanceBetween(lat, lng, latVal, lngVal),
        ),
      );
    }

    return places;
  }

  Future<List<NearbyPlace>> _fetchNearbyByTypeV1({
    required double lat,
    required double lng,
    required int radiusMeters,
    required String includedType,
    required String mappedType,
  }) async {
    final placesData = await searchNearbyPlacesWeb(
      lat: lat,
      lng: lng,
      radiusMeters: radiusMeters,
      includedType: includedType,
      maxResults: 20,
    );

    final places = <NearbyPlace>[];
    for (final result in placesData) {
      final latVal = (result['latitude'] as num?)?.toDouble();
      final lngVal = (result['longitude'] as num?)?.toDouble();
      if (latVal == null || lngVal == null) continue;

      final placeId = (result['id'] ?? '').toString();
      if (placeId.isEmpty) continue;

      final displayName = (result['name'] ?? '').toString();

      places.add(
        NearbyPlace(
          id: placeId,
          name: displayName.isEmpty
              ? (mappedType == 'fuel' ? 'Fuel Station' : 'Garage')
              : displayName,
          address: (result['address'] ?? result['vicinity'] ?? '').toString(),
          type: mappedType,
          latitude: latVal,
          longitude: lngVal,
          distanceMeters: Geolocator.distanceBetween(lat, lng, latVal, lngVal),
        ),
      );
    }

    return places;
  }
}
