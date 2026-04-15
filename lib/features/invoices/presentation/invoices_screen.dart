import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/animated_list_item.dart';
import '../../../../core/utils/haptic_utils.dart';
import '../data/invoices_provider.dart';
import '../domain/invoice.dart';
import 'widgets/invoice_card.dart';

class InvoicesScreen extends ConsumerWidget {
  const InvoicesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final invoices = ref.watch(filteredInvoicesProvider);
    final filter = ref.watch(invoiceStatusFilterProvider);

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
          if (filter != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  Chip(
                    label: Text(_getStatusLabel(filter)),
                    deleteIcon: const Icon(Icons.close, size: 18),
                    onDeleted: () =>
                        ref.read(invoiceStatusFilterProvider.notifier).state =
                            null,
                  ),
                ],
              ),
            ),
          Expanded(
            child: invoices.when(
              data: (list) {
                if (list.isEmpty) {
                  return _buildEmptyState(context, filter != null);
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
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('Error: $e')),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          HapticUtils.mediumImpact();
          context.push('/invoices/create');
        },
        icon: const Icon(Icons.add),
        label: const Text('Create Invoice'),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, bool isFiltered) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            isFiltered ? Icons.filter_list_off : Icons.receipt_long_outlined,
            size: 64,
            color: AppColors.lightTextSecondary,
          ),
          const SizedBox(height: 16),
          Text(
            isFiltered ? 'No invoices match filter' : 'No invoices yet',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          Text(
            isFiltered ? 'Try a different filter' : 'Create your first invoice',
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
