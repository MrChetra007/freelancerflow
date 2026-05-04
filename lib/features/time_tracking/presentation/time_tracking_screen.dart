import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/utils/duration_formatter.dart';
import '../../projects/data/projects_provider.dart';
import '../domain/time_entry.dart';
import '../data/time_entry_provider.dart';
import 'add_time_entry_screen.dart';
import 'widgets/billable_summary_card.dart';
import 'widgets/time_entry_tile.dart';
import 'widgets/timer_widget.dart';

class TimeTrackingScreen extends ConsumerWidget {
  const TimeTrackingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activeTimer = ref.watch(activeTimerProvider);
    final projects = ref.watch(projectsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Time Tracking'),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(activeTimerProvider);
        },
        child: CustomScrollView(
          slivers: [
            // Active Timer Card
            SliverToBoxAdapter(
              child: activeTimer.when(
                data: (entry) {
                  if (entry == null) return const SizedBox.shrink();
                  return Padding(
                    padding: const EdgeInsets.all(16),
                    child: TimerWidget(
                      entry: entry,
                      isRunning: true,
                      onStop: () async {
                        await ref
                            .read(timeEntryRepositoryProvider)
                            .stopTimer(entry.id!);
                        ref.invalidate(activeTimerProvider);
                      },
                    ),
                  );
                },
                loading: () => const SizedBox.shrink(),
                error: (_, __) => const SizedBox.shrink(),
              ),
            ),

            // Billable Summary
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: _MonthSummary(),
              ),
            ),

            // Filters
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: _TimeFilters(),
              ),
            ),

            // Time Entries List
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  'Recent Entries',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
            ),

            // Entries would go here - using project entries stream
            SliverFillRemaining(
              child: Center(
                child: _RecentEntries(),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => const AddTimeEntryScreen(),
            ),
          );
        },
        icon: const Icon(Icons.add),
        label: const Text('Log Time'),
      ),
    );
  }
}

class _MonthSummary extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final entries = ref.watch(unbilledTimeEntriesProvider(''));
    return entries.when(
      data: (data) => BillableSummaryCard(entries: data),
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
    );
  }
}

class _TimeFilters extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          FilterChip(
            selected: true,
            onSelected: (_) {},
            label: const Text('All'),
          ),
          const SizedBox(width: 8),
          FilterChip(
            selected: false,
            onSelected: (_) {},
            label: const Text('Billable'),
          ),
          const SizedBox(width: 8),
          FilterChip(
            selected: false,
            onSelected: (_) {},
            label: const Text('Unbilled'),
          ),
          const SizedBox(width: 8),
          FilterChip(
            selected: false,
            onSelected: (_) {},
            label: const Text('This Week'),
          ),
        ],
      ),
    );
  }
}

class _RecentEntries extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final projectsAsync = ref.watch(projectsProvider);

    return projectsAsync.when(
      data: (projects) {
        if (projects.isEmpty) {
          return const Center(
            child: Text('No time entries yet'),
          );
        }

        final projectId = projects.firstOrNull?.id;
        if (projectId == null) return const SizedBox.shrink();

        final entries = ref.watch(projectTimeEntriesProvider(projectId));

        return entries.when(
          data: (data) {
            if (data.isEmpty) {
              return const Center(
                child: Text('No time entries yet'),
              );
            }
            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: data.length,
              itemBuilder: (context, index) {
                final entry = data[index];
                return TimeEntryTile(
                  entry: entry,
                  onTap: () {
                    context.push('/time-tracking/add', extra: entry);
                  },
                );
              },
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (_, __) => const Center(child: Text('Error loading entries')),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (_, __) => const Center(child: Text('Error loading projects')),
    );
  }
}
