import 'package:flutter/material.dart';
import 'package:driverassist/models/maintenance_model.dart';

class MaintenanceCard extends StatelessWidget {
  final MaintenanceModel maintenance;
  final VoidCallback? onTap;
  final VoidCallback? onDelete;

  const MaintenanceCard({
    super.key,
    required this.maintenance,
    this.onTap,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isOverdue = maintenance.dueDate != null &&
        maintenance.dueDate!.isBefore(DateTime.now()) &&
        !maintenance.isCompleted;

    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              _buildStatusIcon(theme, isOverdue),
              const SizedBox(width: 16),
              Expanded(child: _buildInfo(theme, isOverdue)),
              if (onDelete != null)
                IconButton(
                  icon: const Icon(Icons.delete_outline),
                  onPressed: onDelete,
                  color: theme.colorScheme.error,
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusIcon(ThemeData theme, bool isOverdue) {
    Color iconColor;
    IconData iconData;
    if (maintenance.isCompleted) {
      iconColor = Colors.green;
      iconData = Icons.check_circle_outline;
    } else if (isOverdue) {
      iconColor = theme.colorScheme.error;
      iconData = Icons.warning_amber_outlined;
    } else {
      iconColor = theme.colorScheme.primary;
      iconData = Icons.build_outlined;
    }

    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: iconColor.withValues(alpha: 0.1),
        shape: BoxShape.circle,
      ),
      child: Icon(iconData, color: iconColor, size: 24),
    );
  }

  Widget _buildInfo(ThemeData theme, bool isOverdue) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          maintenance.title,
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        if (maintenance.description != null &&
            maintenance.description!.isNotEmpty)
          Text(
            maintenance.description!,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        const SizedBox(height: 4),
        Row(
          children: [
            if (maintenance.dueDate != null) ...[
              Icon(
                Icons.calendar_today,
                size: 12,
                color: isOverdue
                    ? theme.colorScheme.error
                    : theme.colorScheme.onSurfaceVariant,
              ),
              const SizedBox(width: 4),
              Text(
                _formatDate(maintenance.dueDate!),
                style: theme.textTheme.bodySmall?.copyWith(
                  color: isOverdue
                      ? theme.colorScheme.error
                      : theme.colorScheme.onSurfaceVariant,
                  fontWeight: isOverdue ? FontWeight.bold : null,
                ),
              ),
            ],
          ],
        ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
