import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/theme/theme_notifier.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/supabase/supabase_client.dart';
import '../../../core/services/notification_service.dart';
import '../data/premium_provider.dart';

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
    final isPremium = ref.watch(isPremiumProvider);

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
          if (isPremium) ...[
            Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.amber.shade600, Colors.amber.shade800],
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.amber.withValues(alpha: 0.3),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.workspace_premium,
                      color: Colors.white,
                      size: 32,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Premium Active',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                        Text(
                          'All features unlocked',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.9),
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '\$4.99/mo',
                      style: TextStyle(
                        color: Colors.amber.shade800,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 8),
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
            title: const Text('Test Notifications'),
            subtitle: const Text('Test notification scheduling'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _showNotificationTester(context),
          ),
          ListTile(
            leading: const Icon(Icons.schedule_outlined),
            title: const Text('Scheduled Notifications'),
            subtitle: const Text('View upcoming notifications'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _showScheduledNotifications(context, ref),
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
            onTap: () => context.push('/profile'),
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
          _buildSectionHeader(context, 'Developer Options'),
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.orange.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.orange.withValues(alpha: 0.3)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.bug_report,
                      color: Colors.orange.shade700,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Testing Mode',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.orange.shade700,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                const Text(
                  'Toggle premium status for testing',
                  style: TextStyle(fontSize: 12),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          ref.read(isPremiumProvider.notifier).setPremium(true);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Premium enabled!'),
                              backgroundColor: AppColors.statusPaid,
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.amber.shade700,
                          foregroundColor: Colors.white,
                        ),
                        child: const Text('Go Premium'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {
                          ref
                              .read(isPremiumProvider.notifier)
                              .setPremium(false);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Switched to Free plan'),
                            ),
                          );
                        },
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.grey.shade700,
                        ),
                        child: const Text('Go Free'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
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

  void _showNotificationTester(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => NotificationTesterSheet(),
    );
  }

  void _showScheduledNotifications(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => ScheduledNotificationsSheet(
        notificationService: NotificationService.instance,
      ),
    );
  }
}

class NotificationTesterSheet extends StatefulWidget {
  const NotificationTesterSheet({super.key});

  @override
  State<NotificationTesterSheet> createState() =>
      _NotificationTesterSheetState();
}

class _NotificationTesterSheetState extends State<NotificationTesterSheet> {
  bool _isLoading = false;

  Future<void> _sendImmediate() async {
    await _sendTestNotification(
      'Immediate',
      'This notification appears instantly!',
    );
  }

  Future<void> _sendIn10Seconds() async {
    await _scheduleNotification(
      10,
      '10 Seconds',
      'This notification will appear in 10 seconds!',
    );
  }

  Future<void> _sendIn1Minute() async {
    await _scheduleNotification(
      60,
      '1 Minute',
      'This notification will appear in 1 minute!',
    );
  }

