import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/supabase/supabase_client.dart';
import '../data/project_repository.dart';
import '../domain/project.dart';
import '../domain/milestone.dart';

final projectRepositoryProvider = Provider<ProjectRepository>((ref) {
  return ProjectRepository(SupabaseConfig.client);
});

final projectsProvider = AsyncNotifierProvider<ProjectsNotifier, List<Project>>(
  () {
    return ProjectsNotifier();
  },
);

class ProjectsNotifier extends AsyncNotifier<List<Project>> {
  @override
  Future<List<Project>> build() async {
    final repo = ref.watch(projectRepositoryProvider);
    return repo.getProjects();
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref.read(projectRepositoryProvider).getProjects(),
    );
  }

  Future<void> addProject(Project project) async {
    final repo = ref.read(projectRepositoryProvider);
    await repo.createProject(project);
    await refresh();
  }

  Future<void> updateProject(Project project) async {
    final repo = ref.read(projectRepositoryProvider);
    await repo.updateProject(project);
    await refresh();
  }

  Future<void> deleteProject(String id) async {
    final repo = ref.read(projectRepositoryProvider);
    await repo.deleteProject(id);
    await refresh();
  }
}

final projectStatusFilterProvider = StateProvider<ProjectStatus?>(
  (ref) => null,
);

final filteredProjectsProvider = Provider<AsyncValue<List<Project>>>((ref) {
  final projects = ref.watch(projectsProvider);
  final filter = ref.watch(projectStatusFilterProvider);

  return projects.whenData((list) {
    if (filter == null) return list;
    return list.where((p) => p.status == filter).toList();
  });
});

final milestonesProvider = FutureProvider.family<List<Milestone>, String>((
  ref,
  projectId,
) async {
  final repo = ref.watch(projectRepositoryProvider);
  return repo.getMilestones(projectId);
});

final milestonesNotifierProvider =
    AsyncNotifierProvider.family<MilestonesNotifier, List<Milestone>, String>(
      () {
        return MilestonesNotifier();
      },
    );

class MilestonesNotifier extends FamilyAsyncNotifier<List<Milestone>, String> {
  @override
  Future<List<Milestone>> build(String arg) async {
    final repo = ref.watch(projectRepositoryProvider);
    return repo.getMilestones(arg);
  }

  Future<void> addMilestone(Milestone milestone) async {
    final repo = ref.read(projectRepositoryProvider);
    await repo.createMilestone(milestone);
    ref.invalidateSelf();
  }

  Future<void> toggleMilestone(Milestone milestone) async {
    final repo = ref.read(projectRepositoryProvider);
    final updated = milestone.copyWith(
      isCompleted: !milestone.isCompleted,
      completedAt: !milestone.isCompleted ? DateTime.now() : null,
    );
    await repo.updateMilestone(updated);
    ref.invalidateSelf();
  }

  Future<void> deleteMilestone(String id) async {
    final repo = ref.read(projectRepositoryProvider);
    await repo.deleteMilestone(id);
    ref.invalidateSelf();
  }
}
