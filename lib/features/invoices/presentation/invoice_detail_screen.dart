import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../../core/utils/pdf_generator.dart';
import '../../../../core/widgets/loading_widget.dart';
import '../../../../features/settings/data/premium_provider.dart';
import 'package:client_manager/features/clients/data/clients_provider.dart';
import '../data/invoices_provider.dart';
import '../domain/invoice.dart';
import '../domain/invoice_item.dart';

class InvoiceDetailScreen extends ConsumerStatefulWidget {
  final String invoiceId;

  const InvoiceDetailScreen({super.key, required this.invoiceId});

  @override
  ConsumerState<InvoiceDetailScreen> createState() =>
      _InvoiceDetailScreenState();
}

class _InvoiceDetailScreenState extends ConsumerState<InvoiceDetailScreen> {
  Invoice? _invoice;
  List<InvoiceItem> _items = [];
  dynamic _client;
  bool _isLoading = true;
  bool _isGeneratingPdf = false;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final repo = ref.read(invoiceRepositoryProvider);
      final invoice = await repo.getInvoice(widget.invoiceId);
      final items = await repo.getInvoiceItems(widget.invoiceId);
      final clients = await ref.read(clientsProvider.future);
      final client = clients.firstWhere(
        (c) => c.id == invoice?.clientId,
        orElse: () => throw Exception('Client not found'),
      );

      if (mounted && invoice != null) {
        setState(() {
          _invoice = invoice;
          _items = items;
          _client = client;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error loading invoice: $e')));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _generateAndSharePdf() async {
    if (!mounted) return;
    final isPremium = ref.read(isPremiumProvider);
    if (!isPremium) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('PDF generation requires Pro')),
      );
      return;
    }

    if (_invoice == null || _client == null) return;

    setState(() => _isGeneratingPdf = true);

