import 'package:freezed_annotation/freezed_annotation.dart';

part 'invoice.freezed.dart';
part 'invoice.g.dart';

enum InvoiceStatus {
  @JsonValue('draft')
  draft,
  @JsonValue('sent')
  sent,
  @JsonValue('paid')
  paid,
  @JsonValue('overdue')
  overdue,
  @JsonValue('cancelled')
  cancelled,
}

@freezed
class Invoice with _$Invoice {
  const factory Invoice({
    required String id,
    required String userId,
    required String clientId,
    String? projectId,
    required String invoiceNumber,
    @Default(InvoiceStatus.draft) InvoiceStatus status,
    required DateTime issueDate,
    DateTime? dueDate,
    @Default(0) double subtotal,
    @Default(0) double taxPercent,
    @Default(0) double taxAmount,
    @Default(0) double discountPercent,
    @Default(0) double discountAmount,
    @Default(0) double total,
    @Default('USD') String currency,
    String? notes,
    String? paymentTerms,
    String? pdfUrl,
    DateTime? sentAt,
    DateTime? paidAt,
    required DateTime createdAt,
    DateTime? updatedAt,
  }) = _Invoice;

  factory Invoice.fromJson(Map<String, dynamic> json) =>
      _$InvoiceFromJson(json);
}
