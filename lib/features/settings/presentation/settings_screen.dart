import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/theme/theme_notifier.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/supabase/supabase_client.dart';
import '../../../core/services/notification_service.dart';

final notificationPrefsProvider =
    StateNotifierProvider<NotificationPrefsNotifier, NotificationPrefs>((ref) {
      return NotificationPrefsNotifier(ref.watch(sharedPreferencesProvider));
    });

class NotificationPrefs {
  final bool paymentReminders;
  final bool projectReminders;
  final bool invoiceReminders;

  NotificationPrefs({
    this.paymentReminders = true,
    this.projectReminders = true,
    this.invoiceReminders = true,
  });

  NotificationPrefs copyWith({
    bool? paymentReminders,
    bool? projectReminders,
    bool? invoiceReminders,
  }) {
    return NotificationPrefs(
      paymentReminders: paymentReminders ?? this.paymentReminders,
      projectReminders: projectReminders ?? this.projectReminders,
      invoiceReminders: invoiceReminders ?? this.invoiceReminders,
    );
  }
}

class NotificationPrefsNotifier extends StateNotifier<NotificationPrefs> {
  final SharedPreferences _prefs;

  NotificationPrefsNotifier(this._prefs)
    : super(
        NotificationPrefs(
          paymentReminders: _prefs.getBool('payment_reminders') ?? true,
          projectReminders: _prefs.getBool('project_reminders') ?? true,
          invoiceReminders: _prefs.getBool('invoice_reminders') ?? true,
        ),
      );

  Future<void> setPaymentReminders(bool value) async {
    await _prefs.setBool('payment_reminders', value);
    state = state.copyWith(paymentReminders: value);
  }

  Future<void> setProjectReminders(bool value) async {
    await _prefs.setBool('project_reminders', value);
    state = state.copyWith(projectReminders: value);
  }

  Future<void> setInvoiceReminders(bool value) async {
    await _prefs.setBool('invoice_reminders', value);
    state = state.copyWith(invoiceReminders: value);
  }
}

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeNotifierProvider);
    final notificationPrefs = ref.watch(notificationPrefsProvider);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/dashboard'),
        ),
        title: const Text('Settings'),
      ),
      body: ListView(
        children: [
          const SizedBox(height: 16),
          _buildSectionHeader(context, 'Appearance'),
          ListTile(
            leading: const Icon(Icons.light_mode_outlined),
            title: const Text('Theme'),
            subtitle: Text(_getThemeName(themeMode)),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _showThemePicker(context, ref, themeMode),
          ),
          const Divider(),
          _buildSectionHeader(context, 'Notifications'),
          SwitchListTile(
            secondary: const Icon(Icons.payment_outlined),
            title: const Text('Payment Reminders'),
            subtitle: const Text('Get notified before payments are due'),
            value: notificationPrefs.paymentReminders,
            onChanged: (value) {
              ref
                  .read(notificationPrefsProvider.notifier)
                  .setPaymentReminders(value);
            },
          ),
          SwitchListTile(
            secondary: const Icon(Icons.folder_outlined),
            title: const Text('Project Reminders'),
            subtitle: const Text('Get notified before project deadlines'),
            value: notificationPrefs.projectReminders,
            onChanged: (value) {
              ref
                  .read(notificationPrefsProvider.notifier)
                  .setProjectReminders(value);
            },
          ),
          SwitchListTile(
            secondary: const Icon(Icons.receipt_long_outlined),
            title: const Text('Invoice Reminders'),
            subtitle: const Text('Get notified before invoices are due'),
            value: notificationPrefs.invoiceReminders,
            onChanged: (value) {
              ref
                  .read(notificationPrefsProvider.notifier)
                  .setInvoiceReminders(value);
            },
          ),
          ListTile(
            leading: const Icon(Icons.notifications_outlined),
            title: const Text('Test Notification'),
            subtitle: const Text('Send a test notification'),
            onTap: () async {
              final granted = await NotificationService.instance
                  .requestPermission();
              if (granted) {
                await NotificationService.instance.showNotification(
                  id: 0,
                  title: 'Test Notification',
                  body: 'Notifications are working correctly!',
                );
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Test notification sent!')),
                  );
                }
              } else {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Please enable notifications in settings'),
                    ),
                  );
                }
              }
            },
          ),
          const Divider(),
          _buildSectionHeader(context, 'Premium'),
          ListTile(
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.statusPaid.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.workspace_premium,
                color: AppColors.statusPaid,
              ),
            ),
            title: const Text('Upgrade to Premium'),
            subtitle: const Text('Unlock all features'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.push('/premium'),
          ),
          const Divider(),
          _buildSectionHeader(context, 'Account'),
          ListTile(
            leading: const Icon(Icons.person_outline),
            title: const Text('Profile'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {},
          ),
          ListTile(
            leading: const Icon(Icons.lock_outline),
            title: const Text('Change Password'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {},
          ),
          const Divider(),
          _buildSectionHeader(context, 'About'),
          ListTile(
            leading: const Icon(Icons.info_outline),
            title: const Text('App Version'),
            subtitle: const Text('1.0.0'),
          ),
          ListTile(
            leading: const Icon(Icons.description_outlined),
            title: const Text('Terms of Service'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {},
          ),
          ListTile(
            leading: const Icon(Icons.privacy_tip_outlined),
            title: const Text('Privacy Policy'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {},
          ),
          const Divider(),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: OutlinedButton.icon(
              onPressed: () async {
                await SupabaseConfig.client.auth.signOut();
                if (context.mounted) {
                  context.go('/login');
                }
              },
              icon: const Icon(Icons.logout, color: AppColors.error),
              label: const Text(
                'Sign Out',
                style: TextStyle(color: AppColors.error),
              ),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: AppColors.error),
              ),
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleSmall?.copyWith(
          color: Theme.of(context).brightness == Brightness.dark
              ? AppColors.darkTextSecondary
              : AppColors.lightTextSecondary,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  String _getThemeName(ThemeMode mode) {
    return switch (mode) {
      ThemeMode.light => 'Light',
      ThemeMode.dark => 'Dark',
      ThemeMode.system => 'System',
    };
  }

  void _showThemePicker(
    BuildContext context,
    WidgetRef ref,
    ThemeMode currentMode,
  ) {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 8),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Theme.of(context).dividerColor,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),
            Text('Choose Theme', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            RadioListTile<ThemeMode>(
              value: ThemeMode.system,
              groupValue: currentMode,
              onChanged: (value) {
                ref.read(themeNotifierProvider.notifier).setTheme(value!);
                Navigator.pop(context);
              },
              title: const Text('System'),
              subtitle: const Text('Follow system settings'),
            ),
            RadioListTile<ThemeMode>(
              value: ThemeMode.light,
              groupValue: currentMode,
              onChanged: (value) {
                ref.read(themeNotifierProvider.notifier).setTheme(value!);
                Navigator.pop(context);
              },
              title: const Text('Light'),
              subtitle: const Text('Always light mode'),
            ),
            RadioListTile<ThemeMode>(
              value: ThemeMode.dark,
              groupValue: currentMode,
              onChanged: (value) {
                ref.read(themeNotifierProvider.notifier).setTheme(value!);
                Navigator.pop(context);
              },
              title: const Text('Dark'),
              subtitle: const Text('Always dark mode'),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
