import 'package:flutter/material.dart';

class ServiceHistoryScreen extends StatelessWidget {
  const ServiceHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Service History')),
      body: const Center(
        child: Text('Service history records will appear here.'),
      ),
    );
  }
}
