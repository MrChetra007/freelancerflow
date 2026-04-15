import 'package:freezed_annotation/freezed_annotation.dart';

part 'payment.freezed.dart';
part 'payment.g.dart';

enum PaymentStatus {
  @JsonValue('paid')
  paid,
  @JsonValue('unpaid')
  unpaid,
  @JsonValue('partial')
  partial,
  @JsonValue('overdue')
  overdue,
  @JsonValue('refunded')
  refunded,
}

enum PaymentMethod {
  @JsonValue('bank_transfer')
  bankTransfer,
  @JsonValue('paypal')
  paypal,
  @JsonValue('wise')
  wise,
  @JsonValue('crypto')
  crypto,
  @JsonValue('cash')
  cash,
  @JsonValue('stripe')
  stripe,
  @JsonValue('other')
  other,
}

@freezed
class Payment with _$Payment {
  const factory Payment({
    String? id,
    required String userId,
    required String clientId,
    String? projectId,
    required double amount,
    @Default(0) double amountPaid,
    @Default('USD') String currency,
    @Default(PaymentStatus.unpaid) PaymentStatus status,
    PaymentMethod? method,
    DateTime? dueDate,
    DateTime? paidDate,
    String? description,
    String? referenceNo,
    String? notes,
    required DateTime createdAt,
    DateTime? updatedAt,
  }) = _Payment;

  factory Payment.fromJson(Map<String, dynamic> json) =>
      _$PaymentFromJson(json);
}
