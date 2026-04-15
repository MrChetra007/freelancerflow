import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/supabase/supabase_client.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/services/notification_service.dart';
import '../../clients/data/clients_provider.dart';
import '../../settings/presentation/settings_screen.dart';
import '../data/payments_provider.dart';
import '../domain/payment.dart';

class AddPaymentScreen extends ConsumerStatefulWidget {
  final String? paymentId;

  const AddPaymentScreen({super.key, this.paymentId});

  @override
  ConsumerState<AddPaymentScreen> createState() => _AddPaymentScreenState();
}

class _AddPaymentScreenState extends ConsumerState<AddPaymentScreen> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _amountPaidController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _referenceController = TextEditingController();
  final _notesController = TextEditingController();

  String? _selectedClientId;
  String? _selectedProjectId;
  PaymentStatus _status = PaymentStatus.unpaid;
  PaymentMethod _method = PaymentMethod.bankTransfer;
  DateTime? _dueDate;
  DateTime? _paidDate;
  String _currency = 'USD';
  bool _isLoading = false;
  Payment? _existingPayment;

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

  bool get isEditing => widget.paymentId != null;

  @override
  void initState() {
    super.initState();
    if (isEditing) {
      _loadPayment();
    }
  }

  Future<void> _loadPayment() async {
    final repo = ref.read(paymentRepositoryProvider);
    final payment = await repo.getPayment(widget.paymentId!);
    if (payment != null && mounted) {
      setState(() {
        _existingPayment = payment;
        _amountController.text = payment.amount.toString();
        _amountPaidController.text = payment.amountPaid.toString();
        _descriptionController.text = payment.description ?? '';
        _referenceController.text = payment.referenceNo ?? '';
        _notesController.text = payment.notes ?? '';
        _selectedClientId = payment.clientId;
        _selectedProjectId = payment.projectId;
        _status = payment.status;
        _method = payment.method ?? PaymentMethod.bankTransfer;
        _dueDate = payment.dueDate;
        _paidDate = payment.paidDate;
        _currency = payment.currency;
      });
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    _amountPaidController.dispose();
    _descriptionController.dispose();
    _referenceController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _savePayment() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedClientId == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please select a client')));
      return;
    }

    setState(() => _isLoading = true);

    try {
      final userId = SupabaseConfig.client.auth.currentUser!.id;

      if (isEditing && _existingPayment != null) {
        final updated = _existingPayment!.copyWith(
          clientId: _selectedClientId ?? _existingPayment!.clientId,
          projectId: _selectedProjectId,
          amount: double.tryParse(_amountController.text) ?? 0,
          amountPaid: _status == PaymentStatus.paid
              ? (double.tryParse(_amountController.text) ?? 0)
              : (double.tryParse(_amountPaidController.text) ?? 0),
          currency: _currency,
          status: _status,
          method: _method,
          dueDate: _dueDate,
          paidDate: _status == PaymentStatus.paid && _paidDate == null
              ? DateTime.now()
              : _paidDate,
          description: _descriptionController.text.trim().isEmpty
              ? null
              : _descriptionController.text.trim(),
          referenceNo: _referenceController.text.trim().isEmpty
              ? null
              : _referenceController.text.trim(),
          notes: _notesController.text.trim().isEmpty
              ? null
              : _notesController.text.trim(),
        );
        await ref.read(paymentsProvider.notifier).updatePayment(updated);
      } else {
        final newPayment = Payment(
          userId: userId,
          clientId: _selectedClientId!,
          projectId: _selectedProjectId,
          amount: double.tryParse(_amountController.text) ?? 0,
          amountPaid: _status == PaymentStatus.paid
              ? (double.tryParse(_amountController.text) ?? 0)
              : (double.tryParse(_amountPaidController.text) ?? 0),
          currency: _currency,
          status: _status,
          method: _method,
          dueDate: _dueDate,
          paidDate: _status == PaymentStatus.paid && _paidDate == null
              ? DateTime.now()
              : _paidDate,
          description: _descriptionController.text.trim().isEmpty
              ? null
              : _descriptionController.text.trim(),
          referenceNo: _referenceController.text.trim().isEmpty
              ? null
              : _referenceController.text.trim(),
          notes: _notesController.text.trim().isEmpty
              ? null
              : _notesController.text.trim(),
          createdAt: DateTime.now(),
        );
        await ref.read(paymentsProvider.notifier).addPayment(newPayment);

        if (_dueDate != null) {
          final prefs = ref.read(notificationPrefsProvider);
          if (prefs.paymentReminders) {
            final clients = await ref.read(clientsProvider.future);
            final client = clients.firstWhere((c) => c.id == _selectedClientId);
            await NotificationService.instance.schedulePaymentReminder(
              paymentId: DateTime.now().millisecondsSinceEpoch.toString(),
              clientName: client.name,
              amount: double.tryParse(_amountController.text) ?? 0,
              dueDate: _dueDate!,
            );
          }
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

  Future<void> _pickDate(bool isDueDate) async {
    final initialDate = isDueDate
        ? (_dueDate ?? DateTime.now().add(const Duration(days: 30)))
        : (_paidDate ?? DateTime.now());

    final picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );

    if (picked != null) {
      setState(() {
        if (isDueDate) {
          _dueDate = picked;
        } else {
          _paidDate = picked;
        }
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
        title: Text(isEditing ? 'Edit Payment' : 'New Payment'),
        actions: [
          TextButton(
            onPressed: _isLoading ? null : _savePayment,
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
            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: TextFormField(
                    controller: _amountController,
                    decoration: const InputDecoration(
                      labelText: 'Amount *',
                      prefixIcon: Icon(Icons.attach_money),
                    ),
                    keyboardType: TextInputType.number,
                    validator: (v) => v?.isEmpty == true ? 'Required' : null,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _currency,
                    decoration: const InputDecoration(labelText: 'Currency'),
                    items: _currencies
                        .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                        .toList(),
                    onChanged: (v) => setState(() => _currency = v!),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
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
                onChanged: (v) => setState(() {
                  _selectedClientId = v;
                  _selectedProjectId = null;
                }),
                validator: (v) => v == null ? 'Required' : null,
              ),
              loading: () => const LinearProgressIndicator(),
              error: (_, __) => const Text('Error loading clients'),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<PaymentStatus>(
              value: _status,
              decoration: const InputDecoration(
                labelText: 'Status',
                prefixIcon: Icon(Icons.flag_outlined),
              ),
              items: PaymentStatus.values
                  .map(
                    (s) => DropdownMenuItem(
                      value: s,
                      child: Text(_getStatusLabel(s)),
                    ),
                  )
                  .toList(),
              onChanged: (v) => setState(() => _status = v!),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<PaymentMethod>(
              value: _method,
              decoration: const InputDecoration(
                labelText: 'Payment Method',
                prefixIcon: Icon(Icons.payment),
              ),
              items: PaymentMethod.values
                  .map(
                    (m) => DropdownMenuItem(
                      value: m,
                      child: Text(_getMethodLabel(m)),
                    ),
                  )
                  .toList(),
              onChanged: (v) => setState(() => _method = v!),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _DateField(
                    label: 'Due Date',
                    date: _dueDate,
                    onTap: () => _pickDate(true),
                    onClear: () => setState(() => _dueDate = null),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _DateField(
                    label: 'Paid Date',
                    date: _paidDate,
                    onTap: () => _pickDate(false),
                    onClear: () => setState(() => _paidDate = null),
                  ),
                ),
              ],
            ),
            if (_status == PaymentStatus.partial) ...[
              const SizedBox(height: 16),
              TextFormField(
                controller: _amountPaidController,
                decoration: const InputDecoration(
                  labelText: 'Amount Paid',
                  prefixIcon: Icon(Icons.paid_outlined),
                ),
                keyboardType: TextInputType.number,
              ),
            ],
            const SizedBox(height: 16),
            TextFormField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: 'Description',
                prefixIcon: Icon(Icons.description_outlined),
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _referenceController,
              decoration: const InputDecoration(
                labelText: 'Reference / Transaction ID',
                prefixIcon: Icon(Icons.tag),
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _notesController,
              decoration: const InputDecoration(
                labelText: 'Notes',
                prefixIcon: Icon(Icons.notes_outlined),
                alignLabelWithHint: true,
              ),
              maxLines: 3,
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

  String _getMethodLabel(PaymentMethod method) {
    return switch (method) {
      PaymentMethod.bankTransfer => 'Bank Transfer',
      PaymentMethod.paypal => 'PayPal',
      PaymentMethod.wise => 'Wise',
      PaymentMethod.crypto => 'Crypto',
      PaymentMethod.cash => 'Cash',
      PaymentMethod.stripe => 'Stripe',
      PaymentMethod.other => 'Other',
    };
  }
}

class _DateField extends StatelessWidget {
  final String label;
  final DateTime? date;
  final VoidCallback onTap;
  final VoidCallback onClear;

  const _DateField({
    required this.label,
    required this.date,
    required this.onTap,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: const Icon(Icons.calendar_today),
          suffixIcon: date != null
              ? IconButton(icon: const Icon(Icons.close), onPressed: onClear)
              : null,
        ),
        child: Text(
          date != null ? '${date!.month}/${date!.day}/${date!.year}' : '',
          style: date == null
              ? TextStyle(color: AppColors.lightTextSecondary)
              : null,
        ),
      ),
    );
  }
}
