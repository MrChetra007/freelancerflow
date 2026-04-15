// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'payment.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$PaymentImpl _$$PaymentImplFromJson(Map<String, dynamic> json) =>
    _$PaymentImpl(
      id: json['id'] as String,
      userId: json['userId'] as String,
      clientId: json['clientId'] as String,
      projectId: json['projectId'] as String?,
      amount: (json['amount'] as num).toDouble(),
      amountPaid: (json['amountPaid'] as num?)?.toDouble() ?? 0,
      currency: json['currency'] as String? ?? 'USD',
      status:
          $enumDecodeNullable(_$PaymentStatusEnumMap, json['status']) ??
          PaymentStatus.unpaid,
      method: $enumDecodeNullable(_$PaymentMethodEnumMap, json['method']),
      dueDate: json['dueDate'] == null
          ? null
          : DateTime.parse(json['dueDate'] as String),
      paidDate: json['paidDate'] == null
          ? null
          : DateTime.parse(json['paidDate'] as String),
      description: json['description'] as String?,
      referenceNo: json['referenceNo'] as String?,
      notes: json['notes'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] == null
          ? null
          : DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$$PaymentImplToJson(_$PaymentImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'userId': instance.userId,
      'clientId': instance.clientId,
      'projectId': instance.projectId,
      'amount': instance.amount,
      'amountPaid': instance.amountPaid,
      'currency': instance.currency,
      'status': _$PaymentStatusEnumMap[instance.status]!,
      'method': _$PaymentMethodEnumMap[instance.method],
      'dueDate': instance.dueDate?.toIso8601String(),
      'paidDate': instance.paidDate?.toIso8601String(),
      'description': instance.description,
      'referenceNo': instance.referenceNo,
      'notes': instance.notes,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt?.toIso8601String(),
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
