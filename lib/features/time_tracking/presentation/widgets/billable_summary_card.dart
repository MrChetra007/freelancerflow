import 'package:flutter/material.dart';

import '../../../../core/utils/currency_formatter.dart';
import '../../domain/time_entry.dart';

class BillableSummaryCard extends StatelessWidget {
  final List<TimeEntry> entries;

  const BillableSummaryCard({super.key, required this.entries});

  @override
  Widget build(BuildContext context) {
    final totalHours = entries.fold<double>(
        0, (sum, e) => sum + e.duration.inSeconds / 3600);
    final billableAmount = entries.fold<double>(
        0, (sum, e) => sum + e.billableAmount);
    final unbilledAmount = entries
        .where((e) => e.isBillable && !e.isBilled)
        .fold<double>(0, (sum, e) => sum + e.billableAmount);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Theme.of(context).dividerColor),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _SummaryItem(
            label: 'Total Hours',
            value: '${totalHours.toStringAsFixed(1)}h',
          ),
          _SummaryItem(
            label: 'Billable',
            value: CurrencyFormatter.format(billableAmount, 'USD'),
          ),
          _SummaryItem(
            label: 'Unbilled',
            value: CurrencyFormatter.format(unbilledAmount, 'USD'),
            highlight: true,
          ),
        ],
      ),
    );
  }
}

class _SummaryItem extends StatelessWidget {
  final String label;
  final String value;
  final bool highlight;

  const _SummaryItem({
    required this.label,
    required this.value,
    this.highlight = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: highlight ? Theme.of(context).primaryColor : null,
              ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }
}
