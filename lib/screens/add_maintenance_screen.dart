import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/maintenance_model.dart';
import '../providers/auth_provider.dart';
import '../services/maintenance_service.dart';
import '../utils/constants.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_text_field.dart';

class AddMaintenanceScreen extends StatefulWidget {
  const AddMaintenanceScreen({super.key});

  @override
  State<AddMaintenanceScreen> createState() => _AddMaintenanceScreenState();
}

class _AddMaintenanceScreenState extends State<AddMaintenanceScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _mileageController = TextEditingController();
  DateTime? _dueDate;
  String _priority = AppConstants.priorityMedium;
  bool _loading = false;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _mileageController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final date = await showDatePicker(
      context: context,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 3650)),
      initialDate: DateTime.now().add(const Duration(days: 7)),
    );
    if (date != null) setState(() => _dueDate = date);
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final userId = context.read<AuthProvider>().currentUser?.id;
    if (userId == null) return;

    setState(() => _loading = true);
    try {
      await MaintenanceService().addMaintenance(
        MaintenanceModel(
          id: '',
          vehicleId: 'general',
          userId: userId,
          title: _titleController.text.trim(),
          description:
              _descriptionController.text.trim().isEmpty
                  ? null
                  : _descriptionController.text.trim(),
          dueDate: _dueDate,
          dueMileage: int.tryParse(_mileageController.text.trim()),
          priority: _priority,
          isCompleted: false,
          createdAt: DateTime.now(),
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
    return Scaffold(
      appBar: AppBar(title: const Text('Add Maintenance Reminder')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              CustomTextField(
                controller: _titleController,
                label: 'Title',
                validator:
                    (value) =>
                        value == null || value.trim().isEmpty
                            ? 'Title is required'
                            : null,
              ),
              const SizedBox(height: 12),
              CustomTextField(
                controller: _descriptionController,
                label: 'Description (optional)',
                maxLines: 3,
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: _priority,
                decoration: const InputDecoration(labelText: 'Priority'),
                items: const [
                  DropdownMenuItem(
                    value: AppConstants.priorityLow,
                    child: Text('Low'),
                  ),
                  DropdownMenuItem(
                    value: AppConstants.priorityMedium,
                    child: Text('Medium'),
                  ),
                  DropdownMenuItem(
                    value: AppConstants.priorityHigh,
                    child: Text('High'),
                  ),
                ],
                onChanged: (value) {
                  if (value != null) setState(() => _priority = value);
                },
              ),
              const SizedBox(height: 12),
              CustomTextField(
                controller: _mileageController,
                label: 'Due Mileage (optional)',
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 12),
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(
                  _dueDate == null
                      ? 'Select due date'
                      : 'Due: ${_dueDate!.day}/${_dueDate!.month}/${_dueDate!.year}',
                ),
                trailing: const Icon(Icons.calendar_today),
                onTap: _pickDate,
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: CustomButton(
                  label: 'Save Reminder',
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
