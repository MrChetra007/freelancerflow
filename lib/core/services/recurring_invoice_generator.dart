import 'package:flutter/foundation.dart';

import '../supabase/supabase_client.dart';
import 'notification_service.dart';
import '../../features/invoices/data/invoice_repository.dart';
import '../../features/invoices/domain/invoice.dart';
import '../../features/invoices/domain/invoice_item.dart';
import '../../features/recurring/data/recurring_invoice_repository.dart';

class RecurringInvoiceGenerator {
  Future<void> checkAndGenerate() async {
    try {
      final user = SupabaseConfig.client.auth.currentUser;
      if (user == null) {
        debugPrint('No authenticated user for recurring invoice generation');
        return;
      }

      final userId = user.id;
      final recurringRepo = RecurringInvoiceRepository();
      final invoiceRepo = InvoiceRepository(SupabaseConfig.client);

      final due = await recurringRepo.getDueInvoices(userId);
      if (due.isEmpty) return;

      debugPrint('Found ${due.length} due recurring invoice(s) to generate');

      for (final templateData in due) {
        await _generateInvoice(
          templateData: templateData,
          userId: userId,
          recurringRepo: recurringRepo,
          invoiceRepo: invoiceRepo,
        );
      }
    } catch (e) {
      debugPrint('Error in recurring invoice generation: $e');
    }
  }

  Future<void> _generateInvoice({
    required Map<String, dynamic> templateData,
    required String userId,
    required RecurringInvoiceRepository recurringRepo,
    required InvoiceRepository invoiceRepo,
  }) async {
    try {
      final recurringId = templateData['id'] as String;
      final clientId = templateData['client_id'] as String;
      final clientName = templateData['client_name'] as String;
      final projectId = templateData['project_id'] as String?;
      final dueDays = (templateData['due_days'] as num?)?.toInt() ?? 30;
      final taxPercent = (templateData['tax_percent'] as num?)?.toDouble() ?? 0;
      final discountPercent =
          (templateData['discount_percent'] as num?)?.toDouble() ?? 0;
      final currency = templateData['currency'] as String? ?? 'USD';
      final notes = templateData['notes'] as String?;
      final paymentTerms = templateData['payment_terms'] as String?;

      final lineItemsData = templateData['line_items'] as List<dynamic>?;
      if (lineItemsData == null || lineItemsData.isEmpty) {
        debugPrint('Skipping $recurringId — no line items');
        return;
      }

      final subtotal = lineItemsData.fold<double>(
        0,
        (sum, item) {
          final qty = (item['quantity'] as num?)?.toDouble() ?? 1;
          final price = (item['unit_price'] as num?)?.toDouble() ?? 0;
          return sum + (qty * price);
        },
      );

      final taxAmount = subtotal * (taxPercent / 100);
      final discountAmount = subtotal * (discountPercent / 100);
      final total = subtotal + taxAmount - discountAmount;

      final invoiceNumber = await invoiceRepo.getNextInvoiceNumber(userId);

      final invoice = Invoice(
        userId: userId,
        clientId: clientId,
        projectId: projectId,
        invoiceNumber: invoiceNumber,
        status: InvoiceStatus.draft,
        issueDate: DateTime.now(),
        dueDate: DateTime.now().add(Duration(days: dueDays)),
        subtotal: subtotal,
        taxPercent: taxPercent,
        taxAmount: taxAmount,
        discountPercent: discountPercent,
        discountAmount: discountAmount,
        total: total,
        currency: currency,
        notes: notes,
        paymentTerms: paymentTerms,
        createdAt: DateTime.now(),
      );

      final createdInvoice = await invoiceRepo.createInvoice(invoice);

      for (int i = 0; i < lineItemsData.length; i++) {
        final item = lineItemsData[i] as Map<String, dynamic>;
        final qty = (item['quantity'] as num?)?.toDouble() ?? 1;
        final price = (item['unit_price'] as num?)?.toDouble() ?? 0;

        final invoiceItem = InvoiceItem(
          invoiceId: createdInvoice.id!,
          userId: userId,
          description: item['description'] as String? ?? 'Line item',
          quantity: qty,
          unitPrice: price,
          total: qty * price,
          sortOrder: i,
          createdAt: DateTime.now(),
        );

        await invoiceRepo.createInvoiceItem(invoiceItem);
      }

      await recurringRepo.advanceSchedule(recurringId);

      await NotificationService.instance.showRecurringGenerated(
        invoiceId: createdInvoice.id!,
        invoiceNumber: invoiceNumber,
        clientName: clientName,
      );

      debugPrint(
        'Generated invoice $invoiceNumber for $clientName from recurring template',
      );
    } catch (e) {
      debugPrint('Error generating invoice from recurring template: $e');
    }
  }
}
