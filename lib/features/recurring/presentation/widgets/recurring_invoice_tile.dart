import 'package:flutter/material.dart';

import '../../../../core/utils/date_formatter.dart';
import '../../domain/recurrence_frequency.dart';
import '../../domain/recurring_invoice.dart';

class RecurringInvoiceTile extends StatelessWidget {
  final RecurringInvoice invoice;
  final VoidCallback? onToggle;
  final VoidCallback? onTap;
  final VoidCallback? onDelete;

  const RecurringInvoiceTile({
    super.key,
    required this.invoice,
    this.onToggle,
    this.onTap,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: invoice.isActive
              ? Theme.of(context).primaryColor.withValues(alpha: 0.1)
              : Theme.of(context).dividerColor.withValues(alpha: 0.3),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          Icons.repeat,
          color: invoice.isActive
              ? Theme.of(context).primaryColor
              : Theme.of(context).textTheme.bodySmall?.color,
          size: 20,
        ),
      ),
      title: Text(
        'Recurring Invoice',
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Text(
        '$_frequencyLabel • Next: ${DateFormatter.formatDate(invoice.nextIssueDate)}',
        style: Theme.of(context).textTheme.bodySmall,
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Switch(
            value: invoice.isActive,
            onChanged: (_) => onToggle?.call(),
          ),
          if (onDelete != null)
            PopupMenuButton<String>(
              icon: const Icon(Icons.more_vert, size: 20),
              onSelected: (value) {
                if (value == 'delete') onDelete?.call();
              },
              itemBuilder: (_) => [
                const PopupMenuItem(
                  value: 'delete',
                  child: Text('Delete', style: TextStyle(color: Colors.red)),
                ),
              ],
            ),
        ],
      ),
      onTap: onTap,
    );
  }

  String get _frequencyLabel => switch (invoice.frequency) {
    RecurrenceFrequency.weekly => 'Weekly',
    RecurrenceFrequency.biweekly => 'Bi-weekly',
    RecurrenceFrequency.monthly => 'Monthly',
    RecurrenceFrequency.quarterly => 'Quarterly',
    RecurrenceFrequency.yearly => 'Yearly',
  };
}
