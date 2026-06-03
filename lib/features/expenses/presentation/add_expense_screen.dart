import 'dart:io';

import 'package:client_manager/features/clients/data/clients_provider.dart';
import 'package:client_manager/features/clients/domain/client.dart';
import 'package:client_manager/features/expenses/domain/expense.dart';
import 'package:client_manager/features/expenses/domain/expense_category.dart';
import 'package:client_manager/features/projects/data/projects_provider.dart';
import 'package:client_manager/features/projects/domain/project.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../../core/supabase/supabase_client.dart';
import '../../../../core/widgets/pro_gate.dart';
import '../../../../features/settings/data/premium_provider.dart';
import '../data/expense_provider.dart';

class AddExpenseScreen extends ConsumerWidget {
  final Expense? expense;
  final String? projectId;
  final String? clientId;

  const AddExpenseScreen({super.key, this.expense, this.projectId, this.clientId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        title: Text(expense != null ? 'Edit Expense' : 'Add Expense'),
      ),
      body: _ExpenseForm(expense: expense, projectId: projectId, clientId: clientId),
    );
  }
}

class _ExpenseForm extends ConsumerStatefulWidget {
  final Expense? expense;
  final String? projectId;
  final String? clientId;

  const _ExpenseForm({this.expense, this.projectId, this.clientId});

  @override
  ConsumerState<_ExpenseForm> createState() => _ExpenseFormState();
}

