import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../features/settings/data/premium_provider.dart';

class ProGate extends ConsumerWidget {
  final Widget child;
  final VoidCallback? onBlocked;

  const ProGate({super.key, required this.child, this.onBlocked});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isPremium = ref.watch(isPremiumProvider);
    if (isPremium) return child;

    return GestureDetector(
      onTap: () {
        if (onBlocked != null) {
          onBlocked!();
        } else {
          _showProPrompt(context);
        }
      },
      child: child,
    );
  }

  void _showProPrompt(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => const _ProPromptSheet(),
    );
  }
}

class _ProPromptSheet extends StatelessWidget {
  const _ProPromptSheet();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 8, 24, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.amber.shade600,
                    Colors.amber.shade800,
                  ],
                ),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.workspace_premium,
                color: Colors.white,
                size: 48,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Upgrade to Pro',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'This feature is available for Pro users only',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 32),
            FilledButton.icon(
              onPressed: () {
                context.pop();
                context.push('/premium');
              },
              icon: const Icon(Icons.workspace_premium),
              label: const Text('Upgrade Now'),
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
            ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: () => context.pop(),
              child: const Text('Maybe Later'),
            ),
          ],
        ),
      ),
    );
  }
}

class ProGateButton extends ConsumerWidget {
  final Widget? child;
  final String? label;
  final IconData? icon;
  final VoidCallback onPressed;
  final bool isPro;

  const ProGateButton({
    super.key,
    this.child,
    this.label,
    this.icon,
    required this.onPressed,
    this.isPro = true,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (!isPro) {
      return child ??
          (label != null
              ? ElevatedButton(
                  onPressed: onPressed,
                  child: Text(label!),
                )
              : const SizedBox.shrink());
    }

    final isPremium = ref.watch(isPremiumProvider);

    if (isPremium) {
      return child ??
          (label != null
              ? ElevatedButton.icon(
                  onPressed: onPressed,
                  icon: icon != null ? Icon(icon) : const SizedBox.shrink(),
                  label: Text(label!),
                )
              : const SizedBox.shrink());
    }

    return child ??
        (label != null
            ? ElevatedButton.icon(
                onPressed: () {
                  showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                    ),
                    builder: (context) => const _ProPromptSheet(),
                  );
                },
                icon: const Icon(Icons.workspace_premium, size: 18),
                label: Text(label!),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.amber.shade700,
                  foregroundColor: Colors.white,
                ),
              )
            : const SizedBox.shrink());
  }
}
