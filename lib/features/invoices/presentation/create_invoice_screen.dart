import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/supabase/supabase_client.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/services/notification_service.dart';
import 'package:client_manager/features/clients/data/clients_provider.dart';
import 'package:client_manager/features/settings/presentation/settings_screen.dart';
import '../data/invoices_provider.dart';
import '../domain/invoice.dart';
import '../domain/invoice_item.dart';

class CreateInvoiceScreen extends ConsumerStatefulWidget {
  final String? invoiceId;

  const CreateInvoiceScreen({super.key, this.invoiceId});

  @override
  ConsumerState<CreateInvoiceScreen> createState() =>
      _CreateInvoiceScreenState();
}

class _CreateInvoiceScreenState extends ConsumerState<CreateInvoiceScreen> {
  final _formKey = GlobalKey<FormState>();
  final _notesController = TextEditingController();
  final _paymentTermsController = TextEditingController(
    text: 'Payment due within 30 days',
  );

  String? _selectedClientId;
  DateTime _issueDate = DateTime.now();
  DateTime? _dueDate;
  double _taxPercent = 0;
  double _discountPercent = 0;
  String _currency = 'USD';
  bool _isLoading = false;

  List<_LineItem> _lineItems = [_LineItem()];
  Invoice? _existingInvoice;
  List<InvoiceItem> _existingItems = [];

  final _currencies = [
    'USD',
    'EUR',
    'GBP',
    'CAD',
    'AUD',
    'JPY',
    'SGD',
    'THB',
    'KHR',
  ];

  bool get isEditing => widget.invoiceId != null;

  @override
  void initState() {
    super.initState();
    if (isEditing) {
      _loadInvoice();
    }
  }

  Future<void> _loadInvoice() async {
    final repo = ref.read(invoiceRepositoryProvider);
    final invoice = await repo.getInvoice(widget.invoiceId!);
    final items = await repo.getInvoiceItems(widget.invoiceId!);

    if (invoice != null && mounted) {
      setState(() {
        _existingInvoice = invoice;
        _selectedClientId = invoice.clientId;
        _issueDate = invoice.issueDate;
        _dueDate = invoice.dueDate;
        _taxPercent = invoice.taxPercent;
        _discountPercent = invoice.discountPercent;
        _currency = invoice.currency;
        _notesController.text = invoice.notes ?? '';
        _paymentTermsController.text = invoice.paymentTerms ?? '';
        _existingItems = items;
        _lineItems = items.isEmpty
            ? [_LineItem()]
            : items
                  .map(
                    (i) => _LineItem(
                      description: i.description,
                      quantity: i.quantity,
                      unitPrice: i.unitPrice,
                    ),
                  )
                  .toList();
      });
    }
  }

  @override
  void dispose() {
    _notesController.dispose();
    _paymentTermsController.dispose();
    for (var item in _lineItems) {
      item.dispose();
    }
    super.dispose();
  }

  double get _subtotal => _lineItems.fold(0, (sum, item) => sum + item.total);
  double get _taxAmount => _subtotal * (_taxPercent / 100);
  double get _discountAmount => _subtotal * (_discountPercent / 100);
  double get _total => _subtotal + _taxAmount - _discountAmount;

