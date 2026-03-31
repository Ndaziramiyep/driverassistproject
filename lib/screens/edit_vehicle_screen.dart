import 'package:flutter/material.dart';

import '../models/vehicle_model.dart';
import '../services/vehicle_service.dart';
import '../utils/validators.dart';
import '../utils/vehicle_data.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_text_field.dart';

class EditVehicleScreen extends StatefulWidget {
  const EditVehicleScreen({super.key});

  @override
  State<EditVehicleScreen> createState() => _EditVehicleScreenState();
}

class _EditVehicleScreenState extends State<EditVehicleScreen> {
  final _formKey = GlobalKey<FormState>();
  final _plateController = TextEditingController();
  final _mileageController = TextEditingController();
  bool _loading = false;

  String _make = VehicleData.allMakes.first;
  String _model =
      VehicleData.getModelsForMake(VehicleData.allMakes.first).first;
  String _fuel = VehicleData.fuelTypes.first;
  String _color = VehicleData.colors.first;
  int _year = VehicleData.yearRange.first;
  VehicleModel? _vehicle;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is VehicleModel && _vehicle == null) {
      _vehicle = args;
      _make = args.make;
      _model = args.model;
      _fuel = args.fuelType;
      _color = args.color ?? VehicleData.colors.first;
      _year = args.year;
      _plateController.text = args.plateNumber;
      _mileageController.text = args.currentMileage.toString();
    }
  }

  @override
  void dispose() {
    _plateController.dispose();
    _mileageController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate() || _vehicle == null) return;
    setState(() => _loading = true);
    try {
      await VehicleService().updateVehicle(
        _vehicle!.copyWith(
          make: _make,
          model: _model,
          year: _year,
          plateNumber: _plateController.text.trim(),
          fuelType: _fuel,
          color: _color,
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
    if (_vehicle == null) {
      return const Scaffold(body: Center(child: Text('Vehicle not found.')));
    }

    final models = VehicleData.getModelsForMake(_make);

    return Scaffold(
      appBar: AppBar(title: const Text('Edit Vehicle')),
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
                  label: 'Update Vehicle',
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
