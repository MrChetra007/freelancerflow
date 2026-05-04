import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/supabase/supabase_client.dart';
import '../domain/time_entry.dart';

class TimeEntryRepository {
  Future<TimeEntry?> getActiveTimer(String userId) async {
    final result = await SupabaseConfig.client
        .from('time_entries')
        .select()
        .eq('user_id', userId)
        .isFilter('ended_at', null)
        .maybeSingle();
    if (result == null) return null;
    return TimeEntry.fromJson(result);
  }

  Future<TimeEntry> startTimer({
    required String projectId,
    required String clientId,
    required double hourlyRate,
    String? description,
  }) async {
    final user = SupabaseConfig.client.auth.currentUser!;
    final data = {
      'user_id': user.id,
      'project_id': projectId,
      'client_id': clientId,
      'description': description,
      'started_at': DateTime.now().toIso8601String(),
      'hourly_rate': hourlyRate,
      'is_billable': true,
      'is_billed': false,
    };
    final result = await SupabaseConfig.client
        .from('time_entries')
        .insert(data)
        .select()
        .single();
    return TimeEntry.fromJson(result);
  }

  Future<TimeEntry> stopTimer(String entryId) async {
    final endedAt = DateTime.now();
    final result = await SupabaseConfig.client
        .from('time_entries')
        .update({'ended_at': endedAt.toIso8601String()})
        .eq('id', entryId)
        .select()
        .single();
    return TimeEntry.fromJson(result);
  }

  Future<TimeEntry> createManualEntry(TimeEntry entry) async {
    final data = entry.toJson()..remove('id');
    final result = await SupabaseConfig.client
        .from('time_entries')
        .insert(data)
        .select()
        .single();
    return TimeEntry.fromJson(result);
  }

  Future<List<TimeEntry>?> getAllUnbilled(String userId) async {
    final result = await SupabaseConfig.client
        .from('time_entries')
        .select()
        .eq('user_id', userId)
        .eq('is_billed', false)
        .not('ended_at', 'is', null)
        .order('started_at', ascending: false);
    return result.map((e) => TimeEntry.fromJson(e)).toList();
  }

  Future<List<TimeEntry>?> getUnbilledForClient(String clientId) async {
    final result = await SupabaseConfig.client
        .from('time_entries')
        .select()
        .eq('client_id', clientId)
        .eq('is_billed', false)
        .not('ended_at', 'is', null)
        .order('started_at', ascending: false);
    return result.map((e) => TimeEntry.fromJson(e)).toList();
  }

  Future<List<TimeEntry>?> getUnbilledForProject(String projectId) async {
    final result = await SupabaseConfig.client
        .from('time_entries')
        .select()
        .eq('project_id', projectId)
        .eq('is_billed', false)
        .not('ended_at', 'is', null)
        .order('started_at', ascending: false);
    return result.map((e) => TimeEntry.fromJson(e)).toList();
  }

  Future<void> markAsBilled(List<String> entryIds, String invoiceId) async {
    await SupabaseConfig.client
        .from('time_entries')
        .update({'is_billed': true, 'invoice_id': invoiceId})
        .filter('id', 'in', entryIds);
  }

  Stream<List<TimeEntry>> watchEntriesForProject(String projectId) {
    return SupabaseConfig.client
        .from('time_entries')
        .stream(primaryKey: ['id'])
        .eq('project_id', projectId)
        .order('started_at')
        .map((data) => data.map((e) => TimeEntry.fromJson(e)).toList());
  }

  Future<int> getCountThisMonth(String userId) async {
    final now = DateTime.now();
    final startOfMonth = DateTime(now.year, now.month, 1);
    final result = await SupabaseConfig.client
        .from('time_entries')
        .select()
        .eq('user_id', userId)
        .gte('created_at', startOfMonth.toIso8601String());
    return result.length;
  }

  Future<void> delete(String entryId) async {
    await SupabaseConfig.client
        .from('time_entries')
        .delete()
        .eq('id', entryId);
  }
}
