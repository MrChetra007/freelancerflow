import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/supabase/supabase_client.dart';
import '../domain/time_entry.dart';
import 'time_entry_repository.dart';

part 'time_entry_provider.g.dart';

@riverpod
TimeEntryRepository timeEntryRepository(Ref ref) => TimeEntryRepository();

@riverpod
Future<TimeEntry?> activeTimer(Ref ref) async {
  final user = SupabaseConfig.client.auth.currentUser;
  if (user == null) return null;
  return ref.read(timeEntryRepositoryProvider).getActiveTimer(user.id);
}

@riverpod
Future<List<TimeEntry>> unbilledTimeEntries(Ref ref, String clientId) async {
  final result = await ref
      .read(timeEntryRepositoryProvider)
      .getUnbilledForClient(clientId);
  return result ?? [];
}

@riverpod
Future<List<TimeEntry>> allUnbilledTimeEntries(Ref ref) async {
  final user = SupabaseConfig.client.auth.currentUser;
  if (user == null) return [];
  final result = await ref
      .read(timeEntryRepositoryProvider)
      .getAllUnbilled(user.id);
  return result ?? [];
}

@riverpod
Future<List<TimeEntry>> clientTimeEntries(Ref ref, String clientId) async {
  final result = await ref
      .read(timeEntryRepositoryProvider)
      .getByClient(clientId);
  return result ?? [];
}

@riverpod
Stream<List<TimeEntry>> projectTimeEntries(Ref ref, String projectId) {
  return ref
      .read(timeEntryRepositoryProvider)
      .watchEntriesForProject(projectId);
}
