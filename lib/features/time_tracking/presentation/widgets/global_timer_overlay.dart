import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/duration_formatter.dart';
import '../../data/time_entry_provider.dart';
import '../../domain/time_entry.dart';

class GlobalTimerOverlay extends ConsumerWidget {
  const GlobalTimerOverlay({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activeTimer = ref.watch(activeTimerProvider);

    return activeTimer.when(
      data: (entry) {
        if (entry == null) return const SizedBox.shrink();
        return _OverlayTimerView(entry: entry);
      },
      loading: () => const SizedBox.shrink(),
      error: (_, _) => const SizedBox.shrink(),
    );
  }
}

class _OverlayTimerView extends ConsumerStatefulWidget {
  final TimeEntry entry;

  const _OverlayTimerView({required this.entry});

  @override
  ConsumerState<_OverlayTimerView> createState() => _OverlayTimerViewState();
}

class _OverlayTimerViewState extends ConsumerState<_OverlayTimerView>
    with SingleTickerProviderStateMixin {
  late DateTime _now;
  Timer? _timer;
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _now = DateTime.now();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) {
        setState(() => _now = DateTime.now());
      }
    });
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final duration = _now.difference(widget.entry.startedAt);

    return GestureDetector(
      onTap: () => context.push('/time-tracking'),
      child: Container(
        margin: const EdgeInsets.fromLTRB(12, 0, 12, 12),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: Theme.of(context).brightness == Brightness.dark
              ? const Color(0xFF1E293B)
              : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: AppColors.success.withValues(alpha: 0.5),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.success.withValues(alpha: 0.2),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            FadeTransition(
              opacity: _pulseController,
              child: Container(
                width: 10,
                height: 10,
                decoration: const BoxDecoration(
                  color: AppColors.success,
                  shape: BoxShape.circle,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    widget.entry.description ?? 'Timer Running',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    formatDuration(duration),
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppColors.success,
                        ),
                  ),
                ],
              ),
            ),
            TextButton.icon(
              onPressed: () async {
                await ref
                    .read(timeEntryRepositoryProvider)
                    .stopTimer(widget.entry.id!);
                ref.invalidate(activeTimerProvider);
              },
              icon: const Icon(Icons.stop_circle, color: AppColors.error),
              label: const Text(
                'Stop',
                style: TextStyle(color: AppColors.error),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
