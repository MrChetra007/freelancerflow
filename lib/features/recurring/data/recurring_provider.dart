import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/supabase/supabase_client.dart';
import '../domain/recurring_invoice.dart';
import 'recurring_invoice_repository.dart';

part 'recurring_provider.g.dart';

@riverpod
RecurringInvoiceRepository recurringInvoiceRepository(Ref ref) =>
    RecurringInvoiceRepository();

@riverpod
Future<List<RecurringInvoice>> recurringInvoices(Ref ref) async {
  final user = SupabaseConfig.client.auth.currentUser;
  if (user == null) return [];
  return await ref
      .read(recurringInvoiceRepositoryProvider)
      .getRecurringInvoices(user.id) ?? [];
}
