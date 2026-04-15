import 'package:supabase_flutter/supabase_flutter.dart';
import '../domain/payment.dart';

class PaymentRepository {
  final SupabaseClient _client;

  PaymentRepository(this._client);

  Future<List<Payment>> getPayments() async {
    final response = await _client
        .from('payments')
        .select()
        .order('created_at', ascending: false);
    return response.map((json) => _fromDb(json)).toList();
  }

  Future<List<Payment>> getPaymentsByClient(String clientId) async {
    final response = await _client
        .from('payments')
        .select()
        .eq('client_id', clientId)
        .order('created_at', ascending: false);
    return response.map((json) => _fromDb(json)).toList();
  }

  Future<List<Payment>> getPaymentsByProject(String projectId) async {
    final response = await _client
        .from('payments')
        .select()
        .eq('project_id', projectId)
        .order('created_at', ascending: false);
    return response.map((json) => _fromDb(json)).toList();
  }

  Future<Payment?> getPayment(String id) async {
    final response = await _client
        .from('payments')
        .select()
        .eq('id', id)
        .single();
    return _fromDb(response);
  }

  Future<Payment> createPayment(Payment payment) async {
    final response = await _client
        .from('payments')
        .insert({
          'id': payment.id,
          'user_id': payment.userId,
          'client_id': payment.clientId,
          'project_id': payment.projectId,
          'amount': payment.amount,
          'amount_paid': payment.amountPaid,
          'currency': payment.currency,
          'status': payment.status.name,
          'method': payment.method?.name.replaceAll('_', ' '),
          'due_date': payment.dueDate?.toIso8601String().split('T')[0],
          'paid_date': payment.paidDate?.toIso8601String().split('T')[0],
          'description': payment.description,
          'reference_no': payment.referenceNo,
          'notes': payment.notes,
        })
        .select()
        .single();
    return _fromDb(response);
  }

  Future<Payment> updatePayment(Payment payment) async {
    final response = await _client
        .from('payments')
        .update({
          'client_id': payment.clientId,
          'project_id': payment.projectId,
          'amount': payment.amount,
          'amount_paid': payment.amountPaid,
          'currency': payment.currency,
          'status': payment.status.name,
          'method': payment.method?.name.replaceAll('_', ' '),
          'due_date': payment.dueDate?.toIso8601String().split('T')[0],
          'paid_date': payment.paidDate?.toIso8601String().split('T')[0],
          'description': payment.description,
          'reference_no': payment.referenceNo,
          'notes': payment.notes,
        })
        .eq('id', payment.id)
        .select()
        .single();
    return _fromDb(response);
  }

  Future<void> deletePayment(String id) async {
    await _client.from('payments').delete().eq('id', id);
  }

  Payment _fromDb(Map<String, dynamic> json) {
    return Payment(
      id: json['id'],
      userId: json['user_id'],
      clientId: json['client_id'],
      projectId: json['project_id'],
      amount: (json['amount'] ?? 0).toDouble(),
      amountPaid: (json['amount_paid'] ?? 0).toDouble(),
      currency: json['currency'] ?? 'USD',
      status: _parseStatus(json['status']),
      method: _parseMethod(json['method']),
      dueDate: json['due_date'] != null
          ? DateTime.parse(json['due_date'])
          : null,
      paidDate: json['paid_date'] != null
          ? DateTime.parse(json['paid_date'])
          : null,
      description: json['description'],
      referenceNo: json['reference_no'],
      notes: json['notes'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'])
          : null,
    );
  }

  PaymentStatus _parseStatus(String? status) {
    return switch (status) {
      'paid' => PaymentStatus.paid,
      'unpaid' => PaymentStatus.unpaid,
      'partial' => PaymentStatus.partial,
      'overdue' => PaymentStatus.overdue,
      'refunded' => PaymentStatus.refunded,
      _ => PaymentStatus.unpaid,
    };
  }

  PaymentMethod? _parseMethod(String? method) {
    if (method == null) return null;
    return switch (method) {
      'bank_transfer' => PaymentMethod.bankTransfer,
      'paypal' => PaymentMethod.paypal,
      'wise' => PaymentMethod.wise,
      'crypto' => PaymentMethod.crypto,
      'cash' => PaymentMethod.cash,
      'stripe' => PaymentMethod.stripe,
      'other' => PaymentMethod.other,
      _ => null,
    };
  }
}
