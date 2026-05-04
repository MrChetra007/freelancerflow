import 'package:freezed_annotation/freezed_annotation.dart';

part 'invoice_line_item.freezed.dart';
part 'invoice_line_item.g.dart';

@freezed
class InvoiceLineItem with _$InvoiceLineItem {
  const factory InvoiceLineItem({
    required String description,
    @Default(1) double quantity,
    @Default(0) double unitPrice,
    @Default(0) int sortOrder,
  }) = _InvoiceLineItem;

  factory InvoiceLineItem.fromJson(Map<String, dynamic> json) =>
      _$InvoiceLineItemFromJson(json);
}
