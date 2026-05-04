import 'package:supabase_flutter/supabase_flutter.dart';
import '../domain/client.dart';

class ClientRepository {
  final SupabaseClient _client;

  ClientRepository(this._client);

  Future<List<Client>> getClients() async {
    final response = await _client
        .from('clients')
        .select()
        .eq('is_archived', false)
        .order('created_at', ascending: false);
    return response.map((json) => _fromDb(json)).toList();
  }

  Future<Client?> getClient(String id) async {
    final response = await _client
        .from('clients')
        .select()
        .eq('id', id)
        .single();
    return _fromDb(response);
  }

  Future<Client> createClient(Client client) async {
    final response = await _client
        .from('clients')
        .insert({
          'user_id': client.userId,
          'name': client.name,
          'email': client.email,
          'phone': client.phone,
          'company': client.company,
          'country': client.country,
          'currency': client.currency,
          'notes': client.notes,
          'avatar_color': client.avatarColor,
          'default_hourly_rate': client.defaultHourlyRate,
          'tags': client.tags,
          'is_archived': client.isArchived,
        })
        .select()
        .single();
    return _fromDb(response);
  }

  Future<Client> updateClient(Client client) async {
    final response = await _client
        .from('clients')
        .update({
          'name': client.name,
          'email': client.email,
          'phone': client.phone,
          'company': client.company,
          'country': client.country,
          'currency': client.currency,
          'notes': client.notes,
          'avatar_color': client.avatarColor,
          'default_hourly_rate': client.defaultHourlyRate,
          'tags': client.tags,
          'is_archived': client.isArchived,
        })
        .eq('id', client.id!)
        .select()
        .single();
    return _fromDb(response);
  }

  Future<void> deleteClient(String id) async {
    await _client.from('clients').delete().eq('id', id);
  }

  Future<void> archiveClient(String id) async {
    await _client.from('clients').update({'is_archived': true}).eq('id', id);
  }

  Client _fromDb(Map<String, dynamic> json) {
    return Client(
      id: json['id'],
      userId: json['user_id'],
      name: json['name'],
      email: json['email'],
      phone: json['phone'],
      company: json['company'],
      country: json['country'],
      currency: json['currency'] ?? 'USD',
      notes: json['notes'],
      avatarColor: json['avatar_color'] ?? '#2563EB',
      defaultHourlyRate: (json['default_hourly_rate'] ?? 0).toDouble(),
      tags: json['tags'] != null
          ? List<String>.from(json['tags'])
          : const [],
      isArchived: json['is_archived'] ?? false,
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'])
          : null,
    );
  }
}
