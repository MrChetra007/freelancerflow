import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/services/iap_service.dart';
import '../data/premium_provider.dart';

class PremiumScreen extends ConsumerStatefulWidget {
  const PremiumScreen({super.key});

  @override
  ConsumerState<PremiumScreen> createState() => _PremiumScreenState();
}

class _PremiumScreenState extends ConsumerState<PremiumScreen> {
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    final isPremium = ref.watch(isPremiumProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Premium'),
        actions: [
          if (isPremium)
            IconButton(
              icon: const Icon(Icons.settings),
              onPressed: () => _showSubscriptionSettings(context),
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            if (isPremium) ...[
              _buildPremiumActive(),
            ] else ...[
              _buildUpgradeSection(),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildPremiumActive() {
    return Column(
      children: [
        const SizedBox(height: 40),
        Container(
          width: 120,
          height: 120,
          decoration: BoxDecoration(
            color: AppColors.statusPaid.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.workspace_premium,
            size: 64,
            color: AppColors.statusPaid,
          ),
        ),
        const SizedBox(height: 24),
        Text(
          "You're Premium!",
          style: Theme.of(
            context,
          ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Text(
          'Thank you for supporting FreelanceFlow',
          style: Theme.of(
            context,
          ).textTheme.bodyLarge?.copyWith(color: AppColors.lightTextSecondary),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 40),
        _buildFeatureCard(
          icon: Icons.flash_on,
          title: 'All Features Unlocked',
          subtitle: 'No limits on clients, projects, or invoices',
          color: AppColors.statusPaid,
        ),
        const SizedBox(height: 16),
        _buildFeatureCard(
          icon: Icons.notifications_active,
          title: 'Reminders Enabled',
          subtitle: 'Get notified before deadlines',
          color: AppColors.info,
        ),
        const SizedBox(height: 16),
        _buildFeatureCard(
          icon: Icons.cloud_upload,
          title: 'Cloud Sync',
          subtitle: 'Your data is safely backed up',
          color: AppColors.primary500,
        ),
        const SizedBox(height: 40),
        Card(
          color: AppColors.statusPaid.withValues(alpha: 0.1),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                const Icon(Icons.check_circle, color: AppColors.statusPaid),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Premium Active',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: AppColors.statusPaid,
                        ),
                      ),
                      Text(
                        '\$4.99/month',
                        style: TextStyle(
                          color: AppColors.lightTextSecondary,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildUpgradeSection() {
    return Column(
      children: [
        Container(
          width: 120,
          height: 120,
          decoration: BoxDecoration(
            color: AppColors.primary500.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.workspace_premium,
            size: 64,
            color: AppColors.primary500,
          ),
        ),
        const SizedBox(height: 24),
        Text(
          'Unlock Premium',
          style: Theme.of(
            context,
          ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Text(
          'Remove all limits and unlock all features',
          style: Theme.of(
            context,
          ).textTheme.bodyLarge?.copyWith(color: AppColors.lightTextSecondary),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          decoration: BoxDecoration(
            color: AppColors.primary500,
            borderRadius: BorderRadius.circular(24),
          ),
          child: Text(
            '\$4.99/month',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
        ),
        const SizedBox(height: 32),
        _buildFeatureCard(
          icon: Icons.people,
          title: 'Unlimited Clients',
          subtitle: 'Add as many clients as you need',
          color: AppColors.primary500,
        ),
        const SizedBox(height: 16),
        _buildFeatureCard(
          icon: Icons.folder,
          title: 'Unlimited Projects',
          subtitle: 'No restrictions on projects',
          color: AppColors.info,
        ),
        const SizedBox(height: 16),
        _buildFeatureCard(
          icon: Icons.receipt_long,
          title: 'Unlimited Invoices',
          subtitle: 'Create and send unlimited invoices',
          color: AppColors.statusPaid,
        ),
        const SizedBox(height: 16),
        _buildFeatureCard(
          icon: Icons.notifications,
          title: 'Reminders & Notifications',
          subtitle: 'Stay on top of deadlines',
          color: AppColors.warning,
        ),
        const SizedBox(height: 32),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _isLoading ? null : _purchasePremium,
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            child: _isLoading
                ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text(
                    'Subscribe Now',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
          ),
        ),
        const SizedBox(height: 16),
        TextButton(
          onPressed: _restorePurchases,
          child: const Text('Restore Purchases'),
        ),
        const SizedBox(height: 24),
        const Text(
          'Cancel anytime. Auto-renews unless cancelled 24h before end of period.',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 12, color: AppColors.lightTextSecondary),
        ),
      ],
    );
  }

  Widget _buildFeatureCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
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
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: AppColors.lightTextSecondary,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.check_circle, color: AppColors.statusPaid),
          ],
        ),
      ),
    );
  }

  void _showSubscriptionSettings(BuildContext context) {
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
            Text(
              'Subscription Settings',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.restore),
              title: const Text('Restore Purchases'),
              subtitle: const Text('Restore your subscription'),
              onTap: () {
                Navigator.pop(context);
                _restorePurchases();
              },
            ),
            ListTile(
              leading: const Icon(Icons.open_in_browser),
              title: const Text('Manage Subscription'),
              subtitle: const Text('Open Google Play Store'),
              onTap: () {
                Navigator.pop(context);
                _openPlayStore();
              },
            ),
            ListTile(
              leading: const Icon(
                Icons.cancel_outlined,
                color: AppColors.error,
              ),
              title: const Text(
                'Cancel Subscription',
                style: TextStyle(color: AppColors.error),
              ),
              subtitle: const Text('Turn off auto-renewal'),
              onTap: () {
                Navigator.pop(context);
                _showCancelConfirmation(context);
              },
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  void _showCancelConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cancel Subscription?'),
        content: const Text(
          'Are you sure you want to cancel? You will still have access until the end of your billing period.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Keep Subscription'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _cancelSubscription();
            },
            child: const Text(
              'Cancel Subscription',
              style: TextStyle(color: AppColors.error),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _purchasePremium() async {
    setState(() => _isLoading = true);

    try {
      await IapService.instance.initialize();
      final success = await IapService.instance.purchasePremium();

      if (mounted) {
        if (success) {
          ref.read(isPremiumProvider.notifier).refresh();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Purchase successful! Welcome to Premium!'),
              backgroundColor: AppColors.statusPaid,
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Purchase failed. Please try again.')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _restorePurchases() async {
    setState(() => _isLoading = true);

    try {
      await IapService.instance.restorePurchases();
      ref.read(isPremiumProvider.notifier).refresh();

      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Purchases restored!')));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _cancelSubscription() {
    ref.read(isPremiumProvider.notifier).setPremium(false);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Subscription cancelled. Access continues until end of period.',
        ),
      ),
    );
  }

  void _openPlayStore() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Open Google Play Store > Subscriptions to manage.'),
      ),
    );
  }
}
