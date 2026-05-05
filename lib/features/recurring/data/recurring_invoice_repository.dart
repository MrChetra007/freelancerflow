import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/supabase/supabase_client.dart';
import '../domain/recurring_invoice.dart';

class RecurringInvoiceRepository {
  final SupabaseClient _client = SupabaseConfig.client;

  Future<List<RecurringInvoice>?> getRecurringInvoices(String userId) async {
    final result = await _client
        .from('recurring_invoices')
        .select()
        .eq('user_id', userId)
        .order('next_issue_date');
    return result.map((e) => RecurringInvoice.fromJson(e)).toList();
  }

  Future<RecurringInvoice> create(RecurringInvoice invoice) async {
    final data = invoice.toJson()..remove('id');
    final result = await _client
        .from('recurring_invoices')
        .insert(data)
        .select()
        .single();
    return RecurringInvoice.fromJson(result);
  }

  Future<RecurringInvoice> update(RecurringInvoice invoice) async {
    final result = await _client
        .from('recurring_invoices')
        .update(invoice.toJson()..remove('id'))
        .eq('id', invoice.id!)
        .select()
        .single();
    return RecurringInvoice.fromJson(result);
  }

  Future<void> toggleActive(String id, bool isActive) async {
    await _client
        .from('recurring_invoices')
        .update({'is_active': isActive})
        .eq('id', id);
  }

  Future<List<Map<String, dynamic>>> getDueInvoices(String userId) async {
    final result = await _client.rpc(
      'get_due_recurring_invoices',
      params: {'p_user_id': userId},
    );
    return List<Map<String, dynamic>>.from(result);
  }

  Future<void> advanceSchedule(String recurringId) async {
    await _client.rpc(
      'advance_recurring_invoice',
      params: {'p_recurring_id': recurringId},
    );
  }

  Future<void> delete(String id) async {
    await _client.from('recurring_invoices').delete().eq('id', id);
  }
}
