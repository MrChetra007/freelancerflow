import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'app.dart';
import 'core/supabase/supabase_client.dart';
import 'core/theme/theme_notifier.dart';
import 'core/services/notification_service.dart';
import 'core/services/recurring_invoice_generator.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await SupabaseConfig.initialize();

  try {
    await NotificationService.instance.initialize();
  } catch (e) {
    debugPrint('Notification service initialization failed: $e');
  }

  final prefs = await SharedPreferences.getInstance();

  unawaited(RecurringInvoiceGenerator().checkAndGenerate());

  runApp(
    ProviderScope(
      overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
      child: const App(),
    ),
  );
}
