// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'invoice_line_item.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$InvoiceLineItemImpl _$$InvoiceLineItemImplFromJson(
  Map<String, dynamic> json,
) => _$InvoiceLineItemImpl(
  description: json['description'] as String,
  quantity: (json['quantity'] as num?)?.toDouble() ?? 1,
  unitPrice: (json['unit_price'] as num?)?.toDouble() ?? 0,
  sortOrder: (json['sort_order'] as num?)?.toInt() ?? 0,
);

Map<String, dynamic> _$$InvoiceLineItemImplToJson(
  _$InvoiceLineItemImpl instance,
) => <String, dynamic>{
  'description': instance.description,
  'quantity': instance.quantity,
  'unit_price': instance.unitPrice,
  'sort_order': instance.sortOrder,
};
