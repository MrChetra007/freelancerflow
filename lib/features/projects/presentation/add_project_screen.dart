import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/supabase/supabase_client.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/services/notification_service.dart';
import 'package:client_manager/features/clients/data/clients_provider.dart';
import 'package:client_manager/features/settings/presentation/settings_screen.dart';
import '../data/projects_provider.dart';
import '../domain/project.dart';

class AddProjectScreen extends ConsumerStatefulWidget {
  final String? projectId;

  const AddProjectScreen({super.key, this.projectId});

  @override
  ConsumerState<AddProjectScreen> createState() => _AddProjectScreenState();
}

class _AddProjectScreenState extends ConsumerState<AddProjectScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _budgetController = TextEditingController(text: '0');

  String? _selectedClientId;
  ProjectStatus _status = ProjectStatus.inProgress;
  DateTime? _startDate;
  DateTime? _deadline;
  String _currency = 'USD';
  bool _isLoading = false;
  Project? _existingProject;

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

  bool get isEditing => widget.projectId != null;

  @override
  void initState() {
    super.initState();
    if (isEditing) {
      _loadProject();
    }
  }

  Future<void> _loadProject() async {
    final repo = ref.read(projectRepositoryProvider);
    final project = await repo.getProject(widget.projectId!);
    if (project != null && mounted) {
      setState(() {
        _existingProject = project;
        _titleController.text = project.title;
        _descriptionController.text = project.description ?? '';
        _budgetController.text = project.budget.toString();
        _selectedClientId = project.clientId;
        _status = project.status;
        _startDate = project.startDate;
        _deadline = project.deadline;
        _currency = project.currency;
      });
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _budgetController.dispose();
    super.dispose();
  }

  Future<void> _saveProject() async {
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

      if (isEditing && _existingProject != null) {
        final updated = _existingProject!.copyWith(
          title: _titleController.text.trim(),
          description: _descriptionController.text.trim().isEmpty
              ? null
              : _descriptionController.text.trim(),
          clientId: _selectedClientId ?? _existingProject!.clientId,
          status: _status,
          budget: double.tryParse(_budgetController.text) ?? 0,
          currency: _currency,
          startDate: _startDate,
          deadline: _deadline,
          completedAt: _status == ProjectStatus.completed
              ? DateTime.now()
              : null,
        );
        await ref.read(projectsProvider.notifier).updateProject(updated);
      } else {
        final newProject = Project(
          id: '',
          userId: userId,
          clientId: _selectedClientId!,
          title: _titleController.text.trim(),
          description: _descriptionController.text.trim().isEmpty
              ? null
              : _descriptionController.text.trim(),
          status: _status,
          budget: double.tryParse(_budgetController.text) ?? 0,
          currency: _currency,
          startDate: _startDate,
          deadline: _deadline,
          createdAt: DateTime.now(),
        );
        await ref.read(projectsProvider.notifier).addProject(newProject);

        if (_deadline != null) {
          final prefs = ref.read(notificationPrefsProvider);
          if (prefs.projectReminders) {
            final clients = await ref.read(clientsProvider.future);
            final client = clients.firstWhere((c) => c.id == _selectedClientId);
            await NotificationService.instance.scheduleProjectDeadlineReminder(
              projectId: DateTime.now().millisecondsSinceEpoch.toString(),
              projectTitle: _titleController.text.trim(),
              clientName: client.name,
              deadline: _deadline!,
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

  Future<void> _pickDate(bool isStartDate) async {
    final initialDate = isStartDate
        ? (_startDate ?? DateTime.now())
        : (_deadline ?? DateTime.now().add(const Duration(days: 30)));

    final picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: isStartDate ? DateTime(2020) : _startDate ?? DateTime(2020),
      lastDate: DateTime(2030),
    );

    if (picked != null) {
      setState(() {
        if (isStartDate) {
          _startDate = picked;
        } else {
          _deadline = picked;
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
        title: Text(isEditing ? 'Edit Project' : 'New Project'),
        actions: [
          TextButton(
            onPressed: _isLoading ? null : _saveProject,
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
            TextFormField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Project Title *',
                prefixIcon: Icon(Icons.folder_outlined),
              ),
              textCapitalization: TextCapitalization.words,
              validator: (v) =>
                  v?.trim().isEmpty == true ? 'Title is required' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: 'Description',
                prefixIcon: Icon(Icons.description_outlined),
                alignLabelWithHint: true,
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 16),
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
                validator: (v) => v == null ? 'Please select a client' : null,
              ),
              loading: () => const LinearProgressIndicator(),
              error: (_, _) => const Text('Error loading clients'),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<ProjectStatus>(
              initialValue: _status,
              decoration: const InputDecoration(
                labelText: 'Status',
                prefixIcon: Icon(Icons.flag_outlined),
              ),
              items: ProjectStatus.values
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
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _budgetController,
                    decoration: const InputDecoration(
                      labelText: 'Budget',
                      prefixIcon: Icon(Icons.attach_money),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    initialValue: _currency,
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
            Row(
              children: [
                Expanded(
                  child: _DateField(
                    label: 'Start Date',
                    date: _startDate,
                    onTap: () => _pickDate(true),
                    onClear: () => setState(() => _startDate = null),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _DateField(
                    label: 'Deadline',
                    date: _deadline,
                    onTap: () => _pickDate(false),
                    onClear: () => setState(() => _deadline = null),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _getStatusLabel(ProjectStatus status) {
    return switch (status) {
      ProjectStatus.inProgress => 'In Progress',
      ProjectStatus.completed => 'Completed',
      ProjectStatus.onHold => 'On Hold',
      ProjectStatus.cancelled => 'Cancelled',
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
