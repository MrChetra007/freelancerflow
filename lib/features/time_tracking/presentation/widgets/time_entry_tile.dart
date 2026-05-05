import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/utils/duration_formatter.dart';
import '../../domain/time_entry.dart';

class TimeEntryTile extends StatelessWidget {
  final TimeEntry entry;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final String? projectName;

  const TimeEntryTile({
    super.key,
    required this.entry,
    this.onTap,
    this.onEdit,
    this.onDelete,
    this.projectName,
  });

  @override
  Widget build(BuildContext context) {
    final isRunning = entry.isRunning;

    return ListTile(
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: isRunning
              ? AppColors.timerRunning.withValues(alpha: 0.1)
              : Theme.of(context).dividerColor.withValues(alpha: 0.3),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          Icons.timer_outlined,
          color: isRunning ? AppColors.timerRunning : AppColors.timerStopped,
          size: 20,
        ),
      ),
      title: Text(
        entry.description ?? projectName ?? 'No description',
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (projectName != null && entry.description != null)
            Text(
              projectName!,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.secondary,
                  ),
            ),
          Text(
            '${formatDuration(entry.duration)} • ${CurrencyFormatter.format(entry.billableAmount, 'USD')}',
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (entry.isBilled)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: AppColors.success.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                'Billed',
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: AppColors.success,
                    ),
              ),
            )
          else if (entry.isBillable)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: AppColors.warning.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                'Unbilled',
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: AppColors.warning,
                    ),
              ),
            ),
          if (onEdit != null || onDelete != null) ...[
            PopupMenuButton<String>(
              icon: const Icon(Icons.more_vert, size: 20),
              onSelected: (value) {
                if (value == 'edit' && onEdit != null) onEdit!();
                if (value == 'delete' && onDelete != null) onDelete!();
              },
              itemBuilder: (_) => [
                if (onEdit != null)
                  const PopupMenuItem(value: 'edit', child: Text('Edit')),
                if (onDelete != null)
                  const PopupMenuItem(
                    value: 'delete',
                    child: Text('Delete', style: TextStyle(color: AppColors.error)),
                  ),
              ],
            ),
          ],
        ],
      ),
      onTap: onTap,
    );
  }
}
