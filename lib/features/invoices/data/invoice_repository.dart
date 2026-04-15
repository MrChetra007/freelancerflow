import 'package:supabase_flutter/supabase_flutter.dart';
import '../domain/invoice.dart';
import '../domain/invoice_item.dart';

class InvoiceRepository {
  final SupabaseClient _client;

  InvoiceRepository(this._client);

  Future<List<Invoice>> getInvoices() async {
    final response = await _client
        .from('invoices')
        .select()
        .order('created_at', ascending: false);
    return response.map((json) => _invoiceFromDb(json)).toList();
  }

  Future<Invoice?> getInvoice(String id) async {
    final response = await _client
        .from('invoices')
        .select()
        .eq('id', id)
        .single();
    return _invoiceFromDb(response);
  }

  Future<List<Invoice>> getInvoicesByClient(String clientId) async {
    final response = await _client
        .from('invoices')
        .select()
        .eq('client_id', clientId)
        .order('created_at', ascending: false);
    return response.map((json) => _invoiceFromDb(json)).toList();
  }

  Future<Invoice> createInvoice(Invoice invoice) async {
    final response = await _client
        .from('invoices')
        .insert({
          'user_id': invoice.userId,
          'client_id': invoice.clientId,
          'project_id': invoice.projectId,
          'invoice_number': invoice.invoiceNumber,
          'status': invoice.status.name,
          'issue_date': invoice.issueDate.toIso8601String().split('T')[0],
          'due_date': invoice.dueDate?.toIso8601String().split('T')[0],
          'subtotal': invoice.subtotal,
          'tax_percent': invoice.taxPercent,
          'tax_amount': invoice.taxAmount,
          'discount_percent': invoice.discountPercent,
          'discount_amount': invoice.discountAmount,
          'total': invoice.total,
          'currency': invoice.currency,
          'notes': invoice.notes,
          'payment_terms': invoice.paymentTerms,
          'sent_at': invoice.sentAt?.toIso8601String(),
          'paid_at': invoice.paidAt?.toIso8601String(),
        })
        .select()
        .single();
    return _invoiceFromDb(response);
  }

  Future<Invoice> updateInvoice(Invoice invoice) async {
    final response = await _client
        .from('invoices')
        .update({
          'client_id': invoice.clientId,
          'project_id': invoice.projectId,
          'status': invoice.status.name,
          'issue_date': invoice.issueDate.toIso8601String().split('T')[0],
          'due_date': invoice.dueDate?.toIso8601String().split('T')[0],
          'subtotal': invoice.subtotal,
          'tax_percent': invoice.taxPercent,
          'tax_amount': invoice.taxAmount,
          'discount_percent': invoice.discountPercent,
          'discount_amount': invoice.discountAmount,
          'total': invoice.total,
          'currency': invoice.currency,
          'notes': invoice.notes,
          'payment_terms': invoice.paymentTerms,
          'sent_at': invoice.sentAt?.toIso8601String(),
          'paid_at': invoice.paidAt?.toIso8601String(),
        })
        .eq('id', invoice.id!)
        .select()
        .single();
    return _invoiceFromDb(response);
  }

  Future<void> deleteInvoice(String id) async {
    await _client.from('invoices').delete().eq('id', id);
  }

  Future<List<InvoiceItem>> getInvoiceItems(String invoiceId) async {
    final response = await _client
        .from('invoice_items')
        .select()
        .eq('invoice_id', invoiceId)
        .order('sort_order', ascending: true);
    return response.map((json) => _itemFromDb(json)).toList();
  }

  Future<InvoiceItem> createInvoiceItem(InvoiceItem item) async {
    final response = await _client
        .from('invoice_items')
        .insert({
          'id': item.id,
          'invoice_id': item.invoiceId,
          'user_id': item.userId,
          'description': item.description,
          'quantity': item.quantity,
          'unit_price': item.unitPrice,
          'total': item.total,
          'sort_order': item.sortOrder,
        })
        .select()
        .single();
    return _itemFromDb(response);
  }

  Future<InvoiceItem> updateInvoiceItem(InvoiceItem item) async {
    final response = await _client
        .from('invoice_items')
        .update({
          'description': item.description,
          'quantity': item.quantity,
          'unit_price': item.unitPrice,
          'total': item.total,
          'sort_order': item.sortOrder,
        })
        .eq('id', item.id!)
        .select()
        .single();
    return _itemFromDb(response);
  }

  Future<void> deleteInvoiceItem(String id) async {
    await _client.from('invoice_items').delete().eq('id', id);
  }

  Future<String> getNextInvoiceNumber(String userId) async {
    final response = await _client.rpc(
      'get_next_invoice_number',
      params: {'p_user_id': userId},
    );
    return response as String;
  }

  Invoice _invoiceFromDb(Map<String, dynamic> json) {
    return Invoice(
      id: json['id'],
      userId: json['user_id'],
      clientId: json['client_id'],
      projectId: json['project_id'],
      invoiceNumber: json['invoice_number'],
      status: _parseStatus(json['status']),
      issueDate: DateTime.parse(json['issue_date']),
      dueDate: json['due_date'] != null
          ? DateTime.parse(json['due_date'])
          : null,
      subtotal: (json['subtotal'] ?? 0).toDouble(),
      taxPercent: (json['tax_percent'] ?? 0).toDouble(),
      taxAmount: (json['tax_amount'] ?? 0).toDouble(),
      discountPercent: (json['discount_percent'] ?? 0).toDouble(),
      discountAmount: (json['discount_amount'] ?? 0).toDouble(),
      total: (json['total'] ?? 0).toDouble(),
      currency: json['currency'] ?? 'USD',
      notes: json['notes'],
      paymentTerms: json['payment_terms'],
      pdfUrl: json['pdf_url'],
      sentAt: json['sent_at'] != null ? DateTime.parse(json['sent_at']) : null,
      paidAt: json['paid_at'] != null ? DateTime.parse(json['paid_at']) : null,
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'])
          : null,
    );
  }

  InvoiceStatus _parseStatus(String? status) {
    return switch (status) {
      'draft' => InvoiceStatus.draft,
      'sent' => InvoiceStatus.sent,
      'paid' => InvoiceStatus.paid,
      'overdue' => InvoiceStatus.overdue,
      'cancelled' => InvoiceStatus.cancelled,
      _ => InvoiceStatus.draft,
    };
  }

  InvoiceItem _itemFromDb(Map<String, dynamic> json) {
    return InvoiceItem(
      id: json['id'],
      invoiceId: json['invoice_id'],
      userId: json['user_id'],
      description: json['description'],
      quantity: (json['quantity'] ?? 1).toDouble(),
      unitPrice: (json['unit_price'] ?? 0).toDouble(),
      total: (json['total'] ?? 0).toDouble(),
      sortOrder: json['sort_order'] ?? 0,
      createdAt: DateTime.parse(json['created_at']),
    );
  }
}
