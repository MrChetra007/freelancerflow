// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'expense.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ExpenseImpl _$$ExpenseImplFromJson(Map<String, dynamic> json) =>
    _$ExpenseImpl(
      id: json['id'] as String?,
      userId: json['userId'] as String,
      projectId: json['projectId'] as String?,
      clientId: json['clientId'] as String?,
      category: $enumDecode(_$ExpenseCategoryEnumMap, json['category']),
      description: json['description'] as String,
      amount: (json['amount'] as num).toDouble(),
      currency: json['currency'] as String? ?? 'USD',
      date: DateTime.parse(json['date'] as String),
      receiptUrl: json['receiptUrl'] as String?,
      isBillable: json['isBillable'] as bool? ?? false,
      isBilled: json['isBilled'] as bool? ?? false,
      invoiceId: json['invoiceId'] as String?,
      notes: json['notes'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );

Map<String, dynamic> _$$ExpenseImplToJson(_$ExpenseImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'userId': instance.userId,
      'projectId': instance.projectId,
      'clientId': instance.clientId,
      'category': _$ExpenseCategoryEnumMap[instance.category]!,
      'description': instance.description,
      'amount': instance.amount,
      'currency': instance.currency,
      'date': instance.date.toIso8601String(),
      'receiptUrl': instance.receiptUrl,
      'isBillable': instance.isBillable,
      'isBilled': instance.isBilled,
      'invoiceId': instance.invoiceId,
      'notes': instance.notes,
      'createdAt': instance.createdAt.toIso8601String(),
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
