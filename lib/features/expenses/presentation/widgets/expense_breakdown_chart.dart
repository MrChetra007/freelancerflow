import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

import '../../../../core/theme/app_colors.dart';
import '../../domain/expense_category.dart';

class ExpenseBreakdownChart extends StatelessWidget {
  final List<Map<String, dynamic>> data; // [{category, total, entry_count}]

  const ExpenseBreakdownChart({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    if (data.isEmpty) {
      return const SizedBox.shrink();
    }

    final total = data.fold<double>(0, (sum, e) => sum + (e['total'] as num).toDouble());

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Theme.of(context).dividerColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Expenses by Category',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 200,
            child: Row(
              children: [
                Expanded(
                  flex: 2,
                  child: PieChart(
                    PieChartData(
                      sections: _buildSections(),
                      centerSpaceRadius: 40,
                      sectionsSpace: 2,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: data.map((e) {
                      final category = _getCategory(e['category']);
                      final percentage = total > 0
                          ? ((e['total'] as num).toDouble() / total * 100)
                              .toStringAsFixed(1)
                          : '0';
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Row(
                          children: [
                            Container(
                              width: 12,
                              height: 12,
                              decoration: BoxDecoration(
                                color: category.color,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                '${category.label} ($percentage%)',
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  List<PieChartSectionData> _buildSections() {
    final colors = <Color>[
      AppColors.expenseSoftware,
      AppColors.expenseTravel,
      AppColors.expenseHardware,
      AppColors.expenseOther,
      AppColors.warning,
      AppColors.success,
      AppColors.error,
      AppColors.info,
    ];

    return data.asMap().entries.map((entry) {
      final index = entry.key;
      final item = entry.value;
      final total = data.fold<double>(0, (sum, e) => sum + (e['total'] as num).toDouble());
      final percentage = total > 0
          ? (item['total'] as num).toDouble() / total * 100
          : 0;

      return PieChartSectionData(
        color: colors[index % colors.length],
        value: (item['total'] as num).toDouble(),
        title: '${percentage.toStringAsFixed(1)}%',
        radius: 60,
        titleStyle: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      );
    }).toList();
  }

  ExpenseCategory _getCategory(String name) {
    return ExpenseCategory.values.firstWhere(
      (c) => c.name == name,
      orElse: () => ExpenseCategory.other,
    );
  }
}
