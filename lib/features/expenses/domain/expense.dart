import 'package:freezed_annotation/freezed_annotation.dart';

import 'expense_category.dart';

part 'expense.freezed.dart';
part 'expense.g.dart';

@freezed
class Expense with _$Expense {
  const factory Expense({
    String? id,
    required String userId,
    String? projectId,
    String? clientId,
    required ExpenseCategory category,
    required String description,
    required double amount,
    @Default('USD') String currency,
    required DateTime date,
    String? receiptUrl,
    @Default(false) bool isBillable,
    @Default(false) bool isBilled,
    String? invoiceId,
    String? notes,
    required DateTime createdAt,
  }) = _Expense;

  factory Expense.fromJson(Map<String, dynamic> json) =>
      _$ExpenseFromJson(json);
}
