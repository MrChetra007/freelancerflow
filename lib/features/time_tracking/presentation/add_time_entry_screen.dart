import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/utils/date_formatter.dart';
import '../../../../core/supabase/supabase_client.dart';
import '../../projects/data/projects_provider.dart';
import '../../projects/domain/project.dart';
import '../domain/time_entry.dart';
import '../data/time_entry_provider.dart';

class AddTimeEntryScreen extends ConsumerWidget {
  final TimeEntry? entry;
  final String? projectId;

  const AddTimeEntryScreen({super.key, this.entry, this.projectId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final projectsAsync = ref.watch(projectsProvider);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        title: Text(entry != null ? 'Edit Time Entry' : 'Log Time'),
        actions: [
          if (entry != null)
            IconButton(
              icon: const Icon(Icons.delete_outline),
              onPressed: () => _confirmDelete(context, ref),
            ),
        ],
      ),
      body: projectsAsync.when(
        data: (projects) => _TimeEntryForm(
          entry: entry,
          projects: projects,
          initialProjectId: projectId,
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => const Center(child: Text('Error loading projects')),
      ),
    );
  }

  void _confirmDelete(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Entry'),
        content: const Text('Are you sure you want to delete this time entry?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              if (entry!.id != null) {
                await ref
                    .read(timeEntryRepositoryProvider)
                    .delete(entry!.id!);
              }
              if (context.mounted) {
                Navigator.pop(ctx);
                context.pop();
              }
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}

class _TimeEntryForm extends ConsumerStatefulWidget {
  final TimeEntry? entry;
  final List<Project> projects;
  final String? initialProjectId;

  const _TimeEntryForm({
    this.entry,
    required this.projects,
    this.initialProjectId,
  });

