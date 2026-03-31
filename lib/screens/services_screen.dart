import 'package:flutter/material.dart';

import '../models/service_provider_model.dart';
import '../widgets/service_provider_card.dart';

class ServicesScreen extends StatelessWidget {
  const ServicesScreen({super.key});

  static final _mockProviders = [
    ServiceProviderModel(
      id: '1',
      name: 'QuickFix Garage',
      type: 'mechanic',
      address: '12 Market Road',
      latitude: 0,
      longitude: 0,
      rating: 4.6,
      reviewCount: 90,
      phone: '+250700000001',
      isOpen: true,
      distance: 1.2,
    ),
    ServiceProviderModel(
      id: '2',
      name: 'City Fuel Station',
      type: 'fuel',
      address: 'Airport Avenue',
      latitude: 0,
      longitude: 0,
      rating: 4.4,
      reviewCount: 120,
      phone: '+250700000002',
      isOpen: true,
      distance: 2.1,
    ),
    ServiceProviderModel(
      id: '3',
      name: 'ChargeHub',
      type: 'charging_station',
      address: 'Downtown',
      latitude: 0,
      longitude: 0,
      rating: 4.1,
      reviewCount: 45,
      phone: '+250700000003',
      isOpen: false,
      distance: 2.8,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Nearby Services')),
      body: ListView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: _mockProviders.length,
        itemBuilder: (context, index) {
          final provider = _mockProviders[index];
          return ServiceProviderCard(
            provider: provider,
            onTap: () {},
            onCall: () {},
          );
        },
      ),
    );
  }
}
