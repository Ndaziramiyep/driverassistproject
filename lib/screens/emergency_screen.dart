import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';
import '../providers/location_provider.dart';
import '../services/emergency_service.dart';
import '../utils/constants.dart';
import '../widgets/emergency_button.dart';

class EmergencyScreen extends StatelessWidget {
  const EmergencyScreen({super.key});

  Future<void> _sendSos(BuildContext context, String type) async {
    final user = context.read<AuthProvider>().currentUser;
    final location = context.read<LocationProvider>().currentPosition;

    if (user == null || location == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Missing account or location data.')),
      );
      return;
    }

    await EmergencyService().createEmergencyRequest(
      user.id,
      type,
      location.latitude,
      location.longitude,
      context.read<LocationProvider>().currentAddress,
    );

    if (!context.mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Emergency request sent.')));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Emergency')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 24),
            EmergencyButton(
              onActivated: () =>
                  _sendSos(context, AppConstants.emergencyAmbulance),
            ),
            const SizedBox(height: 28),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                _typeChip(context, 'Police', AppConstants.emergencyPolice),
                _typeChip(
                  context,
                  'Ambulance',
                  AppConstants.emergencyAmbulance,
                ),
                _typeChip(context, 'Fire', AppConstants.emergencyFire),
                _typeChip(context, 'Mechanic', AppConstants.emergencyMechanic),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _typeChip(BuildContext context, String label, String value) {
    return ActionChip(
      avatar: const Icon(Icons.warning, size: 16, color: Color(0xFFFF9800)),
      backgroundColor: const Color(0xFFFF9800).withValues(alpha: 0.1),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      label: Text(label),
      onPressed: () => _sendSos(context, value),
    );
  }
}
