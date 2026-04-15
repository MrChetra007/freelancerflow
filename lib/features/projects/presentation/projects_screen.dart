import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../data/projects_provider.dart';
import '../domain/project.dart';
import 'widgets/project_card.dart';

class ProjectsScreen extends ConsumerWidget {
  const ProjectsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final projects = ref.watch(filteredProjectsProvider);
    final filter = ref.watch(projectStatusFilterProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Projects'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () => _showFilterOptions(context, ref),
          ),
        ],
      ),
      body: Column(
        children: [
          if (filter != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  Chip(
                    label: Text(_getStatusLabel(filter)),
                    deleteIcon: const Icon(Icons.close, size: 18),
                    onDeleted: () =>
                        ref.read(projectStatusFilterProvider.notifier).state =
                            null,
                  ),
                ],
              ),
            ),
          Expanded(
            child: projects.when(
              data: (list) {
                if (list.isEmpty) {
                  return _buildEmptyState(context, filter != null);
                }
                return RefreshIndicator(
                  onRefresh: () =>
                      ref.read(projectsProvider.notifier).refresh(),
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: list.length,
                    itemBuilder: (context, index) {
                      final project = list[index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: ProjectCard(
                          project: project,
                          onTap: () => context.push('/projects/${project.id}'),
                          onDelete: () => _confirmDelete(context, ref, project),
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
        onPressed: () => context.push('/projects/add'),
        icon: const Icon(Icons.add),
        label: const Text('Add Project'),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, bool isFiltered) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            isFiltered ? Icons.filter_list_off : Icons.folder_outlined,
            size: 64,
            color: AppColors.lightTextSecondary,
          ),
          const SizedBox(height: 16),
          Text(
            isFiltered ? 'No projects match filter' : 'No projects yet',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          Text(
            isFiltered ? 'Try a different filter' : 'Create your first project',
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
                ref.read(projectStatusFilterProvider.notifier).state = null;
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: Icon(
                Icons.play_circle_outline,
                color: AppColors.statusActive,
              ),
              title: const Text('In Progress'),
              onTap: () {
                ref.read(projectStatusFilterProvider.notifier).state =
                    ProjectStatus.inProgress;
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: Icon(
                Icons.check_circle_outline,
                color: AppColors.statusDone,
              ),
              title: const Text('Completed'),
              onTap: () {
                ref.read(projectStatusFilterProvider.notifier).state =
                    ProjectStatus.completed;
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: Icon(
                Icons.pause_circle_outline,
                color: AppColors.statusOnHold,
              ),
              title: const Text('On Hold'),
              onTap: () {
                ref.read(projectStatusFilterProvider.notifier).state =
                    ProjectStatus.onHold;
                Navigator.pop(context);
              },
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

  void _confirmDelete(BuildContext context, WidgetRef ref, Project project) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Project?'),
        content: Text('Are you sure you want to delete "${project.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              ref.read(projectsProvider.notifier).deleteProject(project.id);
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
