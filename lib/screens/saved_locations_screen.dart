import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/saved_location_model.dart';
import '../providers/auth_provider.dart';
import '../providers/saved_locations_provider.dart';

class SavedLocationsScreen extends StatefulWidget {
  const SavedLocationsScreen({super.key});

  @override
  State<SavedLocationsScreen> createState() => _SavedLocationsScreenState();
}

class _SavedLocationsScreenState extends State<SavedLocationsScreen> {
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final userId = context.read<AuthProvider>().currentUser?.id;
    if (userId != null) {
      context.read<SavedLocationsProvider>().loadLocations(userId);
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<SavedLocationsProvider>();
    final userId = context.watch<AuthProvider>().currentUser?.id;

    return Scaffold(
      appBar: AppBar(title: const Text('Saved Locations')),
      floatingActionButton: FloatingActionButton(
        onPressed:
            userId == null
                ? null
                : () async {
                  final now = DateTime.now();
                  await provider.addLocation(
                    SavedLocationModel(
                      id: '',
                      userId: userId,
                      name: 'Custom ${now.hour}:${now.minute}',
                      address: 'Unknown address',
                      latitude: 0,
                      longitude: 0,
                      type: 'other',
                      createdAt: now,
                    ),
                  );
                },
        child: const Icon(Icons.add),
      ),
      body:
          provider.isLoading
              ? const Center(child: CircularProgressIndicator())
              : provider.savedLocations.isEmpty
              ? const Center(child: Text('No saved locations.'))
              : ListView.builder(
                itemCount: provider.savedLocations.length,
                itemBuilder: (context, index) {
                  final item = provider.savedLocations[index];
                  return ListTile(
                    leading: const Icon(Icons.place_outlined),
                    title: Text(item.name),
                    subtitle: Text('${item.type} • ${item.address}'),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete_outline),
                      onPressed: () => provider.deleteLocation(item.id),
                    ),
                  );
                },
              ),
    );
  }
}
