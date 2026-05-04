// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'recurring_invoice.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$RecurringInvoiceImpl _$$RecurringInvoiceImplFromJson(
  Map<String, dynamic> json,
) => _$RecurringInvoiceImpl(
  id: json['id'] as String?,
  userId: json['userId'] as String,
  clientId: json['clientId'] as String,
  projectId: json['projectId'] as String?,
  frequency: $enumDecode(_$RecurrenceFrequencyEnumMap, json['frequency']),
  nextIssueDate: DateTime.parse(json['nextIssueDate'] as String),
  dueDays: (json['dueDays'] as num?)?.toInt() ?? 30,
  isActive: json['isActive'] as bool? ?? true,
  lineItems:
      (json['lineItems'] as List<dynamic>?)
          ?.map((e) => InvoiceLineItem.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
  taxPercent: (json['taxPercent'] as num?)?.toDouble() ?? 0,
  discountPercent: (json['discountPercent'] as num?)?.toDouble() ?? 0,
  currency: json['currency'] as String? ?? 'USD',
  notes: json['notes'] as String?,
  paymentTerms: json['paymentTerms'] as String?,
  timesGenerated: (json['timesGenerated'] as num?)?.toInt() ?? 0,
  lastGeneratedAt: json['lastGeneratedAt'] == null
      ? null
      : DateTime.parse(json['lastGeneratedAt'] as String),
  createdAt: DateTime.parse(json['createdAt'] as String),
);

Map<String, dynamic> _$$RecurringInvoiceImplToJson(
  _$RecurringInvoiceImpl instance,
) => <String, dynamic>{
  'id': instance.id,
  'userId': instance.userId,
  'clientId': instance.clientId,
  'projectId': instance.projectId,
  'frequency': _$RecurrenceFrequencyEnumMap[instance.frequency]!,
  'nextIssueDate': instance.nextIssueDate.toIso8601String(),
  'dueDays': instance.dueDays,
  'isActive': instance.isActive,
  'lineItems': instance.lineItems,
  'taxPercent': instance.taxPercent,
  'discountPercent': instance.discountPercent,
  'currency': instance.currency,
  'notes': instance.notes,
  'paymentTerms': instance.paymentTerms,
  'timesGenerated': instance.timesGenerated,
  'lastGeneratedAt': instance.lastGeneratedAt?.toIso8601String(),
  'createdAt': instance.createdAt.toIso8601String(),
};

const _$RecurrenceFrequencyEnumMap = {
  RecurrenceFrequency.weekly: 'weekly',
  RecurrenceFrequency.biweekly: 'biweekly',
  RecurrenceFrequency.monthly: 'monthly',
  RecurrenceFrequency.quarterly: 'quarterly',
  RecurrenceFrequency.yearly: 'yearly',
};
