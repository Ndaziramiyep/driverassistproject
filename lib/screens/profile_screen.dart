import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';
import '../services/maintenance_service.dart';
import '../services/vehicle_service.dart';
import '../utils/constants.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().currentUser;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final initials = _initials(user?.displayName);

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // Hero header
          SliverToBoxAdapter(
            child: Container(
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFF1565C0), Color(0xFF1E88E5)],
                ),
                borderRadius: const BorderRadius.vertical(
                  bottom: Radius.circular(28),
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF1E88E5).withValues(alpha: 0.3),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: SafeArea(
                bottom: false,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
                  child: Column(
                    children: [
                      // Top row
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'My Profile',
                            style: GoogleFonts.poppins(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.settings_outlined,
                                color: Colors.white70),
                            onPressed: () => Navigator.pushNamed(
                                context, AppRoutes.settings),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      // Avatar
                      Stack(
                        alignment: Alignment.bottomRight,
                        children: [
                          user?.photoUrl != null
                              ? CircleAvatar(
                                  radius: 46,
                                  backgroundColor:
                                      Colors.white.withValues(alpha: 0.2),
                                  backgroundImage:
                                      NetworkImage(user!.photoUrl!),
                                )
                              : CircleAvatar(
                                  radius: 46,
                                  backgroundColor:
                                      Colors.white.withValues(alpha: 0.25),
                                  child: Text(
                                    initials,
                                    style: GoogleFonts.poppins(
                                      color: Colors.white,
                                      fontSize: 28,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                          Container(
                            padding: const EdgeInsets.all(4),
                            decoration: const BoxDecoration(
                              color: Color(0xFF1E88E5),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.verified,
                                color: Colors.white, size: 14),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Text(
                        user?.displayName ?? 'Driver',
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        user?.email ?? '',
                        style: GoogleFonts.poppins(
                          color: Colors.white70,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 20)),

          // Stats row
          if (user != null)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: _StatsRow(userId: user.id),
              ),
            ),

          const SliverToBoxAdapter(child: SizedBox(height: 20)),

          // Menu sections
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _sectionHeader('My Vehicles & Maintenance', isDark),
                  const SizedBox(height: 8),
                  _menuCard(
                    context: context,
                    items: [
                      const _MenuItem(
                        icon: Icons.directions_car_rounded,
                        label: 'Vehicle Management',
                        color: Color(0xFF1E88E5),
                        route: AppRoutes.vehicleManagement,
                      ),
                      const _MenuItem(
                        icon: Icons.build_rounded,
                        label: 'Maintenance',
                        color: Color(0xFF43A047),
                        route: AppRoutes.maintenance,
                      ),
                      const _MenuItem(
                        icon: Icons.history_rounded,
                        label: 'Service History',
                        color: Color(0xFFFF9800),
                        route: AppRoutes.serviceHistory,
                      ),
                    ],
                    isDark: isDark,
                  ),
                  const SizedBox(height: 20),
                  _sectionHeader('Safety & Emergency', isDark),
                  const SizedBox(height: 8),
                  _menuCard(
                    context: context,
                    items: [
                      const _MenuItem(
                        icon: Icons.contacts_rounded,
                        label: 'Emergency Contacts',
                        color: Color(0xFFE53935),
                        route: AppRoutes.emergencyContacts,
                      ),
                      const _MenuItem(
                        icon: Icons.place_rounded,
                        label: 'Saved Locations',
                        color: Color(0xFF9C27B0),
                        route: AppRoutes.savedLocations,
                      ),
                    ],
                    isDark: isDark,
                  ),
                  const SizedBox(height: 20),
                  _sectionHeader('Account', isDark),
                  const SizedBox(height: 8),
                  _menuCard(
                    context: context,
                    items: [
                      const _MenuItem(
                        icon: Icons.lock_outline_rounded,
                        label: 'Change Password',
                        color: Color(0xFF607D8B),
                        route: AppRoutes.changePassword,
                      ),
                      const _MenuItem(
                        icon: Icons.settings_outlined,
                        label: 'Settings',
                        color: Color(0xFF455A64),
                        route: AppRoutes.settings,
                      ),
                    ],
                    isDark: isDark,
                  ),
                  const SizedBox(height: 28),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _initials(String? name) {
    if (name == null || name.trim().isEmpty) return 'D';
    final parts = name.trim().split(' ');
    if (parts.length == 1) return parts[0][0].toUpperCase();
    return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
  }

  Widget _sectionHeader(String title, bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: Text(
        title,
        style: GoogleFonts.poppins(
          fontWeight: FontWeight.w700,
          fontSize: 13,
          color: isDark ? Colors.white54 : Colors.black45,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _menuCard({
    required BuildContext context,
    required List<_MenuItem> items,
    required bool isDark,
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
      child: Column(
        children: List.generate(items.length, (i) {
          final item = items[i];
          final isLast = i == items.length - 1;
          return Column(
            children: [
              ListTile(
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: item.color.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(item.icon, color: item.color, size: 20),
                ),
                title: Text(
                  item.label,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                trailing: Icon(
                  Icons.chevron_right_rounded,
                  color: isDark ? Colors.white38 : Colors.black26,
                ),
                onTap: () => Navigator.pushNamed(context, item.route),
              ),
              if (!isLast)
                Divider(
                  height: 1,
                  indent: 56,
                  color: isDark ? Colors.white12 : Colors.black.withValues(alpha: 0.06),
                ),
            ],
          );
        }),
      ),
    );
  }
}

class _MenuItem {
  final IconData icon;
  final String label;
  final Color color;
  final String route;

  const _MenuItem({
    required this.icon,
    required this.label,
    required this.color,
    required this.route,
  });
}

class _StatsRow extends StatelessWidget {
  final String userId;
  const _StatsRow({required this.userId});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return FutureBuilder(
      future: Future.wait([
        VehicleService().getUserVehicles(userId),
        MaintenanceService().getOverdueMaintenance(userId),
      ]),
      builder: (context, snapshot) {
        final vehicleCount =
            snapshot.hasData ? (snapshot.data![0] as List).length : 0;
        final pendingCount =
            snapshot.hasData ? (snapshot.data![1] as List).length : 0;

        return Row(
          children: [
            _statCard(
              icon: Icons.directions_car_rounded,
              value: '$vehicleCount',
              label: 'Vehicles',
              color: const Color(0xFF1E88E5),
              isDark: isDark,
            ),
            const SizedBox(width: 10),
            _statCard(
              icon: Icons.build_rounded,
              value: '$pendingCount',
              label: 'Overdue Tasks',
              color: const Color(0xFFFF9800),
              isDark: isDark,
            ),
            const SizedBox(width: 10),
            _statCard(
              icon: Icons.verified_user_rounded,
              value: 'Active',
              label: 'Account',
              color: const Color(0xFF43A047),
              isDark: isDark,
            ),
          ],
        );
      },
    );
  }

  Widget _statCard({
    required IconData icon,
    required String value,
    required String label,
    required Color color,
    required bool isDark,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 10),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF222831) : Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.15 : 0.06),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 22),
            const SizedBox(height: 6),
            Text(
              value,
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w700,
                fontSize: 16,
                color: color,
              ),
            ),
            Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 10,
                color: isDark ? Colors.white54 : Colors.black45,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
