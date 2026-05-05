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
Future<List<TimeEntry>> allTimeEntries(Ref ref) async {
  final user = SupabaseConfig.client.auth.currentUser;
  if (user == null) return [];
  return ref.read(timeEntryRepositoryProvider).getAll(user.id);
}

@riverpod
Stream<List<TimeEntry>> watchAllTimeEntries(Ref ref) {
  final user = SupabaseConfig.client.auth.currentUser;
  if (user == null) return Stream.value([]);
  return ref.read(timeEntryRepositoryProvider).watchAllEntries(user.id);
}

@riverpod
Future<List<TimeEntry>> thisWeekTimeEntries(Ref ref) async {
  final user = SupabaseConfig.client.auth.currentUser;
  if (user == null) return [];
  final all = await ref.read(timeEntryRepositoryProvider).getAll(user.id);
  final now = DateTime.now();
  final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
  final thisWeekStart = DateTime(startOfWeek.year, startOfWeek.month, startOfWeek.day);
  return all.where((e) => !e.startedAt.isBefore(thisWeekStart)).toList();
}

@riverpod
Future<List<TimeEntry>> thisMonthTimeEntries(Ref ref) async {
  final user = SupabaseConfig.client.auth.currentUser;
  if (user == null) return [];
  final all = await ref.read(timeEntryRepositoryProvider).getAll(user.id);
  final now = DateTime.now();
  final startOfMonth = DateTime(now.year, now.month, 1);
  return all.where((e) => !e.startedAt.isBefore(startOfMonth)).toList();
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
