// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'recurring_invoice.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$RecurringInvoiceImpl _$$RecurringInvoiceImplFromJson(
  Map<String, dynamic> json,
) => _$RecurringInvoiceImpl(
  id: json['id'] as String?,
  userId: json['user_id'] as String,
  clientId: json['client_id'] as String,
  projectId: json['project_id'] as String?,
  frequency: $enumDecode(_$RecurrenceFrequencyEnumMap, json['frequency']),
  nextIssueDate: DateTime.parse(json['next_issue_date'] as String),
  dueDays: (json['due_days'] as num?)?.toInt() ?? 30,
  isActive: json['is_active'] as bool? ?? true,
  lineItems:
      (json['line_items'] as List<dynamic>?)
          ?.map((e) => InvoiceLineItem.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
  taxPercent: (json['tax_percent'] as num?)?.toDouble() ?? 0,
  discountPercent: (json['discount_percent'] as num?)?.toDouble() ?? 0,
  currency: json['currency'] as String? ?? 'USD',
  notes: json['notes'] as String?,
  paymentTerms: json['payment_terms'] as String?,
  timesGenerated: (json['times_generated'] as num?)?.toInt() ?? 0,
  lastGeneratedAt: json['last_generated_at'] == null
      ? null
      : DateTime.parse(json['last_generated_at'] as String),
  createdAt: DateTime.parse(json['created_at'] as String),
);

Map<String, dynamic> _$$RecurringInvoiceImplToJson(
  _$RecurringInvoiceImpl instance,
) => <String, dynamic>{
  'id': instance.id,
  'user_id': instance.userId,
  'client_id': instance.clientId,
  'project_id': instance.projectId,
  'frequency': _$RecurrenceFrequencyEnumMap[instance.frequency]!,
  'next_issue_date': instance.nextIssueDate.toIso8601String(),
  'due_days': instance.dueDays,
  'is_active': instance.isActive,
  'line_items': instance.lineItems,
  'tax_percent': instance.taxPercent,
  'discount_percent': instance.discountPercent,
  'currency': instance.currency,
  'notes': instance.notes,
  'payment_terms': instance.paymentTerms,
  'times_generated': instance.timesGenerated,
  'last_generated_at': instance.lastGeneratedAt?.toIso8601String(),
  'created_at': instance.createdAt.toIso8601String(),
};

const _$RecurrenceFrequencyEnumMap = {
  RecurrenceFrequency.weekly: 'weekly',
  RecurrenceFrequency.biweekly: 'biweekly',
  RecurrenceFrequency.monthly: 'monthly',
  RecurrenceFrequency.quarterly: 'quarterly',
  RecurrenceFrequency.yearly: 'yearly',
};
