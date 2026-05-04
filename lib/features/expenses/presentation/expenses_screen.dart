import 'package:client_manager/features/expenses/domain/expense_category.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../data/expense_provider.dart';
import 'add_expense_screen.dart';
import 'widgets/expense_breakdown_chart.dart';
import 'widgets/expense_tile.dart';

final selectedCategoryFilterProvider = StateProvider<ExpenseCategory?>(
  (ref) => null,
);

class ExpensesScreen extends ConsumerWidget {
  const ExpensesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedCategory = ref.watch(selectedCategoryFilterProvider);
    final expensesAsync = ref.watch(
      expensesProvider(category: selectedCategory),
    );
    final breakdownAsync = ref.watch(expenseBreakdownProvider(6));

    return Scaffold(
      appBar: AppBar(title: const Text('Expenses')),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(expensesProvider);
          ref.invalidate(expenseBreakdownProvider);
        },
        child: CustomScrollView(
          slivers: [
            // Monthly total + chart
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: breakdownAsync.when(
                  data: (data) => ExpenseBreakdownChart(data: data),
                  loading: () => const SizedBox(
                    height: 200,
                    child: Center(child: CircularProgressIndicator()),
                  ),
                  error: (_, __) => const SizedBox.shrink(),
                ),
              ),
            ),

            // Filter tabs
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      FilterChip(
                        selected: selectedCategory == null,
                        onSelected: (_) {
                          ref
                                  .read(selectedCategoryFilterProvider.notifier)
                                  .state =
                              null;
                        },
                        label: const Text('All'),
                        showCheckmark: true,
                        avatar: const Icon(Icons.filter_list, size: 18),
                      ),
                      const SizedBox(width: 8),
                      ...ExpenseCategory.values.map((cat) {
                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: FilterChip(
                            selected: selectedCategory == cat,
                            onSelected: (_) {
                              ref
                                  .read(selectedCategoryFilterProvider.notifier)
                                  .state = selectedCategory == cat
                                  ? null
                                  : cat;
                            },
                            label: Text(cat.label),
                            showCheckmark: true,
                            avatar: Icon(cat.icon, size: 18),
                          ),
                        );
                      }),
                    ],
                  ),
                ),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 8)),

            // Expenses list
            expensesAsync.when(
              data: (expenses) {
                if (expenses.isEmpty) {
                  return const SliverFillRemaining(
                    child: Center(child: Text('No expenses yet')),
                  );
                }
                return SliverList(
                  delegate: SliverChildBuilderDelegate((context, index) {
                    final expense = expenses[index];
                    return ExpenseTile(
                      expense: expense,
                      onDelete: () {
                        _showDeleteConfirmation(context, ref, expense);
                      },
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => AddExpenseScreen(expense: expense),
                          ),
                        );
                      },
                    );
                  }, childCount: expenses.length),
                );
              },
              loading: () => const SliverFillRemaining(
                child: Center(child: CircularProgressIndicator()),
              ),
              error: (_, __) => const SliverFillRemaining(
                child: Center(child: Text('Error loading expenses')),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.of(
            context,
          ).push(MaterialPageRoute(builder: (_) => const AddExpenseScreen()));
        },
        icon: const Icon(Icons.add),
        label: const Text('Add Expense'),
      ),
    );
  }

  void _showDeleteConfirmation(
    BuildContext context,
    WidgetRef ref,
    dynamic expense,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Expense'),
        content: const Text('Are you sure you want to delete this expense?'),
        actions: [
          TextButton(
            onPressed: () => context.pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              context.pop();
              _deleteExpense(context, ref, expense);
            },
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteExpense(
    BuildContext context,
    WidgetRef ref,
    dynamic expense,
  ) async {
    final repo = ref.read(expenseRepositoryProvider);
    await repo.delete(expense.id);
    if (context.mounted) {
      ref.invalidate(expensesProvider);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Expense deleted')));
    }
  }
}
