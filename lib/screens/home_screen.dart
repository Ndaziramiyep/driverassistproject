import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';
import '../providers/location_provider.dart';
import '../utils/constants.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  GoogleMapController? _mapController;
  BitmapDescriptor? _currentMarkerIcon;

  @override
  void initState() {
    super.initState();
    _prepareMarkerIcon();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await context.read<LocationProvider>().getCurrentLocation();
    });
  }

  Future<void> _prepareMarkerIcon() async {
    final icon = await _createMarkerIcon(
      icon: Icons.my_location,
      backgroundColor: const Color(0xFF1E88E5),
    );
    if (!mounted) return;
    setState(() => _currentMarkerIcon = icon);
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
    if (byteData == null) return BitmapDescriptor.defaultMarker;
    return BitmapDescriptor.fromBytes(byteData.buffer.asUint8List());
  }

  String _greeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good Morning';
    if (hour < 17) return 'Good Afternoon';
    return 'Good Evening';
  }

  @override
  Widget build(BuildContext context) {
    final location = context.watch<LocationProvider>();
    final user = context.watch<AuthProvider>().currentUser;
    final position = location.currentPosition;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: Stack(
        children: [
          // ── Full-screen map ──────────────────────────────────────────
          Positioned.fill(
            child: position == null
                ? Container(
                    color: isDark
                        ? const Color(0xFF181A20)
                        : const Color(0xFFE8F0FE),
                    child: const Center(child: CircularProgressIndicator()),
                  )
                : GoogleMap(
                    onMapCreated: (c) => _mapController = c,
                    initialCameraPosition: CameraPosition(
                      target: LatLng(position.latitude, position.longitude),
                      zoom: 15,
                    ),
                    myLocationEnabled: true,
                    myLocationButtonEnabled: false,
                    zoomControlsEnabled: false,
                    mapToolbarEnabled: false,
                    circles: {
                      Circle(
                        circleId: const CircleId('radius'),
                        center: LatLng(position.latitude, position.longitude),
                        radius: 120,
                        fillColor: const Color(0x221E88E5),
                        strokeColor: const Color(0x881E88E5),
                        strokeWidth: 2,
                      ),
                    },
                    markers: {
                      Marker(
                        markerId: const MarkerId('me'),
                        position: LatLng(position.latitude, position.longitude),
                        icon: _currentMarkerIcon ??
                            BitmapDescriptor.defaultMarkerWithHue(
                                BitmapDescriptor.hueAzure),
                        infoWindow: InfoWindow(
                          title: 'You are here',
                          snippet: location.currentAddress,
                        ),
                      ),
                    },
                  ),
          ),

          // ── Top header overlay ───────────────────────────────────────
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: _glassCard(
                            isDark: isDark,
                            child: Row(
                              children: [
                                const Icon(Icons.waving_hand_rounded,
                                    size: 16, color: Color(0xFFFFA726)),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    '${_greeting()}, ${user?.displayName.split(' ').first ?? 'Driver'}',
                                    style: GoogleFonts.poppins(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 13,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        _glassIconBtn(
                          icon: Icons.notifications_outlined,
                          isDark: isDark,
                          onTap: () => Navigator.pushNamed(
                              context, AppRoutes.notifications),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    _glassCard(
                      isDark: isDark,
                      child: Row(
                        children: [
                          if (location.isLoading)
                            const SizedBox(
                              width: 14,
                              height: 14,
                              child:
                                  CircularProgressIndicator(strokeWidth: 2),
                            )
                          else
                            const Icon(Icons.location_on,
                                size: 15, color: Color(0xFF1E88E5)),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              location.isLoading
                                  ? 'Getting location...'
                                  : location.currentAddress,
                              style: GoogleFonts.poppins(fontSize: 12),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // ── My-location button ────────────────────────────────────────
          Positioned(
            right: 16,
            bottom: 120,
            child: _glassIconBtn(
              icon: Icons.my_location,
              isDark: isDark,
              onTap: () {
                if (position != null) {
                  _mapController?.animateCamera(
                    CameraUpdate.newLatLngZoom(
                        LatLng(position.latitude, position.longitude), 16),
                  );
                }
              },
            ),
          ),

          // ── Nearby Services floating button ──────────────────────────
          Positioned(
            left: 16,
            right: 16,
            bottom: 24,
            child: SafeArea(
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1E88E5),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 6,
                  shadowColor:
                      const Color(0xFF1E88E5).withValues(alpha: 0.4),
                ),
                icon: const Icon(Icons.store_mall_directory_rounded, size: 20),
                label: Text(
                  'Find Nearby Services',
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                  ),
                ),
                onPressed: () => Navigator.pushNamed(
                  context,
                  AppRoutes.nearbyServices,
                  arguments: position != null
                      ? {'lat': position.latitude, 'lng': position.longitude}
                      : null,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _glassCard({required bool isDark, required Widget child}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.black.withValues(alpha: 0.65)
            : Colors.white.withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: child,
    );
  }

  Widget _glassIconBtn({
    required IconData icon,
    required bool isDark,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 42,
        height: 42,
        decoration: BoxDecoration(
          color: isDark
              ? Colors.black.withValues(alpha: 0.65)
              : Colors.white.withValues(alpha: 0.92),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Icon(icon, size: 20),
      ),
    );
  }
}
