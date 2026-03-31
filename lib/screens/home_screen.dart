import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
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
  List<NearbyPlace> _nearbyPlaces = [];
  bool _isLoadingPlaces = false;
  String? _placesError;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await context.read<LocationProvider>().getCurrentLocation();
      if (!mounted) return;
      await _loadNearbyPlaces();
    });
  }

  Future<void> _loadNearbyPlaces() async {
    final position = context.read<LocationProvider>().currentPosition;
    if (position == null) return;

    setState(() {
      _isLoadingPlaces = true;
      _placesError = null;
    });

    try {
      final places = await _locationService.fetchNearbyFuelAndGarages(
        position.latitude,
        position.longitude,
      );
      if (!mounted) return;
      setState(() => _nearbyPlaces = places);
    } catch (e) {
      if (!mounted) return;
      setState(() => _placesError = 'Unable to load nearby services: $e');
    } finally {
      if (mounted) setState(() => _isLoadingPlaces = false);
    }
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

  @override
  Widget build(BuildContext context) {
    final location = context.watch<LocationProvider>();
    final position = location.currentPosition;
    final nearestFuel = _nearestFuel;
    final nearestGarage = _nearestGarage;

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
                    : FlutterMap(
                        options: MapOptions(
                          initialCenter:
                              LatLng(position.latitude, position.longitude),
                          initialZoom: 14,
                        ),
                        children: [
                          TileLayer(
                            urlTemplate:
                                'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                            userAgentPackageName: 'com.driverassist.app',
                          ),
                          MarkerLayer(
                            markers: [
                              Marker(
                                point: LatLng(
                                    position.latitude, position.longitude),
                                width: 44,
                                height: 44,
                                child: const Icon(
                                  Icons.my_location,
                                  color: Color(0xFF1E88E5),
                                  size: 34,
                                ),
                              ),
                              ..._nearbyPlaces.map((place) {
                                final isNearest = place.id == nearestFuel?.id ||
                                    place.id == nearestGarage?.id;
                                final color = place.type == 'fuel'
                                    ? const Color(0xFFFFA726)
                                    : const Color(0xFF43A047);

                                return Marker(
                                  point:
                                      LatLng(place.latitude, place.longitude),
                                  width: isNearest ? 48 : 38,
                                  height: isNearest ? 48 : 38,
                                  child: Icon(
                                    place.type == 'fuel'
                                        ? Icons.local_gas_station
                                        : Icons.car_repair,
                                    color: isNearest
                                        ? const Color(0xFFE53935)
                                        : color,
                                    size: isNearest ? 34 : 26,
                                  ),
                                );
                              }),
                            ],
                          ),
                        ],
                      ),
              ),
            ),
            const SizedBox(height: 12),
            if (_isLoadingPlaces) const LinearProgressIndicator(),
            if (_placesError != null)
              Text(_placesError!,
                  style: const TextStyle(color: Color(0xFFE53935))),
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
                onPressed: () =>
                    Navigator.pushNamed(context, AppRoutes.services),
                icon: Icons.store_mall_directory,
              ),
            ),
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
