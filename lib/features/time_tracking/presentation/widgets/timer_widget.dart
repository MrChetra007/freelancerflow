import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/duration_formatter.dart';
import '../../domain/time_entry.dart';
import '../time_tracking_screen.dart';

class TimerWidget extends ConsumerWidget {
  final TimeEntry? entry;
  final bool isRunning;
  final VoidCallback? onStop;

  const TimerWidget({
    super.key,
    this.entry,
    this.isRunning = false,
    this.onStop,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isRunning
              ? AppColors.success.withValues(alpha: 0.5)
              : Theme.of(context).dividerColor,
        ),
      ),
      child: Column(
        children: [
          if (isRunning)
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _PulseDot(),
                const SizedBox(width: 8),
                Text(
                  'TIMER RUNNING',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: AppColors.success,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.2,
                      ),
                ),
              ],
            ),
          if (isRunning) const SizedBox(height: 12),
          _LiveTimer(entry: entry, isRunning: isRunning),
          if (entry != null) ...[
            const SizedBox(height: 8),
            Text(
              entry!.description ?? 'No description',
              style: Theme.of(context).textTheme.bodySmall,
              textAlign: TextAlign.center,
            ),
          ],
          const SizedBox(height: 16),
          if (isRunning && onStop != null)
            ElevatedButton.icon(
              onPressed: onStop,
              icon: const Icon(Icons.stop_circle, size: 20),
              label: const Text('Stop Timer'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.error,
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 48),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _PulseDot extends StatefulWidget {
  @override
  _PulseDotState createState() => _PulseDotState();
}

class _PulseDotState extends State<_PulseDot>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _controller,
      child: Container(
        width: 8,
        height: 8,
        decoration: const BoxDecoration(
          color: AppColors.success,
          shape: BoxShape.circle,
        ),
      ),
    );
  }
}

class _LiveTimer extends StatefulWidget {
  final TimeEntry? entry;
  final bool isRunning;

  const _LiveTimer({this.entry, this.isRunning = false});

  @override
  _LiveTimerState createState() => _LiveTimerState();
}

class _LiveTimerState extends State<_LiveTimer> {
  late DateTime _now;

  @override
  void initState() {
    super.initState();
    _now = DateTime.now();
    Stream.periodic(const Duration(seconds: 1), (_) {
      if (mounted) {
        setState(() {
          _now = DateTime.now();
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (widget.entry == null) {
      return Text(
        '00:00:00',
        style: Theme.of(context).textTheme.headlineLarge?.copyWith(
              fontWeight: FontWeight.bold,
              fontFamily: 'monospace',
            ),
      );
    }
    final duration = widget.isRunning
        ? _now.difference(widget.entry!.startedAt)
        : (widget.entry!.endedAt != null
            ? widget.entry!.endedAt!.difference(widget.entry!.startedAt)
            : Duration.zero);
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);
    return Text(
      '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}',
      style: Theme.of(context).textTheme.headlineLarge?.copyWith(
            fontWeight: FontWeight.bold,
            fontFamily: 'monospace',
          ),
    );
  }
}
