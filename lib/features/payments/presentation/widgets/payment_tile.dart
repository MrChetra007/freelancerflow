import 'package:flutter/material.dart';
import '../../domain/payment.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/utils/date_formatter.dart';

class PaymentTile extends StatelessWidget {
  final Payment payment;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const PaymentTile({
    super.key,
    required this.payment,
    required this.onTap,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: Key(payment.id!),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: AppColors.error,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      confirmDismiss: (_) async {
        onDelete();
        return false;
      },
      child: Card(
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                _StatusIcon(status: payment.status),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (payment.description != null)
                        Text(
                          payment.description!,
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(fontWeight: FontWeight.w600),
                        ),
                      if (payment.referenceNo != null) ...[
                        const SizedBox(height: 2),
                        Text(
                          'Ref: ${payment.referenceNo}',
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(color: AppColors.lightTextSecondary),
                        ),
                      ],
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          if (payment.dueDate != null) ...[
                            Icon(
                              Icons.schedule,
                              size: 12,
                              color: AppColors.lightTextSecondary,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'Due: ${DateFormatter.formatDate(payment.dueDate!)}',
                              style: TextStyle(
                                fontSize: 12,
                                color: AppColors.lightTextSecondary,
                              ),
                            ),
                          ],
                          if (payment.method != null) ...[
                            const SizedBox(width: 12),
                            Icon(
                              Icons.payment,
                              size: 12,
                              color: AppColors.lightTextSecondary,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              _getMethodLabel(payment.method!),
                              style: TextStyle(
                                fontSize: 12,
                                color: AppColors.lightTextSecondary,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      CurrencyFormatter.format(
                        payment.amount,
                        payment.currency,
                      ),
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    _StatusBadge(status: payment.status),
                    if (payment.amountPaid > 0 &&
                        payment.amountPaid < payment.amount) ...[
                      const SizedBox(height: 4),
                      Text(
                        'Paid: ${CurrencyFormatter.format(payment.amountPaid, payment.currency)}',
                        style: TextStyle(
                          fontSize: 11,
                          color: AppColors.statusPartial,
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _getMethodLabel(PaymentMethod method) {
    return switch (method) {
      PaymentMethod.bankTransfer => 'Bank',
      PaymentMethod.paypal => 'PayPal',
      PaymentMethod.wise => 'Wise',
      PaymentMethod.crypto => 'Crypto',
      PaymentMethod.cash => 'Cash',
      PaymentMethod.stripe => 'Stripe',
      PaymentMethod.other => 'Other',
    };
  }
}

class _StatusIcon extends StatelessWidget {
  final PaymentStatus status;

  const _StatusIcon({required this.status});

  @override
  Widget build(BuildContext context) {
    final color = _getColor();
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(_getIcon(), color: color),
    );
  }

  Color _getColor() {
    return switch (status) {
      PaymentStatus.paid => AppColors.statusPaid,
      PaymentStatus.unpaid => AppColors.statusUnpaid,
      PaymentStatus.partial => AppColors.statusPartial,
      PaymentStatus.overdue => AppColors.statusOverdue,
      PaymentStatus.refunded => AppColors.lightTextSecondary,
    };
  }

  IconData _getIcon() {
    return switch (status) {
      PaymentStatus.paid => Icons.check_circle,
      PaymentStatus.unpaid => Icons.schedule,
      PaymentStatus.partial => Icons.percent,
      PaymentStatus.overdue => Icons.warning,
      PaymentStatus.refunded => Icons.replay,
    };
  }
}

class _StatusBadge extends StatelessWidget {
  final PaymentStatus status;

  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    final (color, label) = switch (status) {
      PaymentStatus.paid => (AppColors.statusPaid, 'Paid'),
      PaymentStatus.unpaid => (AppColors.statusUnpaid, 'Unpaid'),
      PaymentStatus.partial => (AppColors.statusPartial, 'Partial'),
      PaymentStatus.overdue => (AppColors.statusOverdue, 'Overdue'),
      PaymentStatus.refunded => (AppColors.lightTextSecondary, 'Refunded'),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w500,
          color: color,
        ),
      ),
    );
  }
}
