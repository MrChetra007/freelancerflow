import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/supabase/supabase_client.dart';
import '../data/invoice_repository.dart';
import '../domain/invoice.dart';
import '../domain/invoice_item.dart';

final invoiceRepositoryProvider = Provider<InvoiceRepository>((ref) {
  return InvoiceRepository(SupabaseConfig.client);
});

final invoicesProvider = AsyncNotifierProvider<InvoicesNotifier, List<Invoice>>(
  () {
    return InvoicesNotifier();
  },
);

class InvoicesNotifier extends AsyncNotifier<List<Invoice>> {
  @override
  Future<List<Invoice>> build() async {
    final repo = ref.watch(invoiceRepositoryProvider);
    return repo.getInvoices();
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref.read(invoiceRepositoryProvider).getInvoices(),
    );
  }

  Future<Invoice> addInvoice(Invoice invoice) async {
    final repo = ref.read(invoiceRepositoryProvider);
    final created = await repo.createInvoice(invoice);
    await refresh();
    return created;
  }

  Future<void> updateInvoice(Invoice invoice) async {
    final repo = ref.read(invoiceRepositoryProvider);
    await repo.updateInvoice(invoice);
    await refresh();
  }

  Future<void> deleteInvoice(String id) async {
    final repo = ref.read(invoiceRepositoryProvider);
    await repo.deleteInvoice(id);
    await refresh();
  }
}

final invoiceStatusFilterProvider = StateProvider<InvoiceStatus?>(
  (ref) => null,
);

final invoiceSearchQueryProvider = StateProvider<String>((ref) => '');

final filteredInvoicesProvider = Provider<AsyncValue<List<Invoice>>>((ref) {
  final invoices = ref.watch(invoicesProvider);
  final filter = ref.watch(invoiceStatusFilterProvider);
  final query = ref.watch(invoiceSearchQueryProvider).toLowerCase();

  return invoices.whenData((list) {
    var result = list;
    
    if (query.isNotEmpty) {
      result = result.where((i) =>
        i.invoiceNumber.toLowerCase().contains(query)
      ).toList();
    }
    
    if (filter != null) {
      result = result.where((i) => i.status == filter).toList();
    }
    
    return result;
  });
});

final invoiceItemsProvider = FutureProvider.family<List<InvoiceItem>, String>((
  ref,
  invoiceId,
) async {
  final repo = ref.watch(invoiceRepositoryProvider);
  return repo.getInvoiceItems(invoiceId);
});
