import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/supabase/supabase_client.dart';
import '../domain/expense.dart';
import '../domain/expense_category.dart';
import 'expense_repository.dart';

part 'expense_provider.g.dart';

@riverpod
ExpenseRepository expenseRepository(Ref ref) => ExpenseRepository();

@riverpod
Future<List<Expense>> expenses(
  Ref ref, {
  String? projectId,
  String? clientId,
  ExpenseCategory? category,
  bool? isBillable,
  bool? isBilled,
}) async {
  return ref.read(expenseRepositoryProvider).getExpenses(
        projectId: projectId,
        clientId: clientId,
        category: category,
        isBillable: isBillable,
        isBilled: isBilled,
      );
}

@riverpod
Future<List<Map<String, dynamic>>> expenseBreakdown(
    Ref ref, int months) async {
  final user = SupabaseConfig.client.auth.currentUser;
  if (user == null) return [];
  return ref.read(expenseRepositoryProvider).getBreakdown(user.id, months);
}

@riverpod
Future<List<Expense>> unbilledBillableExpenses(
  Ref ref,
  String clientId,
) async {
  return ref.read(expenseRepositoryProvider).getExpenses(
        clientId: clientId,
        isBillable: true,
        isBilled: false,
      );
}
