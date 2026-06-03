import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/supabase/supabase_client.dart';
import '../../../core/theme/app_colors.dart';
import '../../settings/data/profile_provider.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkAuth();
  }

  Future<void> _checkAuth() async {
    await Future.delayed(const Duration(milliseconds: 500));
    if (!mounted) return;

    final session = SupabaseConfig.client.auth.currentSession;
    if (session != null) {
      final profile = ref.read(profileProvider);
      if (profile.data?.isOnboarding == true) {
        context.go('/onboarding');
      } else {
        context.go('/dashboard');
      }
    } else {
      context.go('/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.primary500,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
              ),
              child: const Icon(
                Icons.business_center_rounded,
                size: 56,
                color: AppColors.primary500,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'FreelanceFlow',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: isDark ? AppColors.darkTextPrimary : Colors.white,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Client Management',
              style: TextStyle(
                fontSize: 16,
                color: isDark
                    ? AppColors.darkTextSecondary
                    : Colors.white.withValues(alpha: 0.8),
              ),
            ),
            const SizedBox(height: 48),
            const SizedBox(
              width: 32,
              height: 32,
              child: CircularProgressIndicator(
                strokeWidth: 3,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
