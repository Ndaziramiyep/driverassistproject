import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';
import '../services/maintenance_service.dart';
import '../utils/constants.dart';
import '../widgets/maintenance_card.dart';

class MaintenanceScreen extends StatelessWidget {
  const MaintenanceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final userId = context.watch<AuthProvider>().currentUser?.id;

    return Scaffold(
      appBar: AppBar(title: const Text('Maintenance')),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.pushNamed(context, AppRoutes.addMaintenance),
        child: const Icon(Icons.add),
      ),
      body:
          userId == null
              ? const Center(child: Text('Please sign in.'))
              : StreamBuilder(
                stream: MaintenanceService().userMaintenanceStream(userId),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  final items = snapshot.data!;
                  if (items.isEmpty) {
                    return const Center(child: Text('No reminders yet.'));
                  }
                  return ListView.builder(
                    padding: const EdgeInsets.all(12),
                    itemCount: items.length,
                    itemBuilder: (context, index) {
                      final item = items[index];
                      return MaintenanceCard(
                        maintenance: item,
                        onTap:
                            () => Navigator.pushNamed(
                              context,
                              AppRoutes.maintenanceDetail,
                              arguments: item,
                            ),
                        onDelete: () async {
                          await MaintenanceService().deleteMaintenance(item.id);
                        },
                      );
                    },
                  );
                },
              ),
    );
  }
}
