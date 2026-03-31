import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';

import '../providers/location_provider.dart';
import '../services/location_service.dart';
import '../utils/constants.dart';
import '../widgets/custom_button.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final LocationService _locationService = LocationService();
  GoogleMapController? _mapController;
  List<NearbyPlace> _nearbyPlaces = [];
  String _activeServiceFilter = 'all';
  bool _isLoadingPlaces = false;
  bool _hasSearchedNearby = false;
  String? _placesError;
  BitmapDescriptor? _fuelMarkerIcon;
  BitmapDescriptor? _garageMarkerIcon;
  BitmapDescriptor? _currentMarkerIcon;
  BitmapDescriptor? _nearestFuelMarkerIcon;
  BitmapDescriptor? _nearestGarageMarkerIcon;

  @override
  void initState() {
    super.initState();
    _prepareMarkerIcons();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await context.read<LocationProvider>().getCurrentLocation();
    });
  }

  Future<void> _prepareMarkerIcons() async {
    final icons = await Future.wait([
      _createMarkerIcon(
        icon: Icons.local_gas_station,
        backgroundColor: const Color(0xFFFF9800),
      ),
      _createMarkerIcon(
        icon: Icons.car_repair,
        backgroundColor: const Color(0xFF43A047),
      ),
      _createMarkerIcon(
        icon: Icons.my_location,
        backgroundColor: const Color(0xFF1E88E5),
      ),
      _createMarkerIcon(
        icon: Icons.local_gas_station,
        backgroundColor: const Color(0xFFE53935),
      ),
      _createMarkerIcon(
        icon: Icons.car_repair,
        backgroundColor: const Color(0xFFD81B60),
      ),
    ]);

    if (!mounted) return;
    setState(() {
      _fuelMarkerIcon = icons[0];
      _garageMarkerIcon = icons[1];
      _currentMarkerIcon = icons[2];
      _nearestFuelMarkerIcon = icons[3];
      _nearestGarageMarkerIcon = icons[4];
    });
  }

  Future<BitmapDescriptor> _createMarkerIcon({
    required IconData icon,
    required Color backgroundColor,
  }) async {
    const size = 72.0;
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);

    final shadowPaint = Paint()..color = Colors.black26;
    canvas.drawCircle(const Offset(size / 2, size / 2 + 2), 21, shadowPaint);

    final markerPaint = Paint()..color = backgroundColor;
    canvas.drawCircle(const Offset(size / 2, size / 2), 20, markerPaint);

    final borderPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;
    canvas.drawCircle(const Offset(size / 2, size / 2), 20, borderPaint);

    final textPainter = TextPainter(textDirection: TextDirection.ltr);
    textPainter.text = TextSpan(
      text: String.fromCharCode(icon.codePoint),
      style: TextStyle(
        fontSize: 24,
        color: Colors.white,
        fontFamily: icon.fontFamily,
        package: icon.fontPackage,
      ),
    );
    textPainter.layout();
    textPainter.paint(
      canvas,
      Offset((size - textPainter.width) / 2, (size - textPainter.height) / 2),
    );

    final image =
        await recorder.endRecording().toImage(size.toInt(), size.toInt());
    final byteData = await image.toByteData(format: ui.ImageByteFormat.png);

    if (byteData == null) {
      return BitmapDescriptor.defaultMarker;
    }

    return BitmapDescriptor.fromBytes(byteData.buffer.asUint8List());
  }

  Future<void> _loadNearbyPlaces() async {
    final position = context.read<LocationProvider>().currentPosition;
    if (position == null) return;

    setState(() {
      _hasSearchedNearby = true;
      _isLoadingPlaces = true;
      _placesError = null;
    });

    try {
      final places = await _locationService.fetchNearbyFuelAndGarages(
        position.latitude,
        position.longitude,
      );
      if (!mounted) return;
      setState(() {
        _nearbyPlaces = places;
        _activeServiceFilter = 'all';
      });
      if (places.isNotEmpty) {
        _fitMapToPlaces(position.latitude, position.longitude, places);
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _placesError =
          'Unable to load nearby services right now. Please try again.');
    } finally {
      if (mounted) setState(() => _isLoadingPlaces = false);
    }
  }

  List<NearbyPlace> get _visiblePlaces {
    if (_activeServiceFilter == 'fuel') {
      return _nearbyPlaces.where((p) => p.type == 'fuel').toList();
    }
    if (_activeServiceFilter == 'garage') {
      return _nearbyPlaces.where((p) => p.type == 'garage').toList();
    }
    return _nearbyPlaces;
  }

  void _toggleFilter(String nextFilter) {
    final position = context.read<LocationProvider>().currentPosition;
    setState(() {
      _activeServiceFilter =
          _activeServiceFilter == nextFilter ? 'all' : nextFilter;
    });

    if (position != null && _visiblePlaces.isNotEmpty) {
      _fitMapToPlaces(position.latitude, position.longitude, _visiblePlaces);
    }
  }

  void _showPlaceDetails(NearbyPlace place) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      place.type == 'fuel'
                          ? Icons.local_gas_station
                          : Icons.car_repair,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        place.name,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                    'Type: ${place.type == 'fuel' ? 'Fuel Station' : 'Garage'}'),
                Text(
                    'Distance: ${(place.distanceMeters / 1000).toStringAsFixed(2)} km'),
                Text(
                  'Address: ${place.address.trim().isEmpty ? 'Address not available' : place.address}',
                ),
                Text('Place ID: ${place.id}'),
              ],
            ),
          ),
        );
      },
    );
  }

  NearbyPlace? get _nearestFuel {
    final fuel = _nearbyPlaces.where((p) => p.type == 'fuel').toList();
    if (fuel.isEmpty) return null;
    fuel.sort((a, b) => a.distanceMeters.compareTo(b.distanceMeters));
    return fuel.first;
  }

  NearbyPlace? get _nearestGarage {
    final garages = _nearbyPlaces.where((p) => p.type == 'garage').toList();
    if (garages.isEmpty) return null;
    garages.sort((a, b) => a.distanceMeters.compareTo(b.distanceMeters));
    return garages.first;
  }

  void _fitMapToPlaces(
      double userLat, double userLng, List<NearbyPlace> places) {
    if (_mapController == null) return;

    double minLat = userLat;
    double maxLat = userLat;
    double minLng = userLng;
    double maxLng = userLng;

    for (final place in places) {
      if (place.latitude < minLat) minLat = place.latitude;
      if (place.latitude > maxLat) maxLat = place.latitude;
      if (place.longitude < minLng) minLng = place.longitude;
      if (place.longitude > maxLng) maxLng = place.longitude;
    }

    _mapController!.animateCamera(
      CameraUpdate.newLatLngBounds(
        LatLngBounds(
          southwest: LatLng(minLat, minLng),
          northeast: LatLng(maxLat, maxLng),
        ),
        70,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final location = context.watch<LocationProvider>();
    final position = location.currentPosition;
    final visiblePlaces = _visiblePlaces;
    final nearestFuel = _activeServiceFilter == 'garage' ? null : _nearestFuel;
    final nearestGarage =
        _activeServiceFilter == 'fuel' ? null : _nearestGarage;

    return Scaffold(
      appBar: AppBar(title: const Text('DriverAssist Home')),
      body: RefreshIndicator(
        onRefresh: _loadNearbyPlaces,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Current Location',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    if (location.isLoading)
                      const LinearProgressIndicator()
                    else
                      Text(location.currentAddress),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 320,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: position == null
                    ? const Center(child: Text('Location unavailable'))
                    : GoogleMap(
                        onMapCreated: (controller) =>
                            _mapController = controller,
                        initialCameraPosition: CameraPosition(
                          target: LatLng(position.latitude, position.longitude),
                          zoom: 14,
                        ),
                        myLocationEnabled: true,
                        myLocationButtonEnabled: true,
                        zoomControlsEnabled: false,
                        circles: {
                          Circle(
                            circleId: const CircleId('current-location-radius'),
                            center:
                                LatLng(position.latitude, position.longitude),
                            radius: 120,
                            fillColor: const Color(0x331E88E5),
                            strokeColor: const Color(0xAA1E88E5),
                            strokeWidth: 2,
                          ),
                        },
                        markers: {
                          Marker(
                            markerId: const MarkerId('current-location'),
                            position:
                                LatLng(position.latitude, position.longitude),
                            icon: _currentMarkerIcon ??
                                BitmapDescriptor.defaultMarkerWithHue(
                                  BitmapDescriptor.hueAzure,
                                ),
                            infoWindow: InfoWindow(
                              title: 'Your current location',
                              snippet: location.currentAddress,
                            ),
                          ),
                          ...(_hasSearchedNearby
                                  ? visiblePlaces
                                  : <NearbyPlace>[])
                              .map((place) {
                            final isNearestFuel = place.id == nearestFuel?.id;
                            final isNearestGarage =
                                place.id == nearestGarage?.id;

                            return Marker(
                              markerId: MarkerId(place.id),
                              position: LatLng(place.latitude, place.longitude),
                              icon: isNearestFuel
                                  ? (_nearestFuelMarkerIcon ??
                                      BitmapDescriptor.defaultMarkerWithHue(
                                        BitmapDescriptor.hueRed,
                                      ))
                                  : isNearestGarage
                                      ? (_nearestGarageMarkerIcon ??
                                          BitmapDescriptor.defaultMarkerWithHue(
                                            BitmapDescriptor.hueRose,
                                          ))
                                      : place.type == 'fuel'
                                          ? (_fuelMarkerIcon ??
                                              BitmapDescriptor
                                                  .defaultMarkerWithHue(
                                                BitmapDescriptor.hueOrange,
                                              ))
                                          : (_garageMarkerIcon ??
                                              BitmapDescriptor
                                                  .defaultMarkerWithHue(
                                                BitmapDescriptor.hueGreen,
                                              )),
                              infoWindow: InfoWindow(
                                title: place.name,
                                snippet:
                                    '${place.type == 'fuel' ? 'Fuel Station' : 'Garage'} • ${(place.distanceMeters / 1000).toStringAsFixed(2)} km',
                              ),
                              onTap: () => _showPlaceDetails(place),
                            );
                          }),
                        },
                      ),
              ),
            ),
            const SizedBox(height: 12),
            if (_isLoadingPlaces) const LinearProgressIndicator(),
            if (_placesError != null)
              Text(_placesError!,
                  style: const TextStyle(color: Color(0xFFE53935))),
            if (!_hasSearchedNearby)
              const Text(
                'Tap "Find Nearby Services" to show garages and fuel stations around your current location.',
              ),
            if (_hasSearchedNearby && _nearbyPlaces.isNotEmpty) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: FilledButton.icon(
                      onPressed: () => _toggleFilter('fuel'),
                      icon: const Icon(Icons.local_gas_station, size: 16),
                      label: const Text('Fuel'),
                      style: FilledButton.styleFrom(
                        backgroundColor: _activeServiceFilter == 'fuel'
                            ? const Color(0xFFFF9800)
                            : null,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: FilledButton.icon(
                      onPressed: () => _toggleFilter('garage'),
                      icon: const Icon(Icons.car_repair, size: 16),
                      label: const Text('Garages'),
                      style: FilledButton.styleFrom(
                        backgroundColor: _activeServiceFilter == 'garage'
                            ? const Color(0xFF43A047)
                            : null,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Align(
                alignment: Alignment.centerLeft,
                child: TextButton.icon(
                  onPressed: () {
                    final currentPosition = location.currentPosition;
                    setState(() => _activeServiceFilter = 'all');
                    if (currentPosition != null && _nearbyPlaces.isNotEmpty) {
                      _fitMapToPlaces(
                        currentPosition.latitude,
                        currentPosition.longitude,
                        _nearbyPlaces,
                      );
                    }
                  },
                  icon: const Icon(Icons.layers, size: 16),
                  label: const Text('Show all services'),
                ),
              ),
            ],
            if (nearestFuel != null || nearestGarage != null)
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  if (nearestFuel != null)
                    Chip(
                      avatar: const Icon(Icons.local_gas_station, size: 16),
                      label: Text(
                        'Nearest fuel: ${(nearestFuel.distanceMeters / 1000).toStringAsFixed(2)} km',
                      ),
                    ),
                  if (nearestGarage != null)
                    Chip(
                      avatar: const Icon(Icons.car_repair, size: 16),
                      label: Text(
                        'Nearest garage: ${(nearestGarage.distanceMeters / 1000).toStringAsFixed(2)} km',
                      ),
                    ),
                ],
              ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: CustomButton(
                label: 'Find Nearby Services',
                onPressed: _isLoadingPlaces ? null : _loadNearbyPlaces,
                icon: Icons.store_mall_directory,
              ),
            ),
            if (_hasSearchedNearby && visiblePlaces.isNotEmpty) ...[
              const SizedBox(height: 12),
              Text(
                'Nearby service details',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              ...visiblePlaces.map(
                (place) => Card(
                  child: ListTile(
                    leading: Icon(
                      place.type == 'fuel'
                          ? Icons.local_gas_station
                          : Icons.car_repair,
                    ),
                    title: Text(place.name),
                    subtitle: Text(
                      '${place.type == 'fuel' ? 'Fuel Station' : 'Garage'} • ${(place.distanceMeters / 1000).toStringAsFixed(2)} km\n${place.address.trim().isEmpty ? 'Address not available' : place.address}',
                    ),
                    isThreeLine: true,
                    onTap: () => _showPlaceDetails(place),
                  ),
                ),
              ),
            ],
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: CustomButton(
                label: 'Emergency SOS',
                type: ButtonType.secondary,
                onPressed: () =>
                    Navigator.pushNamed(context, AppRoutes.emergency),
                icon: Icons.warning_amber_rounded,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
