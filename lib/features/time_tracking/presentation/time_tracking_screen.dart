import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../projects/data/projects_provider.dart';
import '../../projects/domain/project.dart';
import '../domain/time_entry.dart';
import '../data/time_entry_provider.dart';
import 'widgets/billable_summary_card.dart';
import 'widgets/time_entry_tile.dart';
import 'widgets/timer_widget.dart';

enum TimeFilter { all, billable, unbilled, thisWeek, thisMonth }

class TimeTrackingScreen extends ConsumerStatefulWidget {
  const TimeTrackingScreen({super.key});

  @override
  ConsumerState<TimeTrackingScreen> createState() =>
      _TimeTrackingScreenState();
}

class _TimeTrackingScreenState extends ConsumerState<TimeTrackingScreen> {
  TimeFilter _selectedFilter = TimeFilter.all;

  @override
  Widget build(BuildContext context) {
    final activeTimer = ref.watch(activeTimerProvider);
    final entriesAsync = ref.watch(watchAllTimeEntriesProvider);
    final projectsAsync = ref.watch(projectsProvider);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        title: const Text('Time Tracking'),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(activeTimerProvider);
          ref.invalidate(watchAllTimeEntriesProvider);
        },
        child: CustomScrollView(
          slivers: [
            // Active Timer Card
            SliverToBoxAdapter(
              child: activeTimer.when(
                data: (entry) {
                  if (entry == null) return const SizedBox.shrink();
                  return projectsAsync.when(
                    data: (projects) {
                      final project = projects
                          .where((p) => p.id == entry.projectId)
                          .firstOrNull;
                      return Padding(
                        padding: const EdgeInsets.all(16),
                        child: TimerWidget(
                          entry: entry,
                          isRunning: true,
                          projectName: project?.title,
                          onStop: () async {
                            await ref
                                .read(timeEntryRepositoryProvider)
                                .stopTimer(entry.id!);
                            ref.invalidate(activeTimerProvider);
                            ref.invalidate(watchAllTimeEntriesProvider);
                          },
                        ),
                      );
                    },
                    loading: () => Padding(
                      padding: const EdgeInsets.all(16),
                      child: TimerWidget(
                        entry: entry,
                        isRunning: true,
                        onStop: () async {
                          await ref
                              .read(timeEntryRepositoryProvider)
                              .stopTimer(entry.id!);
                          ref.invalidate(activeTimerProvider);
                          ref.invalidate(watchAllTimeEntriesProvider);
                        },
                      ),
                    ),
                    error: (e, _) => Padding(
                      padding: const EdgeInsets.all(16),
                      child: TimerWidget(
                        entry: entry,
                        isRunning: true,
                        onStop: () async {
                          await ref
                              .read(timeEntryRepositoryProvider)
                              .stopTimer(entry.id!);
                          ref.invalidate(activeTimerProvider);
                          ref.invalidate(watchAllTimeEntriesProvider);
                        },
                      ),
                    ),
                  );
                },
                loading: () => const SizedBox.shrink(),
                error: (e, _) => const SizedBox.shrink(),
              ),
            ),

            // Billable Summary (this month)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: _MonthSummary(),
              ),
            ),

            // Filters
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                child: _TimeFilters(
                  selected: _selectedFilter,
                  onChanged: (filter) {
                    setState(() => _selectedFilter = filter);
                  },
                ),
              ),
            ),

            // Entries header
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                child: Text(
                  'Recent Entries',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
            ),

            // Entries List
            SliverToBoxAdapter(
              child: entriesAsync.when(
                data: (allEntries) {
                  final filtered = _applyFilter(allEntries, _selectedFilter);
                  if (filtered.isEmpty) {
                    return const SizedBox(
                      height: 200,
                      child: Center(
                        child: Text(
                          'No time entries yet.\nTap + to start tracking.',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.grey),
                        ),
                      ),
                    );
                  }

                  return projectsAsync.when(
                    data: (projects) {
                      final projectMap = <String, Project>{
                        for (final p in projects)
                          if (p.id != null) p.id!: p,
                      };
                      final grouped = _groupByDate(filtered);
                      return _GroupedEntriesList(
                        grouped: grouped,
                        projectMap: projectMap,
                      );
                    },
                    loading: () => const Center(
                      child: CircularProgressIndicator(),
                    ),
                    error: (e, _) => _GroupedEntriesList(
                      grouped: _groupByDate(filtered),
                      projectMap: const {},
                    ),
                  );
                },
                loading: () => const Center(
                  child: Padding(
                    padding: EdgeInsets.all(32),
                    child: CircularProgressIndicator(),
                  ),
                ),
                error: (_, e) => Center(
                  child: Text('Error loading entries: $e'),
                ),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 80)),
          ],
        ),
      ),
      floatingActionButton: _TimeTrackingFab(),
    );
  }

  List<TimeEntry> _applyFilter(
    List<TimeEntry> entries,
    TimeFilter filter,
  ) {
    final now = DateTime.now();
    final stopped =
        entries.where((e) => !e.isRunning).toList();

    return switch (filter) {
      TimeFilter.all => stopped,
      TimeFilter.billable =>
        stopped.where((e) => e.isBillable).toList(),
      TimeFilter.unbilled =>
        stopped.where((e) => e.isBillable && !e.isBilled).toList(),
      TimeFilter.thisWeek =>
        stopped.where((e) {
          final startOfWeek =
              now.subtract(Duration(days: now.weekday - 1));
          final thisWeekStart = DateTime(
            startOfWeek.year,
            startOfWeek.month,
            startOfWeek.day,
          );
          return !e.startedAt.isBefore(thisWeekStart);
        }).toList(),
      TimeFilter.thisMonth =>
        stopped.where((e) {
          final startOfMonth = DateTime(now.year, now.month, 1);
          return !e.startedAt.isBefore(startOfMonth);
        }).toList(),
    };
  }

  Map<DateTime, List<TimeEntry>> _groupByDate(List<TimeEntry> entries) {
    final grouped = <DateTime, List<TimeEntry>>{};
    for (final entry in entries) {
      final date = DateTime(
        entry.startedAt.year,
        entry.startedAt.month,
        entry.startedAt.day,
      );
      grouped.putIfAbsent(date, () => []).add(entry);
    }
    final sortedKeys = grouped.keys.toList()
      ..sort((a, b) => b.compareTo(a));
    return {for (final k in sortedKeys) k: grouped[k]!};
  }
}

