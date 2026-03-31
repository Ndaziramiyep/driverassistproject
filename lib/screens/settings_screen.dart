import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';
import '../providers/biometric_provider.dart';
import '../providers/theme_provider.dart';
import '../utils/constants.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = context.watch<ThemeProvider>();
    final bio = context.watch<BiometricProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        children: [
          SwitchListTile(
            title: const Text('Dark mode'),
            value: theme.themeMode == ThemeMode.dark,
            onChanged: (_) => theme.toggleTheme(),
          ),
          SwitchListTile(
            title: const Text('Biometric login'),
            value: bio.isBiometricEnabled,
            onChanged: (enabled) async {
              if (enabled) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Enable from register/login flow.'),
                  ),
                );
              } else {
                await bio.disableBiometric();
              }
            },
          ),
          ListTile(
            leading: const Icon(Icons.lock_outline),
            title: const Text('Change Password'),
            onTap: () => Navigator.pushNamed(context, AppRoutes.changePassword),
          ),
          ListTile(
            leading: const Icon(Icons.place_outlined),
            title: const Text('Saved Locations'),
            onTap: () => Navigator.pushNamed(context, AppRoutes.savedLocations),
          ),
          ListTile(
            leading: const Icon(Icons.notifications_outlined),
            title: const Text('Notifications'),
            onTap: () => Navigator.pushNamed(context, AppRoutes.notifications),
          ),
          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text('Sign Out'),
            onTap: () async {
              await context.read<AuthProvider>().signOut();
              if (!context.mounted) return;
              Navigator.pushNamedAndRemoveUntil(
                context,
                AppRoutes.login,
                (route) => false,
              );
            },
          ),
        ],
      ),
    );
  }
}
