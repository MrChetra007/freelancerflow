import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/supabase/supabase_client.dart';
import '../data/client_repository.dart';
import '../domain/client.dart';

final clientRepositoryProvider = Provider<ClientRepository>((ref) {
  return ClientRepository(SupabaseConfig.client);
});

final clientsProvider = AsyncNotifierProvider<ClientsNotifier, List<Client>>(
  () {
    return ClientsNotifier();
  },
);

class ClientsNotifier extends AsyncNotifier<List<Client>> {
  @override
  Future<List<Client>> build() async {
    final repo = ref.watch(clientRepositoryProvider);
    return repo.getClients();
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref.read(clientRepositoryProvider).getClients(),
    );
  }

  Future<void> addClient(Client client) async {
    final repo = ref.read(clientRepositoryProvider);
    await repo.createClient(client);
    await refresh();
  }

  Future<void> updateClient(Client client) async {
    final repo = ref.read(clientRepositoryProvider);
    await repo.updateClient(client);
    await refresh();
  }

  Future<void> deleteClient(String id) async {
    final repo = ref.read(clientRepositoryProvider);
    await repo.deleteClient(id);
    await refresh();
  }
}

final searchQueryProvider = StateProvider<String>((ref) => '');

final filteredClientsProvider = Provider<AsyncValue<List<Client>>>((ref) {
  final clients = ref.watch(clientsProvider);
  final query = ref.watch(searchQueryProvider).toLowerCase();

  return clients.whenData((list) {
    if (query.isEmpty) return list;
    return list
        .where(
          (c) =>
              c.name.toLowerCase().contains(query) ||
              (c.email?.toLowerCase().contains(query) ?? false) ||
              (c.company?.toLowerCase().contains(query) ?? false),
        )
        .toList();
  });
});

final sortOptionProvider = StateProvider<ClientSortOption>(
  (ref) => ClientSortOption.name,
);

enum ClientSortOption { name, recent, revenue }

final sortedClientsProvider = Provider<AsyncValue<List<Client>>>((ref) {
  final clients = ref.watch(filteredClientsProvider);
  final sortOption = ref.watch(sortOptionProvider);

  return clients.whenData((list) {
    final sorted = List<Client>.from(list);
    switch (sortOption) {
      case ClientSortOption.name:
        sorted.sort((a, b) => a.name.compareTo(b.name));
      case ClientSortOption.recent:
        sorted.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      case ClientSortOption.revenue:
        sorted.sort((a, b) => a.name.compareTo(b.name));
    }
    return sorted;
  });
});
