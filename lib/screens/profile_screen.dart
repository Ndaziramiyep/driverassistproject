import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';
import '../utils/constants.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().currentUser;

    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: ListTile(
              leading: const CircleAvatar(child: Icon(Icons.person)),
              title: Text(user?.displayName ?? 'Driver'),
              subtitle: Text(user?.email ?? 'Not signed in'),
            ),
          ),
          const SizedBox(height: 8),
          ListTile(
            leading: const Icon(Icons.directions_car_outlined),
            title: const Text('Vehicle Management'),
            onTap:
                () => Navigator.pushNamed(context, AppRoutes.vehicleManagement),
          ),
          ListTile(
            leading: const Icon(Icons.build_outlined),
            title: const Text('Maintenance'),
            onTap: () => Navigator.pushNamed(context, AppRoutes.maintenance),
          ),
          ListTile(
            leading: const Icon(Icons.history_outlined),
            title: const Text('Service History'),
            onTap: () => Navigator.pushNamed(context, AppRoutes.serviceHistory),
          ),
          ListTile(
            leading: const Icon(Icons.contacts_outlined),
            title: const Text('Emergency Contacts'),
            onTap:
                () => Navigator.pushNamed(context, AppRoutes.emergencyContacts),
          ),
        ],
      ),
    );
  }
}
