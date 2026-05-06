// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'invoice_item.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$InvoiceItemImpl _$$InvoiceItemImplFromJson(Map<String, dynamic> json) =>
    _$InvoiceItemImpl(
      id: json['id'] as String?,
      invoiceId: json['invoice_id'] as String,
      userId: json['user_id'] as String,
      description: json['description'] as String,
      quantity: (json['quantity'] as num?)?.toDouble() ?? 1,
      unitPrice: (json['unit_price'] as num?)?.toDouble() ?? 0,
      total: (json['total'] as num?)?.toDouble() ?? 0,
      sortOrder: (json['sort_order'] as num?)?.toInt() ?? 0,
      createdAt: DateTime.parse(json['created_at'] as String),
    );

Map<String, dynamic> _$$InvoiceItemImplToJson(_$InvoiceItemImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'invoice_id': instance.invoiceId,
      'user_id': instance.userId,
      'description': instance.description,
      'quantity': instance.quantity,
      'unit_price': instance.unitPrice,
      'total': instance.total,
      'sort_order': instance.sortOrder,
      'created_at': instance.createdAt.toIso8601String(),
    };
