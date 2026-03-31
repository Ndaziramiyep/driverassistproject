import 'package:flutter/material.dart';
import 'package:driverassist/models/service_provider_model.dart';

class ServiceProviderCard extends StatelessWidget {
  final ServiceProviderModel provider;
  final VoidCallback? onTap;
  final VoidCallback? onCall;

  const ServiceProviderCard({
    super.key,
    required this.provider,
    this.onTap,
    this.onCall,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              _buildIcon(theme),
              const SizedBox(width: 12),
              Expanded(child: _buildInfo(theme)),
              if (onCall != null)
                IconButton(
                  icon: const Icon(Icons.phone),
                  onPressed: onCall,
                  color: theme.colorScheme.primary,
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildIcon(ThemeData theme) {
    return Container(
      width: 52,
      height: 52,
      decoration: BoxDecoration(
        color: theme.colorScheme.secondaryContainer,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(
        _iconForType(provider.type),
        color: theme.colorScheme.onSecondaryContainer,
        size: 28,
      ),
    );
  }

  Widget _buildInfo(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          provider.name,
          style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 2),
        Text(
          provider.type,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.primary,
          ),
        ),
        const SizedBox(height: 4),
        Row(
          children: [
            Icon(Icons.star, size: 14, color: Colors.amber),
            const SizedBox(width: 2),
            Text(
              provider.rating.toStringAsFixed(1),
              style: theme.textTheme.bodySmall,
            ),
            const SizedBox(width: 8),
            if (provider.distance != null) ...[
              Icon(Icons.location_on, size: 14,
                  color: theme.colorScheme.onSurfaceVariant),
              const SizedBox(width: 2),
              Text(
                '${provider.distance!.toStringAsFixed(1)} km',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ],
        ),
      ],
    );
  }

  IconData _iconForType(String type) {
    switch (type.toLowerCase()) {
      case 'gas station':
      case 'fuel':
        return Icons.local_gas_station;
      case 'mechanic':
      case 'repair':
        return Icons.build;
      case 'car wash':
        return Icons.local_car_wash;
      case 'parking':
        return Icons.local_parking;
      case 'hospital':
      case 'medical':
        return Icons.local_hospital;
      case 'police':
        return Icons.local_police;
      default:
        return Icons.store;
    }
  }
}
