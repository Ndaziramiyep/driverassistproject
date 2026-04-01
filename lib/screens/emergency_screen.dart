import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';
import '../providers/location_provider.dart';
import '../services/emergency_service.dart';
import '../utils/constants.dart';

class EmergencyScreen extends StatefulWidget {
  const EmergencyScreen({super.key});

  @override
  State<EmergencyScreen> createState() => _EmergencyScreenState();
}

class _EmergencyScreenState extends State<EmergencyScreen>
    with TickerProviderStateMixin {
  late final AnimationController _pulseController;
  late final Animation<double> _pulse1;
  late final Animation<double> _pulse2;
  bool _isSending = false;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();
    _pulse1 = CurvedAnimation(parent: _pulseController, curve: Curves.easeOut);
    _pulse2 = CurvedAnimation(
        parent: _pulseController,
        curve: const Interval(0.3, 1.0, curve: Curves.easeOut));
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  Future<void> _sendSos(String type, String label) async {
    final confirmed = await showDialog<bool>(
      context: context,
      barrierColor: Colors.black87,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: Theme.of(context).colorScheme.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            const Icon(Icons.warning_rounded, color: Color(0xFFE53935)),
            const SizedBox(width: 8),
            Text(
              'Send $label Alert?',
              style: GoogleFonts.poppins(fontWeight: FontWeight.w700),
            ),
          ],
        ),
        content: Text(
          'This will send your current location to emergency services. Only use in a real emergency.',
          style: GoogleFonts.poppins(fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text('Cancel', style: GoogleFonts.poppins()),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFE53935),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: Text('Send Alert', style: GoogleFonts.poppins()),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    final user = context.read<AuthProvider>().currentUser;
    final location = context.read<LocationProvider>();

    if (user == null || location.currentPosition == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            user == null
                ? 'Please sign in to use emergency services.'
                : 'Location unavailable. Please enable GPS.',
            style: GoogleFonts.poppins(),
          ),
          backgroundColor: const Color(0xFFE53935),
        ),
      );
      return;
    }

    setState(() => _isSending = true);

    try {
      await EmergencyService().createEmergencyRequest(
        user.id,
        type,
        location.currentPosition!.latitude,
        location.currentPosition!.longitude,
        location.currentAddress,
      );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.check_circle, color: Colors.white, size: 18),
              const SizedBox(width: 8),
              Text('$label alert sent successfully!',
                  style: GoogleFonts.poppins()),
            ],
          ),
          backgroundColor: const Color(0xFF43A047),
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to send alert. Please try again.',
              style: GoogleFonts.poppins()),
          backgroundColor: const Color(0xFFE53935),
        ),
      );
    } finally {
      if (mounted) setState(() => _isSending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final location = context.watch<LocationProvider>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor:
          isDark ? const Color(0xFF1A0A0A) : const Color(0xFFFFF5F5),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'Emergency SOS',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w700,
            color: const Color(0xFFE53935),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.contacts_outlined),
            color: const Color(0xFFE53935),
            tooltip: 'Emergency Contacts',
            onPressed: () =>
                Navigator.pushNamed(context, AppRoutes.emergencyContacts),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              // Location status banner
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.06)
                      : Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                      color: const Color(0xFFE53935).withValues(alpha: 0.2)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.04),
                      blurRadius: 8,
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Icon(
                      location.currentPosition != null
                          ? Icons.location_on
                          : Icons.location_off,
                      color: location.currentPosition != null
                          ? const Color(0xFF43A047)
                          : const Color(0xFFE53935),
                      size: 18,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        location.isLoading
                            ? 'Getting your location...'
                            : location.currentPosition != null
                                ? location.currentAddress
                                : 'Location unavailable — enable GPS',
                        style: GoogleFonts.poppins(fontSize: 12),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (location.isLoading)
                      const SizedBox(
                        width: 14,
                        height: 14,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                  ],
                ),
              ),

              const SizedBox(height: 28),

              // Main SOS button
              _SosPulseButton(
                pulse1: _pulse1,
                pulse2: _pulse2,
                isSending: _isSending,
                onTap: () => _sendSos(
                    AppConstants.emergencyAmbulance, 'General SOS'),
              ),

              const SizedBox(height: 10),
              Text(
                _isSending ? 'Sending alert...' : 'Tap for General SOS',
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  color: const Color(0xFFE53935).withValues(alpha: 0.7),
                  fontWeight: FontWeight.w500,
                ),
              ),

              const SizedBox(height: 32),

              // Emergency type grid
              Text(
                'Select Emergency Type',
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w700,
                  fontSize: 15,
                ),
              ),
              const SizedBox(height: 14),
              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 1.3,
                children: [
                  _emergencyTypeCard(
                    icon: Icons.local_police,
                    label: 'Police',
                    subtitle: 'Crime / Security',
                    color: const Color(0xFF1E88E5),
                    type: AppConstants.emergencyPolice,
                  ),
                  _emergencyTypeCard(
                    icon: Icons.medical_services,
                    label: 'Ambulance',
                    subtitle: 'Medical Emergency',
                    color: const Color(0xFFE53935),
                    type: AppConstants.emergencyAmbulance,
                  ),
                  _emergencyTypeCard(
                    icon: Icons.local_fire_department,
                    label: 'Fire',
                    subtitle: 'Fire / Hazard',
                    color: const Color(0xFFFF5722),
                    type: AppConstants.emergencyFire,
                  ),
                  _emergencyTypeCard(
                    icon: Icons.build,
                    label: 'Mechanic',
                    subtitle: 'Vehicle Breakdown',
                    color: const Color(0xFF795548),
                    type: AppConstants.emergencyMechanic,
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // Info card
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFFFF9800).withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                      color: const Color(0xFFFF9800).withValues(alpha: 0.25)),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.info_outline,
                        color: Color(0xFFFF9800), size: 18),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Your GPS location will be shared when you send an alert. Only use this in genuine emergencies.',
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: const Color(0xFFFF9800),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _emergencyTypeCard({
    required IconData icon,
    required String label,
    required String subtitle,
    required Color color,
    required String type,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return GestureDetector(
      onTap: _isSending ? null : () => _sendSos(type, label),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        decoration: BoxDecoration(
          color: isDark
              ? color.withValues(alpha: 0.12)
              : color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withValues(alpha: 0.35), width: 1.5),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.1),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, color: color, size: 30),
              const SizedBox(height: 8),
              Text(
                label,
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w700,
                  fontSize: 15,
                  color: color,
                ),
              ),
              Text(
                subtitle,
                style: GoogleFonts.poppins(
                  fontSize: 11,
                  color: color.withValues(alpha: 0.7),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SosPulseButton extends StatelessWidget {
  final Animation<double> pulse1;
  final Animation<double> pulse2;
  final bool isSending;
  final VoidCallback onTap;

  const _SosPulseButton({
    required this.pulse1,
    required this.pulse2,
    required this.isSending,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 180,
      height: 180,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Outer pulse ring 1
          AnimatedBuilder(
            animation: pulse1,
            builder: (context, _) => Transform.scale(
              scale: 0.85 + (pulse1.value * 0.5),
              child: Container(
                width: 180,
                height: 180,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFFE53935)
                      .withValues(alpha: (1 - pulse1.value) * 0.25),
                ),
              ),
            ),
          ),
          // Outer pulse ring 2
          AnimatedBuilder(
            animation: pulse2,
            builder: (context, _) => Transform.scale(
              scale: 0.75 + (pulse2.value * 0.4),
              child: Container(
                width: 180,
                height: 180,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFFE53935)
                      .withValues(alpha: (1 - pulse2.value) * 0.2),
                ),
              ),
            ),
          ),
          // Button
          GestureDetector(
            onTap: isSending ? null : onTap,
            child: Container(
              width: 130,
              height: 130,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const RadialGradient(
                  colors: [
                    Color(0xFFEF5350),
                    Color(0xFFB71C1C),
                  ],
                  center: Alignment.topLeft,
                  radius: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFE53935).withValues(alpha: 0.5),
                    blurRadius: 20,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: isSending
                  ? const Center(
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 3,
                      ),
                    )
                  : Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.emergency,
                            color: Colors.white, size: 42),
                        const SizedBox(height: 4),
                        Text(
                          'SOS',
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 3,
                          ),
                        ),
                      ],
                    ),
            ),
          ),
        ],
      ),
    );
  }
}

