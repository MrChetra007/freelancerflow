import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseConfig {
  static SupabaseClient? _instance;

  static Future<void> initialize() async {
    await dotenv.load();

    final url = dotenv.env['SUPABASE_URL']!;
    final anonKey = dotenv.env['SUPABASE_ANON_KEY']!;

    await Supabase.initialize(url: url, anonKey: anonKey);
    _instance = Supabase.instance.client;
  }

  static SupabaseClient get client {
    if (_instance == null) {
      throw StateError(
        'Supabase not initialized. Call SupabaseConfig.initialize() first.',
      );
    }
    return _instance!;
  }

  static bool get isInitialized => _instance != null;
}
