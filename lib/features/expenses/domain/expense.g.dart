// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'expense.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ExpenseImpl _$$ExpenseImplFromJson(Map<String, dynamic> json) =>
    _$ExpenseImpl(
      id: json['id'] as String?,
      userId: json['user_id'] as String,
      projectId: json['project_id'] as String?,
      clientId: json['client_id'] as String?,
      category: $enumDecode(_$ExpenseCategoryEnumMap, json['category']),
      description: json['description'] as String,
      amount: (json['amount'] as num).toDouble(),
      currency: json['currency'] as String? ?? 'USD',
      date: DateTime.parse(json['date'] as String),
      receiptUrl: json['receipt_url'] as String?,
      isBillable: json['is_billable'] as bool? ?? false,
      isBilled: json['is_billed'] as bool? ?? false,
      invoiceId: json['invoice_id'] as String?,
      notes: json['notes'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
    );

Map<String, dynamic> _$$ExpenseImplToJson(_$ExpenseImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'user_id': instance.userId,
      'project_id': instance.projectId,
      'client_id': instance.clientId,
      'category': _$ExpenseCategoryEnumMap[instance.category]!,
      'description': instance.description,
      'amount': instance.amount,
      'currency': instance.currency,
      'date': instance.date.toIso8601String(),
      'receipt_url': instance.receiptUrl,
      'is_billable': instance.isBillable,
      'is_billed': instance.isBilled,
      'invoice_id': instance.invoiceId,
      'notes': instance.notes,
      'created_at': instance.createdAt.toIso8601String(),
    };

const _$ExpenseCategoryEnumMap = {
  ExpenseCategory.software: 'software',
  ExpenseCategory.hardware: 'hardware',
  ExpenseCategory.travel: 'travel',
  ExpenseCategory.accommodation: 'accommodation',
  ExpenseCategory.meals: 'meals',
  ExpenseCategory.marketing: 'marketing',
  ExpenseCategory.freelancer: 'freelancer',
  ExpenseCategory.office: 'office',
  ExpenseCategory.other: 'other',
};
