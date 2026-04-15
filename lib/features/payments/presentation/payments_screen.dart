import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../data/payments_provider.dart';
import '../domain/payment.dart';
import 'widgets/payment_tile.dart';

class PaymentsScreen extends ConsumerWidget {
  const PaymentsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final payments = ref.watch(filteredPaymentsProvider);
    final filter = ref.watch(paymentStatusFilterProvider);
    final monthlyTotal = ref.watch(monthlyTotalProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Payments'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () => _showFilterOptions(context, ref),
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            margin: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.primary500.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'This Month',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.lightTextSecondary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      CurrencyFormatter.format(monthlyTotal, 'USD'),
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppColors.statusPaid,
                          ),
                    ),
                  ],
                ),
                Icon(Icons.trending_up, color: AppColors.statusPaid, size: 32),
              ],
            ),
          ),
          if (filter != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Chip(
                    label: Text(_getStatusLabel(filter)),
                    deleteIcon: const Icon(Icons.close, size: 18),
                    onDeleted: () =>
                        ref.read(paymentStatusFilterProvider.notifier).state =
                            null,
                  ),
                ],
              ),
            ),
          Expanded(
            child: payments.when(
              data: (list) {
                if (list.isEmpty) {
                  return _buildEmptyState(context, filter != null);
                }
                return RefreshIndicator(
                  onRefresh: () =>
                      ref.read(paymentsProvider.notifier).refresh(),
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: list.length,
                    itemBuilder: (context, index) {
                      final payment = list[index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: PaymentTile(
                          payment: payment,
                          onTap: () =>
                              context.push('/payments/add', extra: payment.id),
                          onDelete: () => _confirmDelete(context, ref, payment),
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
        onPressed: () => context.push('/payments/add'),
        icon: const Icon(Icons.add),
        label: const Text('Add Payment'),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, bool isFiltered) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            isFiltered ? Icons.filter_list_off : Icons.payments_outlined,
            size: 64,
            color: AppColors.lightTextSecondary,
          ),
          const SizedBox(height: 16),
          Text(
            isFiltered ? 'No payments match filter' : 'No payments yet',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          Text(
            isFiltered ? 'Try a different filter' : 'Log your first payment',
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
                ref.read(paymentStatusFilterProvider.notifier).state = null;
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: Icon(
                Icons.check_circle_outline,
                color: AppColors.statusPaid,
              ),
              title: const Text('Paid'),
              onTap: () {
                ref.read(paymentStatusFilterProvider.notifier).state =
                    PaymentStatus.paid;
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: Icon(Icons.schedule, color: AppColors.statusUnpaid),
              title: const Text('Unpaid'),
              onTap: () {
                ref.read(paymentStatusFilterProvider.notifier).state =
                    PaymentStatus.unpaid;
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: Icon(
                Icons.warning_outlined,
                color: AppColors.statusOverdue,
              ),
              title: const Text('Overdue'),
              onTap: () {
                ref.read(paymentStatusFilterProvider.notifier).state =
                    PaymentStatus.overdue;
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: Icon(Icons.percent, color: AppColors.statusPartial),
              title: const Text('Partial'),
              onTap: () {
                ref.read(paymentStatusFilterProvider.notifier).state =
                    PaymentStatus.partial;
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  String _getStatusLabel(PaymentStatus status) {
    return switch (status) {
      PaymentStatus.paid => 'Paid',
      PaymentStatus.unpaid => 'Unpaid',
      PaymentStatus.partial => 'Partial',
      PaymentStatus.overdue => 'Overdue',
      PaymentStatus.refunded => 'Refunded',
    };
  }

  void _confirmDelete(BuildContext context, WidgetRef ref, Payment payment) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Payment?'),
        content: Text('Are you sure you want to delete this payment?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              ref.read(paymentsProvider.notifier).deletePayment(payment.id!);
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