  @override
  ConsumerState<_TimeEntryForm> createState() => _TimeEntryFormState();
}

class _TimeEntryFormState extends ConsumerState<_TimeEntryForm> {
  final _formKey = GlobalKey<FormState>();
  String? _selectedProjectId;
  String? _selectedClientId;
  final _descriptionController = TextEditingController();
  DateTime _startedAt = DateTime.now();
  DateTime? _endedAt;
  double _hourlyRate = 0;
  bool _isBillable = true;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.entry != null) {
      _selectedProjectId = widget.entry!.projectId;
      _selectedClientId = widget.entry!.clientId;
      _descriptionController.text = widget.entry!.description ?? '';
      _startedAt = widget.entry!.startedAt;
      _endedAt = widget.entry!.endedAt;
      _hourlyRate = widget.entry!.hourlyRate;
      _isBillable = widget.entry!.isBillable;
    } else {
      if (widget.initialProjectId != null) {
        _selectedProjectId = widget.initialProjectId;
        final project = widget.projects
            .where((p) => p.id == widget.initialProjectId)
            .firstOrNull;
        _selectedClientId = project?.clientId;
      } else if (widget.projects.isNotEmpty) {
        _selectedProjectId = widget.projects.first.id;
        _selectedClientId = widget.projects.first.clientId;
      }
    }
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Form(
        key: _formKey,
        child: ListView(
          children: [
            DropdownButtonFormField<String>(
              initialValue: _selectedProjectId,
              decoration: const InputDecoration(
                labelText: 'Project',
                border: OutlineInputBorder(),
              ),
              items: widget.projects.map((p) {
                return DropdownMenuItem<String>(
                  value: p.id,
                  child: Text(p.title),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedProjectId = value;
                  final project = widget.projects
                      .where((p) => p.id == value)
                      .firstOrNull;
                  _selectedClientId = project?.clientId;
                });
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
              initialValue: _hourlyRate.toString(),
              decoration: const InputDecoration(
                labelText: 'Hourly Rate',
                border: OutlineInputBorder(),
                prefixText: '\$ ',
              ),
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              onChanged: (v) => _hourlyRate = double.tryParse(v) ?? 0,
            ),
            const SizedBox(height: 16),
            InkWell(
              onTap: () async {
                final date = await showDatePicker(
                  context: context,
                  initialDate: _startedAt,
                  firstDate: DateTime(2020),
                  lastDate: DateTime.now(),
                );
                if (date != null) {
                  setState(() {
                    _startedAt = DateTime(
                      date.year,
                      date.month,
                      date.day,
                      _startedAt.hour,
                      _startedAt.minute,
                    );
                  });
                }
              },
              child: InputDecorator(
                decoration: const InputDecoration(
                  labelText: 'Start Date',
                  border: OutlineInputBorder(),
                ),
                child: Text(DateFormatter.formatDate(_startedAt)),
              ),
            ),
            const SizedBox(height: 16),
            InkWell(
              onTap: () async {
                final time = await showTimePicker(
                  context: context,
                  initialTime: TimeOfDay.fromDateTime(_startedAt),
                );
                if (time != null) {
                  setState(() {
                    _startedAt = DateTime(
                      _startedAt.year,
                      _startedAt.month,
                      _startedAt.day,
                      time.hour,
                      time.minute,
                    );
                  });
                }
              },
              child: InputDecorator(
                decoration: const InputDecoration(
                  labelText: 'Start Time',
                  border: OutlineInputBorder(),
                ),
                child: Text(
                  '${_startedAt.hour.toString().padLeft(2, '0')}:${_startedAt.minute.toString().padLeft(2, '0')}',
                ),
              ),
            ),
            const SizedBox(height: 16),
            InkWell(
              onTap: () async {
                final date = await showDatePicker(
                  context: context,
                  initialDate: _endedAt ?? _startedAt,
                  firstDate: DateTime(2020),
                  lastDate: DateTime.now(),
                );
                if (date != null) {
                  setState(() {
                    _endedAt = DateTime(
                      date.year,
                      date.month,
                      date.day,
                      _endedAt?.hour ?? _startedAt.hour,
                      _endedAt?.minute ?? _startedAt.minute,
                    );
                  });
                }
              },
              child: InputDecorator(
                decoration: const InputDecoration(
                  labelText: 'End Date (optional)',
                  border: OutlineInputBorder(),
                ),
                child: Text(
                  _endedAt != null
                      ? DateFormatter.formatDate(_endedAt!)
                      : 'No end time',
                ),
              ),
            ),
            const SizedBox(height: 16),
            if (_endedAt != null)
              InkWell(
                onTap: () async {
                  final time = await showTimePicker(
                    context: context,
                    initialTime: TimeOfDay.fromDateTime(_endedAt!),
                  );
                  if (time != null) {
                    setState(() {
                      _endedAt = DateTime(
                        _endedAt!.year,
                        _endedAt!.month,
                        _endedAt!.day,
                        time.hour,
                        time.minute,
                      );
                    });
                  }
                },
                child: InputDecorator(
                  decoration: const InputDecoration(
                    labelText: 'End Time',
                    border: OutlineInputBorder(),
                  ),
                  child: Text(
                    '${_endedAt!.hour.toString().padLeft(2, '0')}:${_endedAt!.minute.toString().padLeft(2, '0')}',
                  ),
                ),
              ),
            const SizedBox(height: 16),
            SwitchListTile(
              title: const Text('Billable'),
              value: _isBillable,
              onChanged: (v) => setState(() => _isBillable = v),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _isLoading ? null : _saveEntry,
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 48),
              ),
              child: _isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Text(widget.entry != null ? 'Update' : 'Save Entry'),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Future<void> _saveEntry() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedProjectId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a project')),
      );
      return;
    }

    final user = SupabaseConfig.client.auth.currentUser;
    if (user == null) return;

    setState(() => _isLoading = true);
    try {
      final repo = ref.read(timeEntryRepositoryProvider);

      final newEntry = TimeEntry(
        id: widget.entry?.id,
        userId: user.id,
        projectId: _selectedProjectId!,
        clientId: _selectedClientId ?? '',
        description: _descriptionController.text.trim(),
        startedAt: _startedAt,
        endedAt: _endedAt,
        hourlyRate: _hourlyRate,
        isBillable: _isBillable,
        isBilled: widget.entry?.isBilled ?? false,
        createdAt: widget.entry?.createdAt ?? DateTime.now(),
      );

      if (widget.entry != null) {
        await repo.updateEntry(newEntry);
      } else {
        await repo.createManualEntry(newEntry);
      }

      if (mounted) {
        context.pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content:
                Text(widget.entry != null ? 'Entry updated' : 'Entry saved'),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }
}
