import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
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
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Settings',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w700),
        ),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        children: [
          // App Preferences
          _sectionLabel('App Preferences', isDark),
          const SizedBox(height: 8),
          _settingsCard(
            isDark: isDark,
            children: [
              _switchTile(
                icon: Icons.dark_mode_rounded,
                iconColor: const Color(0xFF5C6BC0),
                title: 'Dark Mode',
                subtitle: 'Switch between light and dark theme',
                value: theme.themeMode == ThemeMode.dark,
                onChanged: (_) => theme.toggleTheme(),
                isDark: isDark,
              ),
              _divider(isDark),
              _switchTile(
                icon: Icons.fingerprint_rounded,
                iconColor: const Color(0xFF43A047),
                title: 'Biometric Login',
                subtitle: bio.isBiometricAvailable
                    ? 'Use fingerprint or face to sign in'
                    : 'Not available on this device',
                value: bio.isBiometricEnabled,
                onChanged: bio.isBiometricAvailable
                    ? (enabled) async {
                        if (enabled) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                'Enable biometrics from the login screen after signing out.',
                                style: GoogleFonts.poppins(),
                              ),
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                        } else {
                          await bio.disableBiometric();
                        }
                      }
                    : null,
                isDark: isDark,
              ),
            ],
          ),

          const SizedBox(height: 20),

          // Notifications
          _sectionLabel('Notifications', isDark),
          const SizedBox(height: 8),
          _settingsCard(
            isDark: isDark,
            children: [
              _navTile(
                context: context,
                icon: Icons.notifications_outlined,
                iconColor: const Color(0xFFFF9800),
                title: 'Notification Centre',
                subtitle: 'View and manage your alerts',
                route: AppRoutes.notifications,
                isDark: isDark,
              ),
            ],
          ),

          const SizedBox(height: 20),

          // Location & Safety
          _sectionLabel('Location & Safety', isDark),
          const SizedBox(height: 8),
          _settingsCard(
            isDark: isDark,
            children: [
              _navTile(
                context: context,
                icon: Icons.place_rounded,
                iconColor: const Color(0xFF9C27B0),
                title: 'Saved Locations',
                subtitle: 'Home, work and favourite places',
                route: AppRoutes.savedLocations,
                isDark: isDark,
              ),
              _divider(isDark),
              _navTile(
                context: context,
                icon: Icons.contacts_rounded,
                iconColor: const Color(0xFFE53935),
                title: 'Emergency Contacts',
                subtitle: 'Manage your emergency contacts',
                route: AppRoutes.emergencyContacts,
                isDark: isDark,
              ),
            ],
          ),

          const SizedBox(height: 20),

          // Account
          _sectionLabel('Account', isDark),
          const SizedBox(height: 8),
          _settingsCard(
            isDark: isDark,
            children: [
              _navTile(
                context: context,
                icon: Icons.lock_outline_rounded,
                iconColor: const Color(0xFF607D8B),
                title: 'Change Password',
                subtitle: 'Update your account password',
                route: AppRoutes.changePassword,
                isDark: isDark,
              ),
            ],
          ),

          const SizedBox(height: 20),

          // Sign out
          _settingsCard(
            isDark: isDark,
            children: [
              ListTile(
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE53935).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.logout_rounded,
                      color: Color(0xFFE53935), size: 20),
                ),
                title: Text(
                  'Sign Out',
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFFE53935),
                    fontSize: 14,
                  ),
                ),
                subtitle: Text(
                  'You will be signed out of your account',
                  style: GoogleFonts.poppins(fontSize: 12),
                ),
                onTap: () async {
                  final confirmed = await showDialog<bool>(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20)),
                      title: Text('Sign Out',
                          style:
                              GoogleFonts.poppins(fontWeight: FontWeight.w700)),
                      content: Text(
                        'Are you sure you want to sign out?',
                        style: GoogleFonts.poppins(),
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.of(ctx).pop(false),
                          child: Text('Cancel', style: GoogleFonts.poppins()),
                        ),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFE53935),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10)),
                          ),
                          onPressed: () => Navigator.of(ctx).pop(true),
                          child:
                              Text('Sign Out', style: GoogleFonts.poppins()),
                        ),
                      ],
                    ),
                  );
                  if (confirmed != true || !context.mounted) return;
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

          const SizedBox(height: 24),

          // App version footer
          Center(
            child: Text(
              'DriverAssist v1.0.0',
              style: GoogleFonts.poppins(
                fontSize: 12,
                color: isDark ? Colors.white38 : Colors.black38,
              ),
            ),
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }

  Widget _sectionLabel(String label, bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: Text(
        label.toUpperCase(),
        style: GoogleFonts.poppins(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.8,
          color: isDark ? Colors.white38 : Colors.black38,
        ),
      ),
    );
  }

  Widget _settingsCard({
    required bool isDark,
    required List<Widget> children,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF222831) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.15 : 0.06),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(children: children),
    );
  }

  Widget _divider(bool isDark) => Divider(
        height: 1,
        indent: 56,
        color:
            isDark ? Colors.white12 : Colors.black.withValues(alpha: 0.06),
      );

  Widget _switchTile({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool>? onChanged,
    required bool isDark,
  }) {
    return SwitchListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
      secondary: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: iconColor.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: iconColor, size: 20),
      ),
      title: Text(
        title,
        style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w500),
      ),
      subtitle: Text(subtitle, style: GoogleFonts.poppins(fontSize: 12)),
      value: value,
      onChanged: onChanged,
      activeColor: iconColor,
    );
  }

  Widget _navTile({
    required BuildContext context,
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required String route,
    required bool isDark,
  }) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: iconColor.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: iconColor, size: 20),
      ),
      title: Text(
        title,
        style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w500),
      ),
      subtitle: Text(subtitle, style: GoogleFonts.poppins(fontSize: 12)),
      trailing: Icon(
        Icons.chevron_right_rounded,
        color: isDark ? Colors.white38 : Colors.black26,
      ),
      onTap: () => Navigator.pushNamed(context, route),
    );
  }
}
