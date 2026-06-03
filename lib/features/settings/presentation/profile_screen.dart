import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/supabase/supabase_client.dart';
import '../../../core/utils/haptic_utils.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../clients/data/clients_provider.dart';
import '../../projects/data/projects_provider.dart';
import '../../payments/data/payments_provider.dart';
import '../../payments/domain/payment.dart';
import '../data/profile_provider.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  bool _isEditing = false;
  bool _isLoading = false;
  bool _isUploadingAvatar = false;
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _businessNameController = TextEditingController();
  final _businessEmailController = TextEditingController();
  final _businessPhoneController = TextEditingController();
  final _businessAddressController = TextEditingController();
  final _hourlyRateController = TextEditingController();
  final _currencyController = TextEditingController();
  final _timezoneController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  void _loadUserData() {
    final user = SupabaseConfig.client.auth.currentUser;
    _emailController.text = user?.email ?? '';
    final profile = ref.read(profileProvider).data;
    if (profile != null) {
      _nameController.text = profile.fullName ?? '';
      _businessNameController.text = profile.businessName ?? '';
      _businessEmailController.text = profile.businessEmail ?? '';
      _businessPhoneController.text = profile.businessPhone ?? '';
      _businessAddressController.text = profile.businessAddress ?? '';
      _hourlyRateController.text = profile.defaultHourlyRate > 0
          ? profile.defaultHourlyRate.toStringAsFixed(2)
          : '';
      _currencyController.text = profile.currency;
      _timezoneController.text = profile.timezone;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _businessNameController.dispose();
    _businessEmailController.dispose();
    _businessPhoneController.dispose();
    _businessAddressController.dispose();
    _hourlyRateController.dispose();
    _currencyController.dispose();
    _timezoneController.dispose();
    super.dispose();
  }

  Future<void> _updateProfile() async {
    setState(() => _isLoading = true);
    try {
      await ref.read(profileProvider.notifier).updateProfile({
        'full_name': _nameController.text.trim(),
        'business_name': _businessNameController.text.trim(),
        'business_email': _businessEmailController.text.trim(),
        'business_phone': _businessPhoneController.text.trim(),
        'business_address': _businessAddressController.text.trim(),
        'default_hourly_rate': double.tryParse(_hourlyRateController.text) ?? 0,
        'currency': _currencyController.text.trim(),
        'timezone': _timezoneController.text.trim(),
      });
      HapticUtils.success();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile updated successfully!')),
        );
        setState(() => _isEditing = false);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: ${e.toString()}')));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _pickAvatar() async {
    final picker = ImagePicker();
    final image = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 512,
      maxHeight: 512,
    );
    if (image == null) return;

    setState(() => _isUploadingAvatar = true);
    try {
      final user = SupabaseConfig.client.auth.currentUser!;
      final ext = image.path.split('.').last;
      final fileName = 'avatars/${user.id}.$ext';

      await SupabaseConfig.client.storage
          .from('avatars')
          .upload(fileName, File(image.path));

      final url = SupabaseConfig.client.storage.from('avatars').getPublicUrl(fileName);

      await ref.read(profileProvider.notifier).updateAvatar(url);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Avatar updated!')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to upload avatar: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isUploadingAvatar = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final profile = ref.watch(profileProvider);
    final clientsAsync = ref.watch(clientsProvider);
    final projectsAsync = ref.watch(projectsProvider);
    final paymentsAsync = ref.watch(paymentsProvider);

    final name = profile.data?.fullName ?? '';
    final email = profile.data?.email ?? '';
    final avatarUrl = profile.data?.avatarUrl;
    final clientCount = clientsAsync.whenData((l) => l.length).value ?? 0;
    final projectCount = projectsAsync.whenData((l) => l.length).value ?? 0;
    final totalEarnings = paymentsAsync.whenData((list) => list
        .where((p) => p.status == PaymentStatus.paid)
        .fold(0.0, (sum, p) => sum + p.amountPaid)
    ).value ?? 0.0;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/settings'),
        ),
        title: const Text('Profile'),
        actions: [
          if (_isEditing)
            TextButton(
              onPressed: _isLoading ? null : _updateProfile,
              child: _isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Save'),
            )
          else
            IconButton(
              icon: const Icon(Icons.edit_outlined),
              onPressed: () {
                HapticUtils.lightImpact();
                final profile = ref.read(profileProvider).data;
                _nameController.text = profile?.fullName ?? '';
                _businessNameController.text = profile?.businessName ?? '';
                _businessEmailController.text = profile?.businessEmail ?? '';
                _businessPhoneController.text = profile?.businessPhone ?? '';
                _businessAddressController.text = profile?.businessAddress ?? '';
                _hourlyRateController.text = (profile?.defaultHourlyRate ?? 0) > 0
                    ? (profile?.defaultHourlyRate ?? 0).toStringAsFixed(2)
                    : '';
                _currencyController.text = profile?.currency ?? 'USD';
                _timezoneController.text = profile?.timezone ?? 'UTC';
                setState(() => _isEditing = true);
              },
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            _buildAvatar(context, isDark, name, email, avatarUrl),
            const SizedBox(height: 24),
            _buildInfoSection(context, isDark, profile.data?.createdAt),
            const SizedBox(height: 24),
            _buildBusinessSection(context, isDark, profile.data),
            const SizedBox(height: 24),
            _buildStatsSection(context, isDark, clientCount, projectCount, totalEarnings),
            const SizedBox(height: 24),
            _buildQuickActions(context, isDark),
          ],
        ),
      ),
    );
  }

  Widget _buildAvatar(BuildContext context, bool isDark, String name, String email, String? avatarUrl) {
    return Column(
      children: [
        GestureDetector(
          onTap: _isUploadingAvatar ? null : _pickAvatar,
          child: Stack(
            children: [
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary500.withValues(alpha: 0.3),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: CircleAvatar(
                  radius: 60,
                  backgroundImage:
                      avatarUrl != null ? NetworkImage(avatarUrl) : null,
                  backgroundColor: AppColors.primary500,
                  child: avatarUrl == null
                      ? Text(
                          _getInitials(name, email),
                          style: const TextStyle(
                            fontSize: 40,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        )
                      : null,
                ),
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: AppColors.primary500,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                  child: _isUploadingAvatar
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : const Icon(Icons.camera_alt, size: 18, color: Colors.white),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Text(
          name.isNotEmpty ? name : 'Freelancer',
          style: Theme.of(context)
              .textTheme
              .headlineSmall
              ?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color: AppColors.statusPaid.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.verified, size: 16, color: AppColors.statusPaid),
              const SizedBox(width: 4),
              Text(
                'FreelanceFlow User',
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.statusPaid,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildInfoSection(BuildContext context, bool isDark, DateTime? createdAt) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Account Information',
            style: Theme.of(context)
                .textTheme
                .titleMedium
                ?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          _buildInfoField(
            context,
            icon: Icons.person_outline,
            label: 'Name',
            controller: _nameController,
            enabled: _isEditing,
          ),
          const Divider(height: 24),
          _buildInfoField(
            context,
            icon: Icons.email_outlined,
            label: 'Email',
            controller: _emailController,
            enabled: false,
            suffix: Icons.lock_outlined,
          ),
          const Divider(height: 24),
          _buildInfoRow(
            context,
            icon: Icons.calendar_today_outlined,
            label: 'Member Since',
            value: _formatDate(createdAt),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoField(
    BuildContext context, {
    required IconData icon,
    required String label,
    required TextEditingController controller,
    required bool enabled,
    IconData? suffix,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: AppColors.primary500.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: AppColors.primary500, size: 20),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: enabled
              ? TextField(
                  controller: controller,
                  decoration: InputDecoration(
                    labelText: label,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                  ),
                )
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: isDark
                            ? AppColors.darkTextSecondary
                            : AppColors.lightTextSecondary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      controller.text.isNotEmpty ? controller.text : 'Not set',
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                  ],
                ),
        ),
        if (suffix != null && !enabled)
          Icon(
            suffix,
            size: 16,
            color: isDark
                ? AppColors.darkTextSecondary
                : AppColors.lightTextSecondary,
          ),
      ],
    );
  }

  Widget _buildInfoRow(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: AppColors.primary500.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: AppColors.primary500, size: 20),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).brightness == Brightness.dark
                      ? AppColors.darkTextSecondary
                      : AppColors.lightTextSecondary,
                ),
              ),
              const SizedBox(height: 4),
              Text(value, style: Theme.of(context).textTheme.bodyLarge),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildBusinessSection(BuildContext context, bool isDark, ProfileData? profile) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Business Information',
            style: Theme.of(context)
                .textTheme
                .titleMedium
                ?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          _buildInfoField(
            context,
            icon: Icons.business,
            label: 'Business Name',
            controller: _businessNameController,
            enabled: _isEditing,
          ),
          const Divider(height: 24),
          _buildInfoField(
            context,
            icon: Icons.email_outlined,
            label: 'Business Email',
            controller: _businessEmailController,
            enabled: _isEditing,
          ),
          const Divider(height: 24),
          _buildInfoField(
            context,
            icon: Icons.phone_outlined,
            label: 'Business Phone',
            controller: _businessPhoneController,
            enabled: _isEditing,
          ),
          const Divider(height: 24),
          _buildInfoField(
            context,
            icon: Icons.location_on_outlined,
            label: 'Business Address',
            controller: _businessAddressController,
            enabled: _isEditing,
          ),
          const Divider(height: 24),
          _buildInfoField(
            context,
            icon: Icons.attach_money_outlined,
            label: 'Default Hourly Rate',
            controller: _hourlyRateController,
            enabled: _isEditing,
          ),
          const Divider(height: 24),
          _buildInfoRow(
            context,
            icon: Icons.monetization_on_outlined,
            label: 'Currency',
            value: profile?.currency ?? 'USD',
          ),
          const Divider(height: 24),
          _buildInfoRow(
            context,
            icon: Icons.access_time,
            label: 'Timezone',
            value: profile?.timezone ?? 'UTC',
          ),
        ],
      ),
    );
  }

  Widget _buildStatsSection(BuildContext context, bool isDark, int clientCount, int projectCount, double totalEarnings) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Quick Stats',
            style: Theme.of(context)
                .textTheme
                .titleMedium
                ?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  context,
                  icon: Icons.people_outline,
                  label: 'Clients',
                  value: clientCount.toString(),
                  color: AppColors.primary500,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  context,
                  icon: Icons.folder_outlined,
                  label: 'Projects',
                  value: projectCount.toString(),
                  color: Colors.orange,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  context,
                  icon: Icons.payments_outlined,
                  label: 'Earnings',
                  value: CurrencyFormatter.formatCompact(totalEarnings, 'USD'),
                  color: AppColors.statusPaid,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).brightness == Brightness.dark
                  ? AppColors.darkTextSecondary
                  : AppColors.lightTextSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Quick Actions',
            style: Theme.of(context)
                .textTheme
                .titleMedium
                ?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          _buildActionTile(
            context,
            icon: Icons.business,
            title: 'Manage Clients',
            subtitle: 'View and edit your clients',
            onTap: () => context.go('/clients'),
          ),
          _buildActionTile(
            context,
            icon: Icons.analytics_outlined,
            title: 'View Dashboard',
            subtitle: 'Check your business overview',
            onTap: () => context.go('/dashboard'),
          ),
          _buildActionTile(
            context,
            icon: Icons.settings_outlined,
            title: 'App Settings',
            subtitle: 'Notifications, theme, and more',
            onTap: () => context.go('/settings'),
          ),
        ],
      ),
    );
  }

  Widget _buildActionTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          HapticUtils.lightImpact();
          onTap();
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.primary500.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: AppColors.primary500, size: 20),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context)
                          .textTheme
                          .bodyLarge
                          ?.copyWith(fontWeight: FontWeight.w500),
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

  String _getInitials(String name, String email) {
    if (name.isNotEmpty) {
      final parts = name.split(' ');
      if (parts.length >= 2) {
        return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
      }
      return name[0].toUpperCase();
    }
    if (email.isNotEmpty) {
      return email[0].toUpperCase();
    }
    return 'F';
  }

  String _formatDate(DateTime? date) {
    if (date == null) return 'Unknown';
    return '${date.day}/${date.month}/${date.year}';
  }
}