  Future<void> _sendTestNotification(String title, String body) async {
    setState(() => _isLoading = true);
    try {
      final granted = await NotificationService.instance.requestPermission();
      if (granted) {
        await NotificationService.instance.showNotification(
          id: DateTime.now().millisecondsSinceEpoch ~/ 1000,
          title: 'FreelanceFlow - $title',
          body: body,
        );
        if (mounted) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Test notification sent!')),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Please enable notifications in settings'),
            ),
          );
        }
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _scheduleNotification(
    int seconds,
    String title,
    String body,
  ) async {
    setState(() => _isLoading = true);
    try {
      final granted = await NotificationService.instance.requestPermission();
      if (granted) {
        final scheduledTime = DateTime.now().add(Duration(seconds: seconds));
        await NotificationService.instance.scheduleNotification(
          id: DateTime.now().millisecondsSinceEpoch ~/ 1000,
          title: 'FreelanceFlow - $title',
          body: body,
          scheduledDate: scheduledTime,
        );
        if (mounted) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Notification scheduled for $title!')),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Please enable notifications in settings'),
            ),
          );
        }
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Theme.of(context).dividerColor,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Test Notifications',
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'Test if notifications are working correctly',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).brightness == Brightness.dark
                  ? AppColors.darkTextSecondary
                  : AppColors.lightTextSecondary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          _buildTestButton(
            context,
            icon: Icons.flash_on,
            title: 'Send Immediately',
            subtitle: 'Test notification right now',
            color: AppColors.statusPaid,
            onTap: _isLoading ? null : _sendImmediate,
          ),
          const SizedBox(height: 12),
          _buildTestButton(
            context,
            icon: Icons.timer,
            title: 'In 10 Seconds',
            subtitle: 'Schedule notification for 10 seconds',
            color: AppColors.primary500,
            onTap: _isLoading ? null : _sendIn10Seconds,
          ),
          const SizedBox(height: 12),
          _buildTestButton(
            context,
            icon: Icons.schedule,
            title: 'In 1 Minute',
            subtitle: 'Schedule notification for 1 minute',
            color: Colors.orange,
            onTap: _isLoading ? null : _sendIn1Minute,
          ),
          const SizedBox(height: 24),
          if (_isLoading) const Center(child: CircularProgressIndicator()),
        ],
      ),
    );
  }

  Widget _buildTestButton(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    VoidCallback? onTap,
  }) {
    return Material(
      color: color.withValues(alpha: 0.1),
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      subtitle,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).brightness == Brightness.dark
                            ? AppColors.darkTextSecondary
                            : AppColors.lightTextSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: Theme.of(context).brightness == Brightness.dark
                    ? AppColors.darkTextSecondary
                    : AppColors.lightTextSecondary,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ScheduledNotificationsSheet extends StatefulWidget {
  final NotificationService notificationService;

  const ScheduledNotificationsSheet({
    super.key,
    required this.notificationService,
  });

  @override
  State<ScheduledNotificationsSheet> createState() =>
      _ScheduledNotificationsSheetState();
}

class _ScheduledNotificationsSheetState
    extends State<ScheduledNotificationsSheet> {
  final List<Map<String, dynamic>> _scheduledNotifications = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadScheduledNotifications();
  }

  Future<void> _loadScheduledNotifications() async {
    setState(() => _isLoading = true);
    try {
      // Note: flutter_local_notifications doesn't expose a method to list pending notifications
      // So we'll show a message explaining this
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _cancelAllScheduled() async {
    await widget.notificationService.cancelAllNotifications();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('All scheduled notifications cancelled')),
      );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.7,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Theme.of(context).dividerColor,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Scheduled Notifications',
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
              TextButton.icon(
                onPressed: _cancelAllScheduled,
                icon: const Icon(Icons.delete_sweep, size: 18),
                label: const Text('Cancel All'),
                style: TextButton.styleFrom(foregroundColor: AppColors.error),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Notifications are automatically scheduled for:\n• Payment due dates (1 day before)\n• Project deadlines (1 day before)\n• Invoice due dates (1 day before)',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).brightness == Brightness.dark
                  ? AppColors.darkTextSecondary
                  : AppColors.lightTextSecondary,
            ),
          ),
          const SizedBox(height: 16),
          const Divider(),
          const SizedBox(height: 8),
          Text(
            'Scheduled Notifications Info',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 12),
          _buildScheduledInfo(
            context,
            icon: Icons.payment,
            title: 'Payment Reminders',
            subtitle: 'Sent 1 day before payment due date',
          ),
          const SizedBox(height: 8),
          _buildScheduledInfo(
            context,
            icon: Icons.folder,
            title: 'Project Reminders',
            subtitle: 'Sent 1 day before project deadline',
          ),
          const SizedBox(height: 8),
          _buildScheduledInfo(
            context,
            icon: Icons.receipt_long,
            title: 'Invoice Reminders',
            subtitle: 'Sent 1 day before invoice due date',
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.primary500.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppColors.primary500.withValues(alpha: 0.3),
              ),
            ),
            child: Row(
              children: [
                Icon(Icons.info_outline, color: AppColors.primary500),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Enable notification toggles above to receive reminders for each type.',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildScheduledInfo(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).brightness == Brightness.dark
            ? Colors.white.withValues(alpha: 0.05)
            : Colors.black.withValues(alpha: 0.03),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(icon, size: 20, color: AppColors.primary500),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
                ),
                Text(
                  subtitle,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).brightness == Brightness.dark
                        ? AppColors.darkTextSecondary
                        : AppColors.lightTextSecondary,
                  ),
                ),
              ],
            ),
          ),
          Icon(Icons.check_circle, color: AppColors.statusPaid, size: 20),
        ],
      ),
    );
  }
}
