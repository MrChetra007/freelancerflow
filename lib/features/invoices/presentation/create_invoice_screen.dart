import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/supabase/supabase_client.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/services/notification_service.dart';
import '../../../../core/widgets/pro_gate.dart';
import '../../../../features/settings/data/premium_provider.dart';
import 'package:client_manager/features/clients/data/clients_provider.dart';
import 'package:client_manager/features/settings/presentation/settings_screen.dart';
import '../../time_tracking/data/time_entry_provider.dart';
import '../../time_tracking/domain/time_entry.dart';
import '../../expenses/data/expense_provider.dart';
import '../../recurring/data/recurring_provider.dart';
import '../../recurring/domain/recurring_invoice.dart';
import '../../recurring/domain/recurrence_frequency.dart';
import '../../recurring/domain/invoice_line_item.dart';
import '../data/invoices_provider.dart';
import '../domain/invoice.dart';
import '../domain/invoice_item.dart';
import 'widgets/import_line_items_sheet.dart';

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
  bool _isRecurring = false;
  RecurrenceFrequency _recurringFrequency = RecurrenceFrequency.monthly;
  DateTime _recurringStartDate = DateTime.now();
  int _recurringDueDays = 30;

  List<_LineItem> _lineItems = [_LineItem()];
  final List<String> _importedTimeEntryIds = [];
  final List<String> _importedExpenseIds = [];
  Invoice? _existingInvoice;
  List<InvoiceItem> _existingItems = [];

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

      if (_importedTimeEntryIds.isNotEmpty) {
        await ref
            .read(timeEntryRepositoryProvider)
            .markAsBilled(_importedTimeEntryIds, invoice.id!);
      }

      if (_importedExpenseIds.isNotEmpty) {
        await ref
            .read(expenseRepositoryProvider)
            .markAsBilled(_importedExpenseIds, invoice.id!);
      }

      if (_isRecurring && !isEditing) {
        final lineItems = _lineItems
            .where((i) => i.descriptionController.text.trim().isNotEmpty)
            .map(
              (i) => InvoiceLineItem(
                description: i.descriptionController.text.trim(),
                quantity: i.quantity,
                unitPrice: i.unitPrice,
              ),
            )
            .toList();

        final recurring = RecurringInvoice(
          userId: userId,
          clientId: _selectedClientId!,
          frequency: _recurringFrequency,
          nextIssueDate: _recurringStartDate,
          dueDays: _recurringDueDays,
          lineItems: lineItems,
          taxPercent: _taxPercent,
          discountPercent: _discountPercent,
          currency: _currency,
          notes: _notesController.text.trim().isEmpty
              ? null
              : _notesController.text.trim(),
          paymentTerms: _paymentTermsController.text.trim().isEmpty
              ? null
              : _paymentTermsController.text.trim(),
          createdAt: DateTime.now(),
        );

        await ref
            .read(recurringInvoiceRepositoryProvider)
            .create(recurring);
      }

      if (_dueDate != null && ref.read(isPremiumProvider)) {
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

  Future<void> _importEntries() async {
    if (_selectedClientId == null) return;
    if (!ref.read(isPremiumProvider)) {
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        builder: (context) => const _ProPromptSheet(),
      );
      return;
    }

    final result = await showImportLineItemsSheet(
      context,
      clientId: _selectedClientId!,
    );

    if (result != null && (result.timeEntryIds.isNotEmpty || result.expenseIds.isNotEmpty)) {
      if (result.timeEntryIds.isNotEmpty) {
        final timeEntries = await ref
            .read(timeEntryRepositoryProvider)
            .getUnbilledForClient(_selectedClientId!);
        for (final entry in result.timeEntryIds) {
          final timeEntry = timeEntries?.firstWhere(
            (e) => e.id == entry,
            orElse: () => throw Exception('Time entry not found'),
          );
          if (timeEntry != null) {
            final hours = timeEntry.duration.inSeconds / 3600;
            _lineItems.add(_LineItem(
              description: timeEntry.description ?? 'Time entry',
              quantity: double.parse(hours.toStringAsFixed(2)),
              unitPrice: timeEntry.hourlyRate,
            ));
            _importedTimeEntryIds.add(entry);
          }
        }
      }

      if (result.expenseIds.isNotEmpty) {
        final expenses = await ref
            .read(expenseRepositoryProvider)
            .getExpenses(
              clientId: _selectedClientId,
              isBillable: true,
              isBilled: false,
            );
        for (final expenseId in result.expenseIds) {
          final expense = expenses.firstWhere(
            (e) => e.id == expenseId,
            orElse: () => throw Exception('Expense not found'),
          );
          _lineItems.add(_LineItem(
            description: expense.description,
            quantity: 1,
            unitPrice: expense.amount,
          ));
          _importedExpenseIds.add(expenseId);
        }
      }

      if (mounted) {
        setState(() {});
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Imported ${result.timeEntryIds.length + result.expenseIds.length} item(s)',
            ),
          ),
        );
      }
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
                initialValue: _selectedClientId,
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
              error: (_, _) => const Text('Error loading clients'),
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
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextButton.icon(
                      onPressed: _selectedClientId == null ? null : _importEntries,
                      icon: const Icon(Icons.download),
                      label: const Text('Import'),
                    ),
                    TextButton.icon(
                      onPressed: _addLineItem,
                      icon: const Icon(Icons.add),
                      label: const Text('Add'),
                    ),
                  ],
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
            if (!isEditing) ...[
              const SizedBox(height: 24),
              ProGate(
                onBlocked: () {
                  showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                    ),
                    builder: (context) => const _ProPromptSheet(),
                  );
                },
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.autorenew,
                              color: Theme.of(context).primaryColor,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Recurring Invoice',
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                            const Spacer(),
                            Switch(
                              value: _isRecurring,
                              onChanged: (v) => setState(() => _isRecurring = v),
                            ),
                          ],
                        ),
                        if (_isRecurring) ...[
                          const SizedBox(height: 16),
                          DropdownButtonFormField<RecurrenceFrequency>(
                            value: _recurringFrequency,
                            decoration: const InputDecoration(
                              labelText: 'Frequency',
                              border: OutlineInputBorder(),
                            ),
                            items: RecurrenceFrequency.values.map((f) {
                              return DropdownMenuItem(
                                value: f,
                                child: Text(_frequencyLabel(f)),
                              );
                            }).toList(),
                            onChanged: (v) {
                              if (v != null) {
                                setState(() => _recurringFrequency = v);
                              }
                            },
                          ),
                          const SizedBox(height: 16),
                          InkWell(
                            onTap: () async {
                              final date = await showDatePicker(
                                context: context,
                                initialDate: _recurringStartDate,
                                firstDate: DateTime.now(),
                                lastDate: DateTime.now().add(
                                  const Duration(days: 365),
                                ),
                              );
                              if (date != null) {
                                setState(() => _recurringStartDate = date);
                              }
                            },
                            child: InputDecorator(
                              decoration: const InputDecoration(
                                labelText: 'First Issue Date',
                                border: OutlineInputBorder(),
                                prefixIcon: Icon(Icons.calendar_today),
                              ),
                              child: Text(
                                '${_recurringStartDate.month}/${_recurringStartDate.day}/${_recurringStartDate.year}',
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            initialValue: _recurringDueDays.toString(),
                            decoration: const InputDecoration(
                              labelText: 'Due in X days',
                              border: OutlineInputBorder(),
                              suffixText: 'days',
                            ),
                            keyboardType: TextInputType.number,
                            onChanged: (v) {
                              final parsed = int.tryParse(v);
                              if (parsed != null) {
                                setState(() => _recurringDueDays = parsed);
                              }
                            },
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            ],
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
  String _frequencyLabel(RecurrenceFrequency frequency) {
    return switch (frequency) {
      RecurrenceFrequency.weekly => 'Weekly',
      RecurrenceFrequency.biweekly => 'Bi-weekly',
      RecurrenceFrequency.monthly => 'Monthly',
      RecurrenceFrequency.quarterly => 'Quarterly',
      RecurrenceFrequency.yearly => 'Yearly',
    };
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

class _ProPromptSheet extends StatelessWidget {
  const _ProPromptSheet();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 8, 24, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.amber.shade600, Colors.amber.shade800],
                ),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.workspace_premium,
                color: Colors.white,
                size: 48,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Upgrade to Pro',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Import entries and create recurring invoices with Pro',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
            ),
            const SizedBox(height: 32),
            FilledButton.icon(
              onPressed: () {
                context.pop();
                context.push('/premium');
              },
              icon: const Icon(Icons.workspace_premium),
              label: const Text('Upgrade Now'),
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
            ),
            const SizedBox(height: 12),
            TextButton(onPressed: () => context.pop(), child: const Text('Maybe Later')),
          ],
        ),
      ),
    );
  }
}
