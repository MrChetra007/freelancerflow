import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/supabase/supabase_client.dart';
import '../data/payment_repository.dart';
import '../domain/payment.dart';

final paymentRepositoryProvider = Provider<PaymentRepository>((ref) {
  return PaymentRepository(SupabaseConfig.client);
});

final paymentsProvider = AsyncNotifierProvider<PaymentsNotifier, List<Payment>>(
  () {
    return PaymentsNotifier();
  },
);

class PaymentsNotifier extends AsyncNotifier<List<Payment>> {
  @override
  Future<List<Payment>> build() async {
    final repo = ref.watch(paymentRepositoryProvider);
    return repo.getPayments();
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref.read(paymentRepositoryProvider).getPayments(),
    );
  }

  Future<void> addPayment(Payment payment) async {
    final repo = ref.read(paymentRepositoryProvider);
    await repo.createPayment(payment);
    await refresh();
  }

  Future<void> updatePayment(Payment payment) async {
    final repo = ref.read(paymentRepositoryProvider);
    await repo.updatePayment(payment);
    await refresh();
  }

  Future<void> deletePayment(String id) async {
    final repo = ref.read(paymentRepositoryProvider);
    await repo.deletePayment(id);
    await refresh();
  }
}

final paymentStatusFilterProvider = StateProvider<PaymentStatus?>(
  (ref) => null,
);

final paymentSearchQueryProvider = StateProvider<String>((ref) => '');

final filteredPaymentsProvider = Provider<AsyncValue<List<Payment>>>((ref) {
  final payments = ref.watch(paymentsProvider);
  final filter = ref.watch(paymentStatusFilterProvider);
  final query = ref.watch(paymentSearchQueryProvider).toLowerCase();

  return payments.whenData((list) {
    var result = list;
    
    if (query.isNotEmpty) {
      result = result.where((p) =>
        (p.description?.toLowerCase().contains(query) ?? false) ||
        (p.notes?.toLowerCase().contains(query) ?? false)
      ).toList();
    }
    
    if (filter != null) {
      result = result.where((p) => p.status == filter).toList();
    }
    
    return result;
  });
});

final monthlyTotalProvider = Provider<double>((ref) {
  final payments = ref.watch(paymentsProvider);
  return payments.whenData((list) {
        final now = DateTime.now();
        return list
            .where(
              (p) =>
                  p.status == PaymentStatus.paid &&
                  p.paidDate?.month == now.month,
            )
            .fold(0.0, (sum, p) => sum + p.amountPaid);
      }).value ??
      0;
});
