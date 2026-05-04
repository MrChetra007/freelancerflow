import 'dart:io';

import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/supabase/supabase_client.dart';
import '../domain/expense.dart';
import '../domain/expense_category.dart';

class ExpenseRepository {
  Future<Expense> create(Expense expense, {File? receiptFile}) async {
    final data = expense.toJson()..remove('id');
    String? receiptUrl;
    if (receiptFile != null) {
      receiptUrl = await _uploadReceipt(receiptFile, expense.userId);
      data['receipt_url'] = receiptUrl;
    }
    final result = await SupabaseConfig.client
        .from('expenses')
        .insert(data)
        .select()
        .single();
    return Expense.fromJson(result);
  }

  Future<List<Expense>> getExpenses({
    String? projectId,
    String? clientId,
    ExpenseCategory? category,
    bool? isBillable,
    bool? isBilled,
  }) async {
    PostgrestFilterBuilder<PostgrestList> query = SupabaseConfig.client
        .from('expenses')
        .select();

    if (projectId != null) query = query.eq('project_id', projectId);
    if (clientId != null) query = query.eq('client_id', clientId);
    if (category != null) query = query.eq('category', category.name);
    if (isBillable != null) query = query.eq('is_billable', isBillable);
    if (isBilled != null) query = query.eq('is_billed', isBilled);

    final result = await query.order('date', ascending: false);
    return result.map((e) => Expense.fromJson(e)).toList();
  }

  Future<List<Map<String, dynamic>>> getBreakdown(
    String userId,
    int months,
  ) async {
    final result = await SupabaseConfig.client.rpc(
      'get_expense_breakdown',
      params: {'p_user_id': userId, 'p_months': months},
    );
    return List<Map<String, dynamic>>.from(result);
  }

  Future<int> getCountThisMonth(String userId) async {
    final now = DateTime.now();
    final startOfMonth = DateTime(now.year, now.month, 1);
    final result = await SupabaseConfig.client
        .from('expenses')
        .select()
        .eq('user_id', userId)
        .gte('date', startOfMonth.toIso8601String());
    return result.length;
  }

  Future<void> markAsBilled(List<String> expenseIds, String invoiceId) async {
    await SupabaseConfig.client
        .from('expenses')
        .update({'is_billed': true, 'invoice_id': invoiceId})
        .filter('id', 'in', expenseIds);
  }

  Future<void> delete(String id) async {
    await SupabaseConfig.client.from('expenses').delete().eq('id', id);
  }

  Future<String> _uploadReceipt(File file, String userId) async {
    final fileName = '${userId}/${DateTime.now().millisecondsSinceEpoch}.jpg';
    await SupabaseConfig.client.storage.from('receipts').upload(fileName, file);
    return SupabaseConfig.client.storage
        .from('receipts')
        .getPublicUrl(fileName);
  }
}
