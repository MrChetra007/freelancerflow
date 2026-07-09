import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/animated_list_item.dart';
import '../../../../core/widgets/loading_widget.dart';
import '../../../../core/widgets/pro_gate.dart';
import '../../../../core/utils/haptic_utils.dart';
import '../data/invoices_provider.dart';
import '../domain/invoice.dart';
import 'widgets/invoice_card.dart';

class InvoicesScreen extends ConsumerWidget {
  const InvoicesScreen({super.key});

  static const _statusFilters = <InvoiceStatus?>[
    null,
    InvoiceStatus.draft,
    InvoiceStatus.sent,
    InvoiceStatus.paid,
    InvoiceStatus.overdue,
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final invoices = ref.watch(filteredInvoicesProvider);
    final filter = ref.watch(invoiceStatusFilterProvider);
    final searchQuery = ref.watch(invoiceSearchQueryProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Invoices'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () => _showFilterOptions(context, ref),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search invoices...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () =>
                            ref.read(invoiceSearchQueryProvider.notifier).state = '',
                      )
                    : null,
              ),
              onChanged: (value) =>
                  ref.read(invoiceSearchQueryProvider.notifier).state = value,
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 36,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: _statusFilters.map((s) {
                final isActive = filter == s;
                final label = s == null ? 'All' : _getStatusLabel(s);
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    label: Text(label),
                    selected: isActive,
                    onSelected: (_) => ref
                        .read(invoiceStatusFilterProvider.notifier)
                        .state = s,
                    selectedColor: AppColors.primary500.withValues(alpha: 0.15),
                    checkmarkColor: AppColors.primary500,
                    labelStyle: TextStyle(
                      color: isActive ? AppColors.primary500 : null,
                      fontWeight: isActive ? FontWeight.w600 : null,
                    ),
                    side: BorderSide(
                      color: isActive
                          ? AppColors.primary500
                          : AppColors.lightBorder,
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: invoices.when(
              data: (list) {
                if (list.isEmpty) {
                  return _buildEmptyState(
                    context,
                    filter != null || searchQuery.isNotEmpty,
                    searchQuery.isNotEmpty,
                  );
                }
                return RefreshIndicator(
                  onRefresh: () =>
                      ref.read(invoicesProvider.notifier).refresh(),
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: list.length,
                    itemBuilder: (context, index) {
                      final invoice = list[index];
                      return AnimatedListItem(
                        index: index,
                        child: Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: InvoiceCard(
                            invoice: invoice,
                            onTap: () {
                              HapticUtils.lightImpact();
                              context.push('/invoices/${invoice.id}');
                            },
                            onDelete: () =>
                                _confirmDelete(context, ref, invoice),
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
              loading: () => const _InvoiceListShimmer(),
              error: (e, _) => ErrorDisplay(
                message: e.toString(),
                onRetry: () => ref.invalidate(invoicesProvider),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: ProGateButton(
        onPressed: () {
          HapticUtils.mediumImpact();
          context.push('/invoices/create');
        },
        label: 'Create Invoice',
        icon: Icons.add,
      ),
    );
  }

  Widget _buildEmptyState(
      BuildContext context, bool isFiltered, bool isSearching) {
    final isSearchOrFilter = isSearching || isFiltered;
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            isSearchOrFilter
                ? Icons.search_off
                : Icons.receipt_long_outlined,
            size: 64,
            color: AppColors.lightTextSecondary,
          ),
          const SizedBox(height: 16),
          Text(
            isSearchOrFilter ? 'No invoices found' : 'No invoices yet',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          Text(
            isSearchOrFilter
                ? 'Try a different search term'
                : 'Create your first invoice',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.lightTextSecondary,
                ),
          ),
        ],
      ),
    );
  }

  void _showFilterOptions(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.all_inclusive),
              title: const Text('All'),
              onTap: () {
                ref.read(invoiceStatusFilterProvider.notifier).state = null;
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: Icon(
                Icons.edit_note,
                color: AppColors.lightTextSecondary,
              ),
              title: const Text('Draft'),
              onTap: () {
                ref.read(invoiceStatusFilterProvider.notifier).state =
                    InvoiceStatus.draft;
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: Icon(Icons.send, color: AppColors.info),
              title: const Text('Sent'),
              onTap: () {
                ref.read(invoiceStatusFilterProvider.notifier).state =
                    InvoiceStatus.sent;
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: Icon(Icons.check_circle, color: AppColors.statusPaid),
              title: const Text('Paid'),
              onTap: () {
                ref.read(invoiceStatusFilterProvider.notifier).state =
                    InvoiceStatus.paid;
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: Icon(Icons.warning, color: AppColors.statusOverdue),
              title: const Text('Overdue'),
              onTap: () {
                ref.read(invoiceStatusFilterProvider.notifier).state =
                    InvoiceStatus.overdue;
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  String _getStatusLabel(InvoiceStatus status) {
    return switch (status) {
      InvoiceStatus.draft => 'Draft',
      InvoiceStatus.sent => 'Sent',
      InvoiceStatus.paid => 'Paid',
      InvoiceStatus.overdue => 'Overdue',
      InvoiceStatus.cancelled => 'Cancelled',
    };
  }

  void _confirmDelete(BuildContext context, WidgetRef ref, Invoice invoice) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Invoice?'),
        content: Text(
          'Are you sure you want to delete ${invoice.invoiceNumber}?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              ref.read(invoicesProvider.notifier).deleteInvoice(invoice.id!);
              Navigator.pop(context);
            },
            child: const Text(
              'Delete',
              style: TextStyle(color: AppColors.error),
            ),
          ),
        ],
      ),
    );
  }
}

class _InvoiceListShimmer extends StatelessWidget {
  const _InvoiceListShimmer();

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: 5,
      itemBuilder: (context, index) => Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: LoadingShimmer(
          isLoading: true,
          child: Container(
            height: 100,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      ),
    );
  }
}