class _MonthSummary extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final entries = ref.watch(thisMonthTimeEntriesProvider);
    return entries.when(
      data: (data) => BillableSummaryCard(entries: data),
      loading: () => const SizedBox.shrink(),
      error: (e, _) => const SizedBox.shrink(),
    );
  }
}

class _TimeFilters extends StatelessWidget {
  final TimeFilter selected;
  final ValueChanged<TimeFilter> onChanged;

  const _TimeFilters({
    required this.selected,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _FilterChip(
            label: 'All',
            selected: selected == TimeFilter.all,
            onTap: () => onChanged(TimeFilter.all),
          ),
          const SizedBox(width: 8),
          _FilterChip(
            label: 'Billable',
            selected: selected == TimeFilter.billable,
            onTap: () => onChanged(TimeFilter.billable),
          ),
          const SizedBox(width: 8),
          _FilterChip(
            label: 'Unbilled',
            selected: selected == TimeFilter.unbilled,
            onTap: () => onChanged(TimeFilter.unbilled),
          ),
          const SizedBox(width: 8),
          _FilterChip(
            label: 'This Week',
            selected: selected == TimeFilter.thisWeek,
            onTap: () => onChanged(TimeFilter.thisWeek),
          ),
          const SizedBox(width: 8),
          _FilterChip(
            label: 'This Month',
            selected: selected == TimeFilter.thisMonth,
            onTap: () => onChanged(TimeFilter.thisMonth),
          ),
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return FilterChip(
      selected: selected,
      onSelected: (_) => onTap(),
      label: Text(label),
      showCheckmark: false,
    );
  }
}

class _GroupedEntriesList extends StatelessWidget {
  final Map<DateTime, List<TimeEntry>> grouped;
  final Map<String, Project> projectMap;

  const _GroupedEntriesList({
    required this.grouped,
    required this.projectMap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: grouped.entries.map((entry) {
        final date = entry.key;
        final entries = entry.value;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
              child: Text(
                _formatDateHeader(date),
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      color: Theme.of(context).colorScheme.secondary,
                    ),
              ),
            ),
            ...entries.map(
              (e) => TimeEntryTile(
                entry: e,
                projectName: projectMap[e.projectId]?.title,
                onTap: () {
                  context.push('/time-tracking/add', extra: e);
                },
              ),
            ),
            const Divider(height: 1),
          ],
        );
      }).toList(),
    );
  }

  String _formatDateHeader(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final entryDate = DateTime(date.year, date.month, date.day);

    if (entryDate == today) return 'Today';
    if (entryDate == yesterday) return 'Yesterday';

    final diff = today.difference(entryDate).inDays;
    if (diff < 7) {
      return _dayOfWeek(date);
    }
    return '${_monthName(date.month)} ${date.day}, ${date.year}';
  }

  String _dayOfWeek(DateTime date) {
    const days = [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday',
    ];
    return days[date.weekday - 1];
  }

  String _monthName(int month) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return months[month - 1];
  }
}

class _TimeTrackingFab extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return FloatingActionButton.extended(
      onPressed: () => _showFabOptions(context, ref),
      icon: const Icon(Icons.timer),
      label: const Text('Track Time'),
    );
  }

  void _showFabOptions(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.success.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.play_circle_filled,
                  color: AppColors.success,
                ),
              ),
              title: const Text('Start Timer'),
              subtitle: const Text('Begin tracking time live'),
              onTap: () {
                Navigator.pop(ctx);
                context.push('/time-tracking/add');
              },
            ),
            const Divider(height: 1),
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.edit_calendar,
                  color: Theme.of(context).primaryColor,
                ),
              ),
              title: const Text('Log Manual Entry'),
              subtitle: const Text('Add a past time entry'),
              onTap: () {
                Navigator.pop(ctx);
                context.push('/time-tracking/add');
              },
            ),
          ],
        ),
      ),
    );
  }
}
