import 'package:flutter/material.dart';

import '../models/maintenance_model.dart';
import '../services/maintenance_service.dart';

class MaintenanceDetailScreen extends StatelessWidget {
  const MaintenanceDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)?.settings.arguments;
    final maintenance = args is MaintenanceModel ? args : null;

    if (maintenance == null) {
      return const Scaffold(
        body: Center(child: Text('Maintenance item not found.')),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Maintenance Detail')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          ListTile(
            title: const Text('Title'),
            subtitle: Text(maintenance.title),
          ),
          ListTile(
            title: const Text('Description'),
            subtitle: Text(maintenance.description ?? '-'),
          ),
          ListTile(
            title: const Text('Priority'),
            subtitle: Text(maintenance.priority),
          ),
          ListTile(
            title: const Text('Due Date'),
            subtitle: Text(
              maintenance.dueDate == null
                  ? '-'
                  : '${maintenance.dueDate!.day}/${maintenance.dueDate!.month}/${maintenance.dueDate!.year}',
            ),
          ),
          ListTile(
            title: const Text('Due Mileage'),
            subtitle: Text(maintenance.dueMileage?.toString() ?? '-'),
          ),
          const SizedBox(height: 12),
          ElevatedButton.icon(
            onPressed:
                maintenance.isCompleted
                    ? null
                    : () async {
                      await MaintenanceService().completeMaintenance(
                        maintenance.id,
                      );
                      if (!context.mounted) return;
                      Navigator.pop(context);
                    },
            icon: const Icon(Icons.check),
            label: const Text('Mark Completed'),
          ),
        ],
      ),
    );
  }
}
