import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';
import '../services/vehicle_service.dart';
import '../utils/constants.dart';
import '../widgets/vehicle_card.dart';

class VehicleManagementScreen extends StatelessWidget {
  const VehicleManagementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final userId = context.watch<AuthProvider>().currentUser?.id;

    return Scaffold(
      appBar: AppBar(title: const Text('Vehicles')),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.pushNamed(context, AppRoutes.addVehicle),
        child: const Icon(Icons.add),
      ),
      body:
          userId == null
              ? const Center(child: Text('Please sign in.'))
              : StreamBuilder(
                stream: VehicleService().vehicleStream(userId),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  final vehicles = snapshot.data!;
                  if (vehicles.isEmpty) {
                    return const Center(child: Text('No vehicles added yet.'));
                  }
                  return ListView.builder(
                    padding: const EdgeInsets.all(12),
                    itemCount: vehicles.length,
                    itemBuilder: (context, index) {
                      final vehicle = vehicles[index];
                      return VehicleCard(
                        vehicle: vehicle,
                        onEdit:
                            () => Navigator.pushNamed(
                              context,
                              AppRoutes.editVehicle,
                              arguments: vehicle,
                            ),
                        onDelete: () async {
                          await VehicleService().deleteVehicle(vehicle.id);
                        },
                      );
                    },
                  );
                },
              ),
    );
  }
}
