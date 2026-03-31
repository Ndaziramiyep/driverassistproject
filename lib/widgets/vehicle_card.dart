import 'package:flutter/material.dart';
import 'package:driverassist/models/vehicle_model.dart';

class VehicleCard extends StatelessWidget {
  final VehicleModel vehicle;
  final bool isSelected;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const VehicleCard({
    super.key,
    required this.vehicle,
    this.isSelected = false,
    this.onTap,
    this.onEdit,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      elevation: isSelected ? 4 : 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side:
            isSelected
                ? BorderSide(color: theme.colorScheme.primary, width: 2)
                : BorderSide.none,
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              _buildVehicleIcon(theme),
              const SizedBox(width: 16),
              Expanded(child: _buildVehicleInfo(theme)),
              _buildActions(theme),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildVehicleIcon(ThemeData theme) {
    return Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        color: theme.colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(8),
      ),
      child:
          vehicle.imageUrl != null
              ? ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  vehicle.imageUrl!,
                  fit: BoxFit.cover,
                  errorBuilder:
                      (_, __, ___) => Icon(
                        Icons.directions_car,
                        color: theme.colorScheme.onPrimaryContainer,
                        size: 32,
                      ),
                ),
              )
              : Icon(
                Icons.directions_car,
                color: theme.colorScheme.onPrimaryContainer,
                size: 32,
              ),
    );
  }

  Widget _buildVehicleInfo(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                '${vehicle.year} ${vehicle.make} ${vehicle.model}',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          vehicle.plateNumber,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 4),
        Row(
          children: [
            Icon(
              Icons.local_gas_station,
              size: 14,
              color: theme.colorScheme.onSurfaceVariant,
            ),
            const SizedBox(width: 4),
            Text(
              vehicle.fuelType,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(width: 12),
            Icon(
              Icons.speed,
              size: 14,
              color: theme.colorScheme.onSurfaceVariant,
            ),
            const SizedBox(width: 4),
            Text(
              '${vehicle.currentMileage} km',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActions(ThemeData theme) {
    if (onEdit == null && onDelete == null) return const SizedBox.shrink();
    return PopupMenuButton<String>(
      onSelected: (value) {
        if (value == 'edit') onEdit?.call();
        if (value == 'delete') onDelete?.call();
      },
      itemBuilder:
          (_) => [
            if (onEdit != null)
              const PopupMenuItem(value: 'edit', child: Text('Edit')),
            if (onDelete != null)
              const PopupMenuItem(value: 'delete', child: Text('Delete')),
          ],
    );
  }
}
