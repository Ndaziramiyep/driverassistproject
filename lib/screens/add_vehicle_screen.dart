import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/vehicle_model.dart';
import '../providers/auth_provider.dart';
import '../services/vehicle_service.dart';
import '../utils/validators.dart';
import '../utils/vehicle_data.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_text_field.dart';

class AddVehicleScreen extends StatefulWidget {
  const AddVehicleScreen({super.key});

  @override
  State<AddVehicleScreen> createState() => _AddVehicleScreenState();
}

class _AddVehicleScreenState extends State<AddVehicleScreen> {
  final _formKey = GlobalKey<FormState>();
  final _plateController = TextEditingController();
  final _mileageController = TextEditingController();
  String _make = VehicleData.allMakes.first;
  String _model =
      VehicleData.getModelsForMake(VehicleData.allMakes.first).first;
  String _fuel = VehicleData.fuelTypes.first;
  String _color = VehicleData.colors.first;
  int _year = VehicleData.yearRange.first;
  bool _loading = false;

  @override
  void dispose() {
    _plateController.dispose();
    _mileageController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final userId = context.read<AuthProvider>().currentUser?.id;
    if (userId == null) return;

    setState(() => _loading = true);
    try {
      await VehicleService().addVehicle(
        VehicleModel(
          id: '',
          userId: userId,
          make: _make,
          model: _model,
          year: _year,
          plateNumber: _plateController.text.trim(),
          color: _color,
          fuelType: _fuel,
          currentMileage: int.parse(_mileageController.text.trim()),
        ),
      );
      if (!mounted) return;
      Navigator.pop(context);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final models = VehicleData.getModelsForMake(_make);

    return Scaffold(
      appBar: AppBar(title: const Text('Add Vehicle')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              DropdownButtonFormField<String>(
                value: _make,
                items:
                    VehicleData.allMakes
                        .map(
                          (make) =>
                              DropdownMenuItem(value: make, child: Text(make)),
                        )
                        .toList(),
                onChanged: (value) {
                  if (value == null) return;
                  setState(() {
                    _make = value;
                    _model = VehicleData.getModelsForMake(value).first;
                  });
                },
                decoration: const InputDecoration(labelText: 'Make'),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: models.contains(_model) ? _model : models.first,
                items:
                    models
                        .map(
                          (model) => DropdownMenuItem(
                            value: model,
                            child: Text(model),
                          ),
                        )
                        .toList(),
                onChanged: (value) {
                  if (value != null) setState(() => _model = value);
                },
                decoration: const InputDecoration(labelText: 'Model'),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<int>(
                value: _year,
                items:
                    VehicleData.yearRange
                        .map(
                          (year) => DropdownMenuItem(
                            value: year,
                            child: Text('$year'),
                          ),
                        )
                        .toList(),
                onChanged: (value) {
                  if (value != null) setState(() => _year = value);
                },
                decoration: const InputDecoration(labelText: 'Year'),
              ),
              const SizedBox(height: 12),
              CustomTextField(
                controller: _plateController,
                label: 'Plate Number',
                validator: Validators.plateNumber,
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: _fuel,
                items:
                    VehicleData.fuelTypes
                        .map(
                          (fuel) =>
                              DropdownMenuItem(value: fuel, child: Text(fuel)),
                        )
                        .toList(),
                onChanged: (value) {
                  if (value != null) setState(() => _fuel = value);
                },
                decoration: const InputDecoration(labelText: 'Fuel Type'),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: _color,
                items:
                    VehicleData.colors
                        .map(
                          (color) => DropdownMenuItem(
                            value: color,
                            child: Text(color),
                          ),
                        )
                        .toList(),
                onChanged: (value) {
                  if (value != null) setState(() => _color = value);
                },
                decoration: const InputDecoration(labelText: 'Color'),
              ),
              const SizedBox(height: 12),
              CustomTextField(
                controller: _mileageController,
                label: 'Current Mileage',
                keyboardType: TextInputType.number,
                validator: Validators.mileage,
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: CustomButton(
                  label: 'Save Vehicle',
                  isLoading: _loading,
                  onPressed: _submit,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
