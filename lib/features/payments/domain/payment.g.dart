// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'payment.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$PaymentImpl _$$PaymentImplFromJson(Map<String, dynamic> json) =>
    _$PaymentImpl(
      id: json['id'] as String?,
      userId: json['user_id'] as String,
      clientId: json['client_id'] as String,
      projectId: json['project_id'] as String?,
      amount: (json['amount'] as num).toDouble(),
      amountPaid: (json['amount_paid'] as num?)?.toDouble() ?? 0,
      currency: json['currency'] as String? ?? 'USD',
      status:
          $enumDecodeNullable(_$PaymentStatusEnumMap, json['status']) ??
          PaymentStatus.unpaid,
      method: $enumDecodeNullable(_$PaymentMethodEnumMap, json['method']),
      dueDate: json['due_date'] == null
          ? null
          : DateTime.parse(json['due_date'] as String),
      paidDate: json['paid_date'] == null
          ? null
          : DateTime.parse(json['paid_date'] as String),
      description: json['description'] as String?,
      referenceNo: json['reference_no'] as String?,
      notes: json['notes'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: json['updated_at'] == null
          ? null
          : DateTime.parse(json['updated_at'] as String),
    );

Map<String, dynamic> _$$PaymentImplToJson(_$PaymentImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'user_id': instance.userId,
      'client_id': instance.clientId,
      'project_id': instance.projectId,
      'amount': instance.amount,
      'amount_paid': instance.amountPaid,
      'currency': instance.currency,
      'status': _$PaymentStatusEnumMap[instance.status]!,
      'method': _$PaymentMethodEnumMap[instance.method],
      'due_date': instance.dueDate?.toIso8601String(),
      'paid_date': instance.paidDate?.toIso8601String(),
      'description': instance.description,
      'reference_no': instance.referenceNo,
      'notes': instance.notes,
      'created_at': instance.createdAt.toIso8601String(),
      'updated_at': instance.updatedAt?.toIso8601String(),
    };

const _$PaymentStatusEnumMap = {
  PaymentStatus.paid: 'paid',
  PaymentStatus.unpaid: 'unpaid',
  PaymentStatus.partial: 'partial',
  PaymentStatus.overdue: 'overdue',
  PaymentStatus.refunded: 'refunded',
};

const _$PaymentMethodEnumMap = {
  PaymentMethod.bankTransfer: 'bank_transfer',
  PaymentMethod.paypal: 'paypal',
  PaymentMethod.wise: 'wise',
  PaymentMethod.crypto: 'crypto',
  PaymentMethod.cash: 'cash',
  PaymentMethod.stripe: 'stripe',
  PaymentMethod.other: 'other',
};
