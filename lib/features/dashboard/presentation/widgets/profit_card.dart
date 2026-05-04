import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../data/dashboard_provider.dart';

class ProfitCard extends StatelessWidget {
  final DashboardStats stats;

  const ProfitCard({super.key, required this.stats});

  @override
  Widget build(BuildContext context) {
    final isProfit = stats.profitThisMonth >= 0;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).dividerColor,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                isProfit ? Icons.trending_up : Icons.trending_down,
                color: isProfit ? AppColors.success : AppColors.error,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Net Profit',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).textTheme.bodySmall?.color?.withValues(alpha: 0.7),
                    ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            CurrencyFormatter.format(stats.profitThisMonth, 'USD'),
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: isProfit ? AppColors.success : AppColors.error,
                ),
          ),
          const SizedBox(height: 4),
          Text(
            'Revenue: ${CurrencyFormatter.format(stats.monthlyEarnings, 'USD')} • Expenses: ${CurrencyFormatter.format(stats.expensesThisMonth, 'USD')}',
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    );
  }
}
