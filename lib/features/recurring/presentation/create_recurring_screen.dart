import 'package:client_manager/features/recurring/domain/recurrence_frequency.dart';
import 'package:client_manager/features/recurring/domain/recurring_invoice.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/supabase/supabase_client.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../clients/data/clients_provider.dart';
import '../../clients/domain/client.dart';
import '../data/recurring_provider.dart';

class CreateRecurringScreen extends ConsumerWidget {
  final RecurringInvoice? recurring;

  const CreateRecurringScreen({super.key, this.recurring});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        title: Text(recurring != null ? 'Edit Recurring' : 'Create Recurring'),
      ),
      body: _RecurringForm(ref: ref, recurring: recurring),
    );
  }
}

class _RecurringForm extends StatefulWidget {
  final WidgetRef ref;
  final RecurringInvoice? recurring;

  const _RecurringForm({required this.ref, this.recurring});

  @override
  _RecurringFormState createState() => _RecurringFormState();
}

class _RecurringFormState extends State<_RecurringForm> {
  final _formKey = GlobalKey<FormState>();
  RecurrenceFrequency _frequency = RecurrenceFrequency.monthly;
  DateTime _nextIssueDate = DateTime.now().add(const Duration(days: 30));
  int _dueDays = 30;
  String? _selectedClientId;
  final _taxController = TextEditingController();
  final _discountController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.recurring != null) {
      _frequency = widget.recurring!.frequency;
      _nextIssueDate = widget.recurring!.nextIssueDate;
      _dueDays = widget.recurring!.dueDays;
      _selectedClientId = widget.recurring!.clientId;
      _taxController.text = widget.recurring!.taxPercent.toString();
      _discountController.text = widget.recurring!.discountPercent.toString();
    }
  }

  @override
  Widget build(BuildContext context) {
    final clientsAsync = widget.ref.watch(clientsProvider);

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Form(
        key: _formKey,
        child: ListView(
          children: [
            clientsAsync.when(
              data: (clients) => DropdownButtonFormField<String>(
                value: _selectedClientId,
                decoration: const InputDecoration(
                  labelText: 'Client',
                  border: OutlineInputBorder(),
                ),
                items: clients.map((client) {
                  return DropdownMenuItem<String>(
                    value: client.id,
                    child: Text(client.name),
                  );
                }).toList(),
                onChanged: (value) => setState(() => _selectedClientId = value),
                validator: (value) =>
                    value == null || value.isEmpty ? 'Please select a client' : null,
              ),
              loading: () => const LinearProgressIndicator(),
              error: (_, __) => const Text('Error loading clients'),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<RecurrenceFrequency>(
              value: _frequency,
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
              onChanged: (v) => setState(() => _frequency = v!),
            ),
            const SizedBox(height: 16),
            InkWell(
              onTap: () async {
                final date = await showDatePicker(
                  context: context,
                  initialDate: _nextIssueDate,
                  firstDate: DateTime.now(),
                  lastDate: DateTime.now().add(const Duration(days: 365)),
                );
                if (date != null) {
                  setState(() => _nextIssueDate = date);
                }
              },
              child: InputDecorator(
                decoration: const InputDecoration(
                  labelText: 'First Issue Date',
                  border: OutlineInputBorder(),
                ),
                child: Text(DateFormatter.formatDate(_nextIssueDate)),
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              initialValue: _dueDays.toString(),
              decoration: const InputDecoration(
                labelText: 'Due Days',
                border: OutlineInputBorder(),
                hintText: 'e.g. 30',
              ),
              keyboardType: TextInputType.number,
              onChanged: (v) => _dueDays = int.tryParse(v) ?? 30,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _taxController,
                    decoration: const InputDecoration(
                      labelText: 'Tax %',
                      border: OutlineInputBorder(),
                      suffixText: '%',
                    ),
                    keyboardType: TextInputType.number,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextFormField(
                    controller: _discountController,
                    decoration: const InputDecoration(
                      labelText: 'Discount %',
                      border: OutlineInputBorder(),
                      suffixText: '%',
                    ),
                    keyboardType: TextInputType.number,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _save,
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 48),
              ),
              child: Text(widget.recurring != null ? 'Update' : 'Create'),
            ),
          ],
        ),
      ),
    );
  }

  String _frequencyLabel(RecurrenceFrequency f) => switch (f) {
    RecurrenceFrequency.weekly => 'Weekly',
    RecurrenceFrequency.biweekly => 'Bi-weekly',
    RecurrenceFrequency.monthly => 'Monthly',
    RecurrenceFrequency.quarterly => 'Quarterly',
    RecurrenceFrequency.yearly => 'Yearly',
  };

  Future<void> _save() async {
    final repo = widget.ref.read(recurringInvoiceRepositoryProvider);
    final tax = double.tryParse(_taxController.text) ?? 0;
    final discount = double.tryParse(_discountController.text) ?? 0;

    final user = SupabaseConfig.client.auth.currentUser;
    if (user == null) return;

    if (widget.recurring != null) {
      await repo.update(
        widget.recurring!.copyWith(
          frequency: _frequency,
          nextIssueDate: _nextIssueDate,
          dueDays: _dueDays,
          taxPercent: tax,
          discountPercent: discount,
        ),
      );
    } else {
      if (_selectedClientId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please select a client')),
        );
        return;
      }

      await repo.create(
        RecurringInvoice(
          userId: user.id,
          clientId: _selectedClientId!,
          frequency: _frequency,
          nextIssueDate: _nextIssueDate,
          dueDays: _dueDays,
          taxPercent: tax,
          discountPercent: discount,
          createdAt: DateTime.now(),
        ),
      );
    }
    if (mounted) Navigator.pop(context);
  }
}
