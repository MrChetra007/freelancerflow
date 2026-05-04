import 'package:freezed_annotation/freezed_annotation.dart';

import 'invoice_line_item.dart';
import 'recurrence_frequency.dart';

part 'recurring_invoice.freezed.dart';
part 'recurring_invoice.g.dart';

@freezed
class RecurringInvoice with _$RecurringInvoice {
  const factory RecurringInvoice({
    String? id,
    required String userId,
    required String clientId,
    String? projectId,
    required RecurrenceFrequency frequency,
    required DateTime nextIssueDate,
    @Default(30) int dueDays,
    @Default(true) bool isActive,
    @Default([]) List<InvoiceLineItem> lineItems,
    @Default(0) double taxPercent,
    @Default(0) double discountPercent,
    @Default('USD') String currency,
    String? notes,
    String? paymentTerms,
    @Default(0) int timesGenerated,
    DateTime? lastGeneratedAt,
    required DateTime createdAt,
  }) = _RecurringInvoice;

  factory RecurringInvoice.fromJson(Map<String, dynamic> json) =>
      _$RecurringInvoiceFromJson(json);
}
