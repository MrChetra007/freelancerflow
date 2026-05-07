import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/duration_formatter.dart';
import '../../../time_tracking/data/time_entry_provider.dart';
import '../../../time_tracking/domain/time_entry.dart';

class ActiveTimerBanner extends ConsumerWidget {
  const ActiveTimerBanner({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activeTimer = ref.watch(activeTimerProvider);

    return activeTimer.when(
      data: (entry) {
        if (entry == null) return const SizedBox.shrink();
        return _ActiveTimerView(entry: entry);
      },
      loading: () => const SizedBox.shrink(),
      error: (_, _) => const SizedBox.shrink(),
    );
  }
}

class _ActiveTimerView extends ConsumerStatefulWidget {
  final TimeEntry entry;

  const _ActiveTimerView({required this.entry});

  @override
  ConsumerState<_ActiveTimerView> createState() => _ActiveTimerViewState();
}

class _ActiveTimerViewState extends ConsumerState<_ActiveTimerView> {
  late DateTime _now;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _now = DateTime.now();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) {
        setState(() {
          _now = DateTime.now();
        });
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final duration = _now.difference(widget.entry.startedAt);

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.success.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.success.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.timer,
            color: AppColors.success,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Timer Running',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.success,
                        fontWeight: FontWeight.w600,
                      ),
                ),
                Text(
                  formatDuration(duration),
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.stop_circle, color: AppColors.error),
            onPressed: () async {
              await ref
                  .read(timeEntryRepositoryProvider)
                  .stopTimer(widget.entry.id!);
              ref.invalidate(activeTimerProvider);
            },
          ),
        ],
      ),
    );
  }
}
