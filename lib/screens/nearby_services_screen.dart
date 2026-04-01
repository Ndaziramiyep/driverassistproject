import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';

import '../providers/location_provider.dart';
import '../services/location_service.dart';

class NearbyServicesScreen extends StatefulWidget {
  const NearbyServicesScreen({super.key});

  @override
  State<NearbyServicesScreen> createState() => _NearbyServicesScreenState();
}

class _NearbyServicesScreenState extends State<NearbyServicesScreen>
    with SingleTickerProviderStateMixin {
  final LocationService _locationService = LocationService();
  GoogleMapController? _mapController;

  List<NearbyPlace> _nearbyPlaces = [];
  String _activeFilter = 'all';
  bool _isLoading = false;
  bool _hasFetched = false;
  String? _error;

  BitmapDescriptor? _fuelIcon;
  BitmapDescriptor? _garageIcon;
  BitmapDescriptor? _currentIcon;
  BitmapDescriptor? _nearestFuelIcon;
  BitmapDescriptor? _nearestGarageIcon;

  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) return;
      final filters = ['all', 'fuel', 'garage'];
      _setFilter(filters[_tabController.index]);
    });
    _prepareIcons();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_hasFetched) _fetchPlaces();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _prepareIcons() async {
    final icons = await Future.wait([
      _makeIcon(Icons.local_gas_station, const Color(0xFFFF9800)),
      _makeIcon(Icons.car_repair, const Color(0xFF43A047)),
      _makeIcon(Icons.my_location, const Color(0xFF1E88E5)),
      _makeIcon(Icons.local_gas_station, const Color(0xFFE53935)),
      _makeIcon(Icons.car_repair, const Color(0xFFD81B60)),
    ]);
    if (!mounted) return;
    setState(() {
      _fuelIcon = icons[0];
      _garageIcon = icons[1];
      _currentIcon = icons[2];
      _nearestFuelIcon = icons[3];
      _nearestGarageIcon = icons[4];
    });
  }

  Future<BitmapDescriptor> _makeIcon(IconData icon, Color bg) async {
    const size = 72.0;
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    canvas.drawCircle(
        const Offset(size / 2, size / 2 + 2), 21, Paint()..color = Colors.black26);
    canvas.drawCircle(
        const Offset(size / 2, size / 2), 20, Paint()..color = bg);
    canvas.drawCircle(
      const Offset(size / 2, size / 2),
      20,
      Paint()
        ..color = Colors.white
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3,
    );
    final tp = TextPainter(textDirection: TextDirection.ltr)
      ..text = TextSpan(
        text: String.fromCharCode(icon.codePoint),
        style: TextStyle(
            fontSize: 24,
            color: Colors.white,
            fontFamily: icon.fontFamily,
            package: icon.fontPackage),
      )
      ..layout();
    tp.paint(canvas,
        Offset((size - tp.width) / 2, (size - tp.height) / 2));
    final img = await recorder.endRecording().toImage(size.toInt(), size.toInt());
    final bd = await img.toByteData(format: ui.ImageByteFormat.png);
    if (bd == null) return BitmapDescriptor.defaultMarker;
    return BitmapDescriptor.bytes(bd.buffer.asUint8List());
  }

  Future<void> _fetchPlaces() async {
    final position = context.read<LocationProvider>().currentPosition;
    if (position == null) {
      setState(() => _error = 'Location unavailable. Please enable GPS.');
      return;
    }
    setState(() {
      _hasFetched = true;
      _isLoading = true;
      _error = null;
    });
    try {
      final places = await _locationService.fetchNearbyFuelAndGarages(
        position.latitude,
        position.longitude,
      );
      if (!mounted) return;
      setState(() => _nearbyPlaces = places);
      if (places.isNotEmpty) {
        _fitMap(position.latitude, position.longitude, places);
      }
    } catch (_) {
      if (!mounted) return;
      setState(
          () => _error = 'Unable to load nearby services. Please try again.');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _setFilter(String filter) {
    final position = context.read<LocationProvider>().currentPosition;
    setState(() => _activeFilter = filter);
    final visible = _visiblePlaces;
    if (position != null && visible.isNotEmpty) {
      _fitMap(position.latitude, position.longitude, visible);
    }
  }

  List<NearbyPlace> get _visiblePlaces {
    if (_activeFilter == 'fuel') {
      return _nearbyPlaces.where((p) => p.type == 'fuel').toList();
    }
    if (_activeFilter == 'garage') {
      return _nearbyPlaces.where((p) => p.type == 'garage').toList();
    }
    return _nearbyPlaces;
  }

  NearbyPlace? get _nearestFuel {
    final fuel = _nearbyPlaces.where((p) => p.type == 'fuel').toList()
      ..sort((a, b) => a.distanceMeters.compareTo(b.distanceMeters));
    return fuel.isEmpty ? null : fuel.first;
  }

  NearbyPlace? get _nearestGarage {
    final garages = _nearbyPlaces.where((p) => p.type == 'garage').toList()
      ..sort((a, b) => a.distanceMeters.compareTo(b.distanceMeters));
    return garages.isEmpty ? null : garages.first;
  }

  void _fitMap(double lat, double lng, List<NearbyPlace> places) {
    if (_mapController == null) return;
    double minLat = lat, maxLat = lat, minLng = lng, maxLng = lng;
    for (final p in places) {
      if (p.latitude < minLat) minLat = p.latitude;
      if (p.latitude > maxLat) maxLat = p.latitude;
      if (p.longitude < minLng) minLng = p.longitude;
      if (p.longitude > maxLng) maxLng = p.longitude;
    }
    _mapController!.animateCamera(
      CameraUpdate.newLatLngBounds(
        LatLngBounds(
          southwest: LatLng(minLat, minLng),
          northeast: LatLng(maxLat, maxLng),
        ),
        80,
      ),
    );
  }

  void _showDetails(NearbyPlace place) {
    final isFuel = place.type == 'fuel';
    final color = isFuel ? const Color(0xFFFF9800) : const Color(0xFF43A047);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      backgroundColor: Theme.of(context).colorScheme.surface,
      builder: (_) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color:
                        isDark ? Colors.grey.shade700 : Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Icon(
                      isFuel ? Icons.local_gas_station : Icons.car_repair,
                      color: color,
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          place.name,
                          style: GoogleFonts.poppins(
                              fontWeight: FontWeight.w700, fontSize: 16),
                        ),
                        Text(
                          isFuel ? 'Fuel Station' : 'Auto Garage',
                          style: GoogleFonts.poppins(
                              fontSize: 12,
                              color: color,
                              fontWeight: FontWeight.w500),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _detailRow(
                Icons.near_me,
                '${(place.distanceMeters / 1000).toStringAsFixed(2)} km away',
                const Color(0xFF1E88E5),
              ),
              const SizedBox(height: 8),
              _detailRow(
                Icons.location_on_outlined,
                place.address.trim().isEmpty
                    ? 'Address not available'
                    : place.address,
                Colors.grey,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _detailRow(IconData icon, String text, Color color) => Row(
        children: [
          Icon(icon, size: 18, color: color),
          const SizedBox(width: 8),
          Expanded(
            child: Text(text, style: GoogleFonts.poppins(fontSize: 13)),
          ),
        ],
      );

  @override
  Widget build(BuildContext context) {
    final location = context.watch<LocationProvider>();
    final position = location.currentPosition;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final visible = _visiblePlaces;
    final nearestFuel =
        _activeFilter == 'garage' ? null : _nearestFuel;
    final nearestGarage =
        _activeFilter == 'fuel' ? null : _nearestGarage;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Nearby Services',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w700),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            tooltip: 'Refresh',
            onPressed: _isLoading ? null : _fetchPlaces,
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelStyle:
              GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 13),
          unselectedLabelStyle:
              GoogleFonts.poppins(fontWeight: FontWeight.w500, fontSize: 13),
          indicatorWeight: 3,
          tabs: const [
            Tab(icon: Icon(Icons.layers_rounded, size: 18), text: 'All'),
            Tab(
                icon: Icon(Icons.local_gas_station, size: 18),
                text: 'Fuel'),
            Tab(icon: Icon(Icons.car_repair, size: 18), text: 'Garages'),
          ],
        ),
      ),
      body: Column(
        children: [
          // ── Mini map ─────────────────────────────────────────────────
          SizedBox(
            height: 220,
            child: position == null
                ? Container(
                    color: isDark
                        ? const Color(0xFF181A20)
                        : const Color(0xFFE8F0FE),
                    child: const Center(child: CircularProgressIndicator()),
                  )
                : GoogleMap(
                    onMapCreated: (c) {
                      _mapController = c;
                      if (visible.isNotEmpty) {
                        _fitMap(
                            position.latitude, position.longitude, visible);
                      }
                    },
                    initialCameraPosition: CameraPosition(
                      target: LatLng(position.latitude, position.longitude),
                      zoom: 14,
                    ),
                    myLocationEnabled: true,
                    myLocationButtonEnabled: false,
                    zoomControlsEnabled: false,
                    mapToolbarEnabled: false,
                    circles: {
                      Circle(
                        circleId: const CircleId('r'),
                        center:
                            LatLng(position.latitude, position.longitude),
                        radius: 120,
                        fillColor: const Color(0x221E88E5),
                        strokeColor: const Color(0x881E88E5),
                        strokeWidth: 2,
                      ),
                    },
                    markers: {
                      Marker(
                        markerId: const MarkerId('me'),
                        position:
                            LatLng(position.latitude, position.longitude),
                        icon: _currentIcon ??
                            BitmapDescriptor.defaultMarkerWithHue(
                                BitmapDescriptor.hueAzure),
                        infoWindow: const InfoWindow(title: 'You are here'),
                      ),
                      ...visible.map((place) {
                        final isNF = place.id == nearestFuel?.id;
                        final isNG = place.id == nearestGarage?.id;
                        return Marker(
                          markerId: MarkerId(place.id),
                          position:
                              LatLng(place.latitude, place.longitude),
                          icon: isNF
                              ? (_nearestFuelIcon ??
                                  BitmapDescriptor.defaultMarkerWithHue(
                                      BitmapDescriptor.hueRed))
                              : isNG
                                  ? (_nearestGarageIcon ??
                                      BitmapDescriptor.defaultMarkerWithHue(
                                          BitmapDescriptor.hueRose))
                                  : place.type == 'fuel'
                                      ? (_fuelIcon ??
                                          BitmapDescriptor.defaultMarkerWithHue(
                                              BitmapDescriptor.hueOrange))
                                      : (_garageIcon ??
                                          BitmapDescriptor.defaultMarkerWithHue(
                                              BitmapDescriptor.hueGreen)),
                          infoWindow: InfoWindow(
                            title: place.name,
                            snippet:
                                '${place.type == 'fuel' ? 'Fuel' : 'Garage'} • ${(place.distanceMeters / 1000).toStringAsFixed(2)} km',
                          ),
                          onTap: () => _showDetails(place),
                        );
                      }),
                    },
                  ),
          ),

          // ── Nearest chips bar ─────────────────────────────────────────
          if (nearestFuel != null || nearestGarage != null)
            Container(
              color: isDark
                  ? const Color(0xFF222831)
                  : const Color(0xFFF5F5F5),
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  if (nearestFuel != null)
                    _nearestChip(
                      Icons.local_gas_station,
                      'Fuel ${(nearestFuel.distanceMeters / 1000).toStringAsFixed(2)} km',
                      const Color(0xFFFF9800),
                    ),
                  if (nearestFuel != null && nearestGarage != null)
                    const SizedBox(width: 8),
                  if (nearestGarage != null)
                    _nearestChip(
                      Icons.car_repair,
                      'Garage ${(nearestGarage.distanceMeters / 1000).toStringAsFixed(2)} km',
                      const Color(0xFF43A047),
                    ),
                ],
              ),
            ),

          // ── Loading / error ───────────────────────────────────────────
          if (_isLoading) const LinearProgressIndicator(),
          if (_error != null)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              color: const Color(0xFFE53935).withValues(alpha: 0.08),
              child: Row(
                children: [
                  const Icon(Icons.error_outline,
                      color: Color(0xFFE53935), size: 16),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _error!,
                      style: GoogleFonts.poppins(
                          color: const Color(0xFFE53935), fontSize: 12),
                    ),
                  ),
                  TextButton(
                    onPressed: _fetchPlaces,
                    child: Text('Retry', style: GoogleFonts.poppins()),
                  ),
                ],
              ),
            ),

          // ── Service list ──────────────────────────────────────────────
          Expanded(
            child: _isLoading && visible.isEmpty
                ? const Center(child: CircularProgressIndicator())
                : visible.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.store_outlined,
                                size: 56,
                                color: isDark
                                    ? Colors.white24
                                    : Colors.black26),
                            const SizedBox(height: 12),
                            Text(
                              _error != null
                                  ? 'Could not load services'
                                  : 'No services found nearby',
                              style: GoogleFonts.poppins(
                                  color: Colors.grey, fontSize: 14),
                            ),
                          ],
                        ),
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.all(16),
                        itemCount: visible.length,
                        separatorBuilder: (_, __) =>
                            const SizedBox(height: 10),
                        itemBuilder: (context, i) =>
                            _serviceCard(visible[i], isDark),
                      ),
          ),
        ],
      ),
    );
  }

  Widget _nearestChip(IconData icon, String label, Color color) => Container(
        padding:
            const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14, color: color),
            const SizedBox(width: 4),
            Text(
              label,
              style: GoogleFonts.poppins(
                  fontSize: 11, color: color, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      );

  Widget _serviceCard(NearbyPlace place, bool isDark) {
    final isFuel = place.type == 'fuel';
    final color = isFuel ? const Color(0xFFFF9800) : const Color(0xFF43A047);
    final isNearest = place.id == _nearestFuel?.id ||
        place.id == _nearestGarage?.id;

    return InkWell(
      onTap: () => _showDetails(place),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF222831) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isNearest
                ? color.withValues(alpha: 0.5)
                : (isDark
                    ? Colors.white12
                    : Colors.black.withValues(alpha: 0.06)),
            width: isNearest ? 1.5 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.12 : 0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(
                isFuel ? Icons.local_gas_station : Icons.car_repair,
                color: color,
                size: 22,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          place.name,
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (isNearest)
                        Container(
                          margin: const EdgeInsets.only(left: 6),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: color.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            'Nearest',
                            style: GoogleFonts.poppins(
                              fontSize: 10,
                              color: color,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    place.address.trim().isEmpty
                        ? isFuel
                            ? 'Fuel Station'
                            : 'Auto Garage'
                        : place.address,
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: Colors.grey,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                '${(place.distanceMeters / 1000).toStringAsFixed(1)} km',
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  color: color,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