  Future<void> _saveInvoice() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedClientId == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please select a client')));
      return;
    }
    if (_lineItems.every((i) => i.descriptionController.text.trim().isEmpty)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Add at least one line item')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final userId = SupabaseConfig.client.auth.currentUser!.id;
      final repo = ref.read(invoiceRepositoryProvider);

      String invoiceNumber;
      if (isEditing && _existingInvoice != null) {
        invoiceNumber = _existingInvoice!.invoiceNumber;
      } else {
        invoiceNumber = await repo.getNextInvoiceNumber(userId);
      }

      late Invoice invoice = Invoice(
        id: _existingInvoice?.id ?? '',
        userId: userId,
        clientId: _selectedClientId!,
        invoiceNumber: invoiceNumber,
        status: InvoiceStatus.draft,
        issueDate: _issueDate,
        dueDate: _dueDate,
        subtotal: _subtotal,
        taxPercent: _taxPercent,
        taxAmount: _taxAmount,
        discountPercent: _discountPercent,
        discountAmount: _discountAmount,
        total: _total,
        currency: _currency,
        notes: _notesController.text.trim().isEmpty
            ? null
            : _notesController.text.trim(),
        paymentTerms: _paymentTermsController.text.trim().isEmpty
            ? null
            : _paymentTermsController.text.trim(),
        createdAt: _existingInvoice?.createdAt ?? DateTime.now(),
      );

      if (isEditing) {
        await repo.updateInvoice(invoice);
        for (var item in _existingItems) {
          await repo.deleteInvoiceItem(item.id!);
        }
      } else {
        invoice = await repo.createInvoice(invoice);
      }

      for (int i = 0; i < _lineItems.length; i++) {
        final item = _lineItems[i];
        if (item.descriptionController.text.trim().isEmpty) continue;

        final invoiceItem = InvoiceItem(
          invoiceId: invoice.id!,
          userId: userId,
          description: item.descriptionController.text.trim(),
          quantity: item.quantity,
          unitPrice: item.unitPrice,
          total: item.total,
          sortOrder: i,
          createdAt: DateTime.now(),
        );
        await repo.createInvoiceItem(invoiceItem);
      }

      if (_dueDate != null) {
        final prefs = ref.read(notificationPrefsProvider);
        if (prefs.invoiceReminders) {
          final clients = await ref.read(clientsProvider.future);
          final client = clients.firstWhere((c) => c.id == _selectedClientId);
          await NotificationService.instance.scheduleInvoiceReminder(
            invoiceId: invoice.id!,
            invoiceNumber: invoice.invoiceNumber,
            clientName: client.name,
            dueDate: _dueDate!,
            total: _total,
          );
        }
      }

      if (mounted) {
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _pickDate(bool isIssueDate) async {
    final initialDate = isIssueDate
        ? _issueDate
        : (_dueDate ?? DateTime.now().add(const Duration(days: 30)));

    final picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );

    if (picked != null) {
      setState(() {
        if (isIssueDate) {
          _issueDate = picked;
        } else {
          _dueDate = picked;
        }
      });
    }
  }

  void _addLineItem() {
    setState(() {
      _lineItems.add(_LineItem());
    });
  }

  void _removeLineItem(int index) {
    if (_lineItems.length > 1) {
      setState(() {
        _lineItems[index].dispose();
        _lineItems.removeAt(index);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final clients = ref.watch(clientsProvider);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => context.pop(),
        ),
        title: Text(isEditing ? 'Edit Invoice' : 'Create Invoice'),
        actions: [
          TextButton(
            onPressed: _isLoading ? null : _saveInvoice,
            child: _isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('Save'),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            clients.when(
              data: (list) => DropdownButtonFormField<String>(
                value: _selectedClientId,
                decoration: const InputDecoration(
                  labelText: 'Client *',
                  prefixIcon: Icon(Icons.person_outline),
                ),
                items: list
                    .map(
                      (c) => DropdownMenuItem(value: c.id, child: Text(c.name)),
                    )
                    .toList(),
                onChanged: (v) => setState(() => _selectedClientId = v),
                validator: (v) => v == null ? 'Required' : null,
              ),
              loading: () => const LinearProgressIndicator(),
              error: (_, __) => const Text('Error loading clients'),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: InkWell(
                    onTap: () => _pickDate(true),
                    borderRadius: BorderRadius.circular(12),
                    child: InputDecorator(
                      decoration: const InputDecoration(
                        labelText: 'Issue Date',
                        prefixIcon: Icon(Icons.calendar_today),
                      ),
                      child: Text(
                        '${_issueDate.month}/${_issueDate.day}/${_issueDate.year}',
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: InkWell(
                    onTap: () => _pickDate(false),
                    borderRadius: BorderRadius.circular(12),
                    child: InputDecorator(
                      decoration: InputDecoration(
                        labelText: 'Due Date',
                        prefixIcon: const Icon(Icons.event),
                        suffixIcon: _dueDate != null
                            ? IconButton(
                                icon: const Icon(Icons.close),
                                onPressed: () =>
                                    setState(() => _dueDate = null),
                              )
                            : null,
                      ),
                      child: Text(
                        _dueDate != null
                            ? '${_dueDate!.month}/${_dueDate!.day}/${_dueDate!.year}'
                            : '',
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Line Items',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                TextButton.icon(
                  onPressed: _addLineItem,
                  icon: const Icon(Icons.add),
                  label: const Text('Add Item'),
                ),
              ],
            ),
            ...List.generate(
              _lineItems.length,
              (index) => _buildLineItem(index),
            ),
            const SizedBox(height: 24),
            _buildTotalsSection(),
            const SizedBox(height: 16),
            TextField(
              controller: _notesController,
              decoration: const InputDecoration(
                labelText: 'Notes',
                prefixIcon: Icon(Icons.notes),
                alignLabelWithHint: true,
              ),
              maxLines: 2,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _paymentTermsController,
              decoration: const InputDecoration(
                labelText: 'Payment Terms',
                prefixIcon: Icon(Icons.gavel),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLineItem(int index) {
    final item = _lineItems[index];
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: item.descriptionController,
                    decoration: InputDecoration(
                      labelText: 'Description ${index + 1}',
                      isDense: true,
                    ),
                    onChanged: (_) => setState(() {}),
                  ),
                ),
                if (_lineItems.length > 1)
                  IconButton(
                    icon: const Icon(
                      Icons.delete_outline,
                      color: AppColors.error,
                    ),
                    onPressed: () => _removeLineItem(index),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: item.quantityController,
                    decoration: const InputDecoration(
                      labelText: 'Qty',
                      isDense: true,
                    ),
                    keyboardType: TextInputType.number,
                    onChanged: (_) => setState(() {}),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  flex: 2,
                  child: TextField(
                    controller: item.unitPriceController,
                    decoration: const InputDecoration(
                      labelText: 'Unit Price',
                      isDense: true,
                      prefixText: '\$ ',
                    ),
                    keyboardType: TextInputType.number,
                    onChanged: (_) => setState(() {}),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: InputDecorator(
                    decoration: const InputDecoration(
                      labelText: 'Total',
                      isDense: true,
                    ),
                    child: Text('\$${item.total.toStringAsFixed(2)}'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTotalsSection() {
    return Card(
      color: AppColors.primary500.withValues(alpha: 0.05),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Subtotal'),
                Text('\$${_subtotal.toStringAsFixed(2)}'),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Text('Tax'),
                const Spacer(),
                SizedBox(
                  width: 60,
                  child: TextField(
                    decoration: const InputDecoration(
                      isDense: true,
                      suffixText: '%',
                    ),
                    keyboardType: TextInputType.number,
                    onChanged: (v) =>
                        setState(() => _taxPercent = double.tryParse(v) ?? 0),
                    controller: TextEditingController(
                      text: _taxPercent.toStringAsFixed(0),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                SizedBox(
                  width: 80,
                  child: Text(
                    '\$${_taxAmount.toStringAsFixed(2)}',
                    textAlign: TextAlign.right,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Text('Discount'),
                const Spacer(),
                SizedBox(
                  width: 60,
                  child: TextField(
                    decoration: const InputDecoration(
                      isDense: true,
                      suffixText: '%',
                    ),
                    keyboardType: TextInputType.number,
                    onChanged: (v) => setState(
                      () => _discountPercent = double.tryParse(v) ?? 0,
                    ),
                    controller: TextEditingController(
                      text: _discountPercent.toStringAsFixed(0),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                SizedBox(
                  width: 80,
                  child: Text(
                    '\$${_discountAmount.toStringAsFixed(2)}',
                    textAlign: TextAlign.right,
                  ),
                ),
              ],
            ),
            const Divider(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Total',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '\$${_total.toStringAsFixed(2)}',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary500,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _LineItem {
  final TextEditingController descriptionController;
  final TextEditingController quantityController;
  final TextEditingController unitPriceController;

  _LineItem({String? description, double? quantity, double? unitPrice})
    : descriptionController = TextEditingController(text: description ?? ''),
      quantityController = TextEditingController(
        text: (quantity ?? 1).toString(),
      ),
      unitPriceController = TextEditingController(
        text: (unitPrice ?? 0).toString(),
      );

  double get quantity => double.tryParse(quantityController.text) ?? 1;
  double get unitPrice => double.tryParse(unitPriceController.text) ?? 0;
  double get total => quantity * unitPrice;

  void dispose() {
    descriptionController.dispose();
    quantityController.dispose();
    unitPriceController.dispose();
  }
}