    try {
      final pdfBytes = await PdfGenerator.generateInvoicePdf(
        invoice: _invoice!,
        items: _items,
        client: _client,
      );

      await PdfGenerator.sharePdf(
        pdfBytes: pdfBytes,
        fileName: _invoice!.invoiceNumber,
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error generating PDF: $e')));
      }
    } finally {
      if (mounted) setState(() => _isGeneratingPdf = false);
    }
  }

  Future<void> _printPdf() async {
    if (!mounted) return;
    final isPremium = ref.read(isPremiumProvider);
    if (!isPremium) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('PDF printing requires Pro')),
      );
      return;
    }

    if (_invoice == null || _client == null) return;

    setState(() => _isGeneratingPdf = true);

    try {
      final pdfBytes = await PdfGenerator.generateInvoicePdf(
        invoice: _invoice!,
        items: _items,
        client: _client,
      );

      await PdfGenerator.printPdf(pdfBytes);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error printing PDF: $e')));
      }
    } finally {
      if (mounted) setState(() => _isGeneratingPdf = false);
    }
  }

  Future<void> _updateStatus(InvoiceStatus newStatus) async {
    if (_invoice == null) return;

    try {
      final updated = _invoice!.copyWith(
        status: newStatus,
        sentAt: newStatus == InvoiceStatus.sent
            ? DateTime.now()
            : _invoice!.sentAt,
        paidAt: newStatus == InvoiceStatus.paid
            ? DateTime.now()
            : _invoice!.paidAt,
      );
      await ref.read(invoicesProvider.notifier).updateInvoice(updated);
      await _loadData();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text('Invoice')),
        body: const _InvoiceDetailShimmer(),
      );
    }

    if (_invoice == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Invoice')),
        body: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.receipt_long_outlined, size: 64, color: Colors.grey),
              SizedBox(height: 16),
              Text('Invoice not found'),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        title: Text(_invoice!.invoiceNumber),
        actions: [
          if (_isGeneratingPdf)
            const Padding(
              padding: EdgeInsets.all(16),
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            )
            else ...[
              IconButton(
                icon: const Icon(Icons.print),
                onPressed: _isGeneratingPdf ? null : () => _printPdf(),
                tooltip: 'Print',
              ),
              IconButton(
                icon: const Icon(Icons.share),
                onPressed: _isGeneratingPdf ? null : () => _generateAndSharePdf(),
                tooltip: 'Share PDF',
              ),
            PopupMenuButton<InvoiceStatus>(
              icon: const Icon(Icons.more_vert),
              onSelected: _updateStatus,
              itemBuilder: (context) => [
                if (_invoice!.status != InvoiceStatus.draft)
                  const PopupMenuItem(
                    value: InvoiceStatus.draft,
                    child: Text('Mark as Draft'),
                  ),
                if (_invoice!.status != InvoiceStatus.sent)
                  const PopupMenuItem(
                    value: InvoiceStatus.sent,
                    child: Text('Mark as Sent'),
                  ),
                if (_invoice!.status != InvoiceStatus.paid)
                  const PopupMenuItem(
                    value: InvoiceStatus.paid,
                    child: Text('Mark as Paid'),
                  ),
                if (_invoice!.status != InvoiceStatus.cancelled)
                  const PopupMenuItem(
                    value: InvoiceStatus.cancelled,
                    child: Text('Cancel Invoice'),
                  ),
              ],
            ),
          ],
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildStatusCard(),
          const SizedBox(height: 16),
          _buildClientCard(),
          const SizedBox(height: 16),
          _buildDatesCard(),
          const SizedBox(height: 16),
          _buildLineItemsCard(),
          const SizedBox(height: 16),
          _buildTotalsCard(),
          if (_invoice!.notes != null && _invoice!.notes!.isNotEmpty) ...[
            const SizedBox(height: 16),
            _buildNotesCard(),
          ],
        ],
      ),
    );
  }

  Widget _buildStatusCard() {
    final status = _invoice!.status;
    final (color, label) = switch (status) {
      InvoiceStatus.draft => (AppColors.lightTextSecondary, 'Draft'),
      InvoiceStatus.sent => (AppColors.info, 'Sent'),
      InvoiceStatus.paid => (AppColors.statusPaid, 'Paid'),
      InvoiceStatus.overdue => (AppColors.statusOverdue, 'Overdue'),
      InvoiceStatus.cancelled => (AppColors.error, 'Cancelled'),
    };

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            ),
            const SizedBox(width: 12),
            Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: color,
                fontSize: 16,
              ),
            ),
            const Spacer(),
            Text(
              CurrencyFormatter.format(_invoice!.total, _invoice!.currency),
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.primary500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildClientCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundColor: AppColors.primary50,
                  child: Text(
                    (_client?.name ?? '?')[0].toUpperCase(),
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary600,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _client?.name ?? 'Unknown',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      if (_client?.company != null)
                        Text(
                          _client!.company!,
                          style: TextStyle(
                            color: AppColors.lightTextSecondary,
                            fontSize: 13,
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
            if (_client?.email != null) ...[
              const Divider(height: 24),
              Row(
                children: [
                  Icon(Icons.email_outlined,
                      size: 16, color: AppColors.lightTextSecondary),
                  const SizedBox(width: 8),
                  Text(
                    _client!.email!,
                    style: TextStyle(color: AppColors.lightTextSecondary),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildDatesCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Expanded(
              child: Row(
                children: [
                  Icon(Icons.calendar_today,
                      size: 16, color: AppColors.primary500),
                  const SizedBox(width: 8),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Issue Date',
                        style: TextStyle(
                          color: AppColors.lightTextSecondary,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        DateFormatter.formatDate(_invoice!.issueDate),
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            if (_invoice!.dueDate != null)
              Expanded(
                child: Row(
                  children: [
                    Icon(Icons.event,
                        size: 16, color: AppColors.statusOverdue),
                    const SizedBox(width: 8),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Due Date',
                          style: TextStyle(
                            color: AppColors.lightTextSecondary,
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          DateFormatter.formatDate(_invoice!.dueDate!),
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildLineItemsCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Items',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const Divider(height: 20),
            ...List.generate(_items.length, (index) {
              final item = _items[index];
              final isLast = index == _items.length - 1;
              return Column(
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 3,
                        height: 48,
                        decoration: BoxDecoration(
                          color: AppColors.primary200,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item.description,
                              style: const TextStyle(
                                fontWeight: FontWeight.w500,
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${item.quantity} x ${CurrencyFormatter.format(item.unitPrice, _invoice!.currency)}',
                              style: TextStyle(
                                color: AppColors.lightTextSecondary,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Text(
                        CurrencyFormatter.format(
                            item.total, _invoice!.currency),
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                  if (!isLast) const SizedBox(height: 12),
                  if (!isLast) const Divider(height: 1),
                  if (!isLast) const SizedBox(height: 12),
                ],
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildTotalsCard() {
    return Card(
      color: AppColors.primary500.withValues(alpha: 0.03),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildTotalRow('Subtotal', _invoice!.subtotal),
            if (_invoice!.taxPercent > 0)
              _buildTotalRow(
                'Tax (${_invoice!.taxPercent.toStringAsFixed(0)}%)',
                _invoice!.taxAmount,
              ),
            if (_invoice!.discountPercent > 0)
              _buildTotalRow(
                'Discount (${_invoice!.discountPercent.toStringAsFixed(0)}%)',
                -_invoice!.discountAmount,
              ),
            const Divider(height: 24),
            _buildTotalRow(
              'Total',
              _invoice!.total,
              bold: true,
              color: AppColors.primary500,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTotalRow(
    String label,
    double amount, {
    bool bold = false,
    Color? color,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontWeight: bold ? FontWeight.bold : FontWeight.normal,
              fontSize: bold ? 16 : 14,
            ),
          ),
          Text(
            CurrencyFormatter.format(amount, _invoice!.currency),
            style: TextStyle(
              fontWeight: bold ? FontWeight.bold : FontWeight.normal,
              fontSize: bold ? 16 : 14,
              color: color ?? (bold ? AppColors.primary500 : null),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotesCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.notes,
                    size: 16, color: AppColors.lightTextSecondary),
                const SizedBox(width: 8),
                Text(
                  'Notes',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: AppColors.lightTextSecondary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(_invoice!.notes!, style: const TextStyle(height: 1.5)),
          ],
        ),
      ),
    );
  }
}

class _InvoiceDetailShimmer extends StatelessWidget {
  const _InvoiceDetailShimmer();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: List.generate(
        4,
        (_) => Padding(
          padding: const EdgeInsets.only(bottom: 16),
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
      ),
    );
  }
}
