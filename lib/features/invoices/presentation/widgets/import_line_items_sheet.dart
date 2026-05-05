import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/duration_formatter.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../time_tracking/data/time_entry_provider.dart';
import '../../../time_tracking/domain/time_entry.dart';
import '../../../expenses/data/expense_provider.dart';

class ImportLineItemsSheet extends ConsumerStatefulWidget {
  final String clientId;
  final String? projectId;

  const ImportLineItemsSheet({
    super.key,
    required this.clientId,
    this.projectId,
  });

  @override
  ConsumerState<ImportLineItemsSheet> createState() =>
      _ImportLineItemsSheetState();
}

class _ImportLineItemsSheetState extends ConsumerState<ImportLineItemsSheet>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final Set<String> _selectedTimeEntryIds = {};
  final Set<String> _selectedExpenseIds = {};

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.75,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            child: Row(
              children: [
                Text(
                  'Import Line Items',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),
          TabBar(
            controller: _tabController,
            tabs: const [
              Tab(text: 'Time Entries'),
              Tab(text: 'Expenses'),
            ],
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _TimeEntriesTab(
                  clientId: widget.clientId,
                  selectedIds: _selectedTimeEntryIds,
                  onSelectionChanged: (ids) {
                    setState(() => _selectedTimeEntryIds.clear());
                    setState(() => _selectedTimeEntryIds.addAll(ids));
                  },
                ),
                _ExpensesTab(
                  clientId: widget.clientId,
                  selectedIds: _selectedExpenseIds,
                  onSelectionChanged: (ids) {
                    setState(() => _selectedExpenseIds.clear());
                    setState(() => _selectedExpenseIds.addAll(ids));
                  },
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.all(16),
            child: SizedBox(
              width: double.infinity,
              child: Consumer(
                builder: (context, ref, child) {
                  final totalSelected =
                      _selectedTimeEntryIds.length + _selectedExpenseIds.length;
                  return FilledButton(
                    onPressed: totalSelected == 0
                        ? null
                        : () {
                            Navigator.pop(
                              context,
                              ImportResult(
                                timeEntryIds: _selectedTimeEntryIds.toList(),
                                expenseIds: _selectedExpenseIds.toList(),
                              ),
                            );
                          },
                    child: Text('Import $totalSelected item${totalSelected == 1 ? '' : 's'}'),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TimeEntriesTab extends ConsumerWidget {
  final String clientId;
  final Set<String> selectedIds;
  final ValueChanged<Set<String>> onSelectionChanged;

  const _TimeEntriesTab({
    required this.clientId,
    required this.selectedIds,
    required this.onSelectionChanged,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final entriesAsync = ref.watch(unbilledTimeEntriesProvider(clientId));

    return entriesAsync.when(
      data: (entries) {
        if (entries.isEmpty) {
          return const Center(
            child: Text('No unbilled time entries for this client'),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: entries.length,
          itemBuilder: (context, index) {
            final entry = entries[index];
            final isSelected = selectedIds.contains(entry.id);
            return CheckboxListTile(
              value: isSelected,
              onChanged: (_) {
                final newSet = Set<String>.from(selectedIds);
                if (isSelected) {
                  newSet.remove(entry.id);
                } else {
                  if (entry.id != null) newSet.add(entry.id!);
                }
                onSelectionChanged(newSet);
              },
              title: Text(entry.description ?? 'No description'),
              subtitle: Text(
                '${formatDuration(entry.duration)} • ${CurrencyFormatter.format(entry.billableAmount, 'USD')}',
              ),
              secondary: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.primary500.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.timer_outlined,
                  color: AppColors.primary500,
                ),
              ),
              controlAffinity: ListTileControlAffinity.leading,
            );
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Error: $e')),
    );
  }
}

class _ExpensesTab extends ConsumerWidget {
  final String clientId;
  final Set<String> selectedIds;
  final ValueChanged<Set<String>> onSelectionChanged;

  const _ExpensesTab({
    required this.clientId,
    required this.selectedIds,
    required this.onSelectionChanged,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final expensesAsync = ref.watch(unbilledBillableExpensesProvider(clientId));

    return expensesAsync.when(
      data: (expenses) {
        if (expenses.isEmpty) {
          return const Center(
            child: Text('No billable unbilled expenses for this client'),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: expenses.length,
          itemBuilder: (context, index) {
            final expense = expenses[index];
            final isSelected = selectedIds.contains(expense.id);
            return CheckboxListTile(
              value: isSelected,
              onChanged: (_) {
                final newSet = Set<String>.from(selectedIds);
                if (isSelected) {
                  newSet.remove(expense.id);
                } else {
                  if (expense.id != null) newSet.add(expense.id!);
                }
                onSelectionChanged(newSet);
              },
              title: Text(expense.description),
              subtitle: Text(
                '${expense.category.label} • ${CurrencyFormatter.format(expense.amount, expense.currency)}',
              ),
              secondary: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: expense.category.color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  expense.category.icon,
                  color: expense.category.color,
                ),
              ),
              controlAffinity: ListTileControlAffinity.leading,
            );
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Error: $e')),
    );
  }
}

class ImportResult {
  final List<String> timeEntryIds;
  final List<String> expenseIds;

  ImportResult({
    this.timeEntryIds = const [],
    this.expenseIds = const [],
  });
}

Future<ImportResult?> showImportLineItemsSheet(
  BuildContext context, {
  required String clientId,
  String? projectId,
}) {
  return showModalBottomSheet<ImportResult>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    builder: (ctx) => DraggableScrollableSheet(
      initialChildSize: 0.7,
      minChildSize: 0.4,
      maxChildSize: 0.95,
      expand: false,
      builder: (context, scrollController) {
        return ImportLineItemsSheet(
          clientId: clientId,
          projectId: projectId,
        );
      },
    ),
  );
}