class _ExpenseFormState extends ConsumerState<_ExpenseForm> {
  final _formKey = GlobalKey<FormState>();
  final _descriptionController = TextEditingController();
  final _amountController = TextEditingController();
  final _notesController = TextEditingController();
  ExpenseCategory _selectedCategory = ExpenseCategory.other;
  DateTime _selectedDate = DateTime.now();
  bool _isBillable = false;
  File? _receiptFile;
  String? _receiptUrl;
  String? _selectedClientId;
  String? _selectedProjectId;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.expense != null) {
      _descriptionController.text = widget.expense!.description;
      _amountController.text = widget.expense!.amount.toString();
      _notesController.text = widget.expense!.notes ?? '';
      _selectedCategory = widget.expense!.category;
      _selectedDate = widget.expense!.date;
      _isBillable = widget.expense!.isBillable;
      _receiptUrl = widget.expense!.receiptUrl;
      _selectedClientId = widget.expense!.clientId;
      _selectedProjectId = widget.expense!.projectId;
    } else if (widget.projectId != null) {
      _selectedProjectId = widget.projectId;
      _selectedClientId = widget.clientId;
    }
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    _amountController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final clientsAsync = ref.watch(clientsProvider);
    final projectsAsync = ref.watch(projectsProvider);

    return Form(
      key: _formKey,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          DropdownButtonFormField<ExpenseCategory>(
            value: _selectedCategory,
            decoration: const InputDecoration(
              labelText: 'Category',
              border: OutlineInputBorder(),
            ),
            items: ExpenseCategory.values.map((category) {
              return DropdownMenuItem(
                value: category,
                child: Row(
                  children: [
                    Icon(category.icon, size: 20),
                    const SizedBox(width: 12),
                    Text(category.label),
                  ],
                ),
              );
            }).toList(),
            onChanged: (value) {
              if (value != null) setState(() => _selectedCategory = value);
            },
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _descriptionController,
            decoration: const InputDecoration(
              labelText: 'Description',
              border: OutlineInputBorder(),
            ),
            maxLines: 2,
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _amountController,
            decoration: const InputDecoration(
              labelText: 'Amount',
              border: OutlineInputBorder(),
              prefixText: '\$ ',
            ),
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter an amount';
              }
              if (double.tryParse(value) == null) {
                return 'Please enter a valid number';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          clientsAsync.when(
            data: (clients) => _buildClientPicker(clients),
            loading: () => const CircularProgressIndicator(),
            error: (e, st) => const SizedBox.shrink(),
          ),
          const SizedBox(height: 16),
          projectsAsync.when(
            data: (projects) => _buildProjectPicker(projects),
            loading: () => const CircularProgressIndicator(),
            error: (e, st) => const SizedBox.shrink(),
          ),
          const SizedBox(height: 16),
          InkWell(
            onTap: () async {
              final date = await showDatePicker(
                context: context,
                initialDate: _selectedDate,
                firstDate: DateTime(2020),
                lastDate: DateTime.now(),
              );
              if (date != null) {
                setState(() => _selectedDate = date);
              }
            },
            child: InputDecorator(
              decoration: const InputDecoration(
                labelText: 'Date',
                border: OutlineInputBorder(),
              ),
              child: Text(DateFormatter.formatDate(_selectedDate)),
            ),
          ),
          const SizedBox(height: 16),
          SwitchListTile(
            title: const Text('Billable'),
            subtitle: const Text('Can be added to an invoice later'),
            value: _isBillable,
            onChanged: (v) => setState(() => _isBillable = v),
          ),
          const SizedBox(height: 16),
          ListTile(
            leading: const Icon(Icons.receipt_outlined),
            title: Text(
              _receiptFile != null
                  ? 'New receipt selected'
                  : _receiptUrl != null
                  ? 'Current receipt attached'
                  : 'Upload Receipt (optional)',
            ),
            subtitle: _receiptFile != null
                ? Text(_receiptFile!.path.split('/').last)
                : null,
            trailing: _receiptUrl != null || _receiptFile != null
                ? IconButton(
                    icon: const Icon(Icons.delete, color: AppColors.error),
                    onPressed: () {
                      setState(() {
                        _receiptFile = null;
                        _receiptUrl = null;
                      });
                    },
                  )
                : const Icon(Icons.upload_file),
            onTap: _pickReceipt,
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _notesController,
            decoration: const InputDecoration(
              labelText: 'Notes (optional)',
              border: OutlineInputBorder(),
            ),
            maxLines: 3,
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: _isLoading ? null : _saveExpense,
            style: ElevatedButton.styleFrom(
              minimumSize: const Size(double.infinity, 48),
            ),
            child: _isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Text(widget.expense != null ? 'Update' : 'Save Expense'),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildClientPicker(List<Client> clients) {
    return DropdownButtonFormField<String>(
      value: _selectedClientId,
      decoration: const InputDecoration(
        labelText: 'Client (optional)',
        border: OutlineInputBorder(),
      ),
      isExpanded: true,
      items: [
        const DropdownMenuItem<String>(value: null, child: Text('None')),
        ...clients.map((client) {
          return DropdownMenuItem<String>(
            value: client.id,
            child: Text(client.name),
          );
        }),
      ],
      onChanged: (value) {
        setState(() => _selectedClientId = value);
      },
    );
  }

  Widget _buildProjectPicker(List<Project> projects) {
    final filtered = _selectedClientId != null
        ? projects.where((p) => p.clientId == _selectedClientId).toList()
        : projects;

    return DropdownButtonFormField<String>(
      value: _selectedProjectId,
      decoration: const InputDecoration(
        labelText: 'Project (optional)',
        border: OutlineInputBorder(),
      ),
      isExpanded: true,
      items: [
        const DropdownMenuItem<String>(value: null, child: Text('None')),
        ...filtered.map((project) {
          return DropdownMenuItem<String>(
            value: project.id,
            child: Text(project.title),
          );
        }),
      ],
      onChanged: (value) {
        setState(() => _selectedProjectId = value);
      },
    );
  }

  Future<void> _pickReceipt() async {
    if (!mounted) return;
    final isPremium = ref.read(isPremiumProvider);
    if (!isPremium) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Receipt upload requires Pro')),
      );
      return;
    }
    final picker = ImagePicker();
    final image = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1920,
      maxHeight: 1920,
      imageQuality: 85,
    );
    if (image != null) {
      setState(() => _receiptFile = File(image.path));
    }
  }

  Future<void> _saveExpense() async {
    if (!_formKey.currentState!.validate()) return;
    final user = SupabaseConfig.client.auth.currentUser;
    if (user == null) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('You must be logged in')));
      }
      return;
    }

    setState(() => _isLoading = true);
    try {
      final amount = double.parse(_amountController.text);
      final repo = ref.read(expenseRepositoryProvider);

      final expense = Expense(
        id: widget.expense?.id,
        userId: user.id,
        projectId: _selectedProjectId,
        clientId: _selectedClientId,
        category: _selectedCategory,
        description: _descriptionController.text.trim(),
        amount: amount,
        currency: 'USD',
        date: _selectedDate,
        receiptUrl: _receiptUrl,
        isBillable: _isBillable,
        isBilled: widget.expense?.isBilled ?? false,
        notes: _notesController.text.trim().isEmpty
            ? null
            : _notesController.text.trim(),
        createdAt: widget.expense?.createdAt ?? DateTime.now(),
      );

      await repo.create(expense, receiptFile: _receiptFile);
      if (mounted) {
        context.pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              widget.expense != null ? 'Expense updated' : 'Expense saved',
            ),
          ),
        );
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
}
