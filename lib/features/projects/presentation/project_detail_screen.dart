import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/utils/duration_formatter.dart';
import '../../../../core/widgets/loading_widget.dart';
import '../../time_tracking/data/time_entry_provider.dart';
import '../../time_tracking/domain/time_entry.dart';
import '../../expenses/data/expense_provider.dart';
import '../../expenses/presentation/widgets/expense_tile.dart';
import '../data/projects_provider.dart';
import '../domain/project.dart';

class ProjectDetailScreen extends ConsumerStatefulWidget {
  final String projectId;

  const ProjectDetailScreen({super.key, required this.projectId});

  @override
  ConsumerState<ProjectDetailScreen> createState() =>
      _ProjectDetailScreenState();
}

class _ProjectDetailScreenState extends ConsumerState<ProjectDetailScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final projectAsync = ref.watch(singleProjectProvider(widget.projectId));

    return Scaffold(
      body: projectAsync.when(
        data: (project) {
          if (project == null) {
            return const Center(child: Text('Project not found'));
          }
          return NestedScrollView(
            headerSliverBuilder: (context, innerBoxIsScrolled) {
              return [
                _buildSliverAppBar(project),
                _buildTabBar(),
              ];
            },
            body: TabBarView(
              controller: _tabController,
              children: [
                _ProjectDetailsTab(project: project),
                _ProjectTimeTab(project: project),
                _ProjectExpensesTab(project: project),
              ],
            ),
          );
        },
        loading: () => const Center(child: LoadingDots()),
        error: (e, _) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 48, color: AppColors.error),
              const SizedBox(height: 16),
              Text(e.toString()),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () =>
                    ref.invalidate(singleProjectProvider(widget.projectId)),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSliverAppBar(Project project) {
    final statusColor = _getStatusColor(project.status);
    final statusLabel = _getStatusLabel(project.status);

    return SliverAppBar(
      expandedHeight: 180,
      floating: false,
      pinned: true,
      actions: [
        IconButton(
          icon: const Icon(Icons.edit_outlined),
          onPressed: () => context.push('/projects/${project.id}/edit'),
        ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        title: Text(
          project.title,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        background: Container(
          padding: const EdgeInsets.fromLTRB(16, 60, 16, 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Chip(
                label: Text(
                  statusLabel,
                  style: const TextStyle(fontSize: 12, color: Colors.white),
                ),
                backgroundColor: statusColor,
                padding: EdgeInsets.zero,
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(
                    Icons.account_balance_wallet_outlined,
                    size: 16,
                    color: AppColors.lightTextSecondary,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    CurrencyFormatter.format(project.budget, project.currency),
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.lightTextSecondary,
                        ),
                  ),
                  if (project.deadline != null) ...[
                    const SizedBox(width: 16),
                    const Icon(
                      Icons.calendar_today_outlined,
                      size: 16,
                      color: AppColors.lightTextSecondary,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      DateFormat('MMM d, yyyy').format(project.deadline!),
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppColors.lightTextSecondary,
                          ),
                    ),
                  ],
                ],
              ),
              if (project.description != null) ...[
                const SizedBox(height: 4),
                Text(
                  project.description!,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.lightTextSecondary,
                      ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTabBar() {
    final tabBar = TabBar(
      controller: _tabController,
      tabs: const [
        Tab(text: 'Details'),
        Tab(text: 'Time'),
        Tab(text: 'Expenses'),
      ],
      indicatorColor: AppColors.primary500,
      labelColor: AppColors.primary500,
      unselectedLabelColor: AppColors.lightTextSecondary,
    );
    return SliverPersistentHeader(
      pinned: true,
      delegate: _SliverTabDelegate(kTextTabBarHeight, tabBar),
    );
  }

  Color _getStatusColor(ProjectStatus status) {
    return switch (status) {
      ProjectStatus.inProgress => AppColors.statusActive,
      ProjectStatus.completed => AppColors.statusDone,
      ProjectStatus.onHold => AppColors.statusOnHold,
      ProjectStatus.cancelled => AppColors.error,
    };
  }

  String _getStatusLabel(ProjectStatus status) {
    return switch (status) {
      ProjectStatus.inProgress => 'In Progress',
      ProjectStatus.completed => 'Completed',
      ProjectStatus.onHold => 'On Hold',
      ProjectStatus.cancelled => 'Cancelled',
    };
  }
}

class _SliverTabDelegate extends SliverPersistentHeaderDelegate {
  final double height;
  final Widget child;

  _SliverTabDelegate(this.height, this.child);

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return Material(
      color: Theme.of(context).scaffoldBackgroundColor,
      child: child,
    );
  }

  @override
  double get maxExtent => height;
  @override
  double get minExtent => height;
  @override
  bool shouldRebuild(covariant SliverPersistentHeaderDelegate oldDelegate) =>
      false;
}

class _ProjectDetailsTab extends ConsumerWidget {
  final Project project;

  const _ProjectDetailsTab({required this.project});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final milestonesAsync = ref.watch(milestonesProvider(project.id!));

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildInfoCard(context),
        const SizedBox(height: 16),
        milestonesAsync.when(
          data: (milestones) => _buildMilestonesSection(context, ref, milestones),
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Text('Error: $e'),
        ),
      ],
    );
  }

  Widget _buildInfoCard(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Project Information',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const Divider(),
            _buildInfoRow('Client ID', project.clientId),
            _buildInfoRow(
              'Start Date',
              project.startDate != null
                  ? DateFormat('MMM d, yyyy').format(project.startDate!)
                  : 'Not set',
            ),
            _buildInfoRow(
              'Deadline',
              project.deadline != null
                  ? DateFormat('MMM d, yyyy').format(project.deadline!)
                  : 'Not set',
            ),
            _buildInfoRow('Currency', project.currency),
            _buildInfoRow('Created', DateFormat('MMM d, yyyy').format(project.createdAt)),
            if (project.completedAt != null)
              _buildInfoRow(
                'Completed',
                DateFormat('MMM d, yyyy').format(project.completedAt!),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: const TextStyle(
                color: AppColors.lightTextSecondary,
                fontSize: 13,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMilestonesSection(
    BuildContext context,
    WidgetRef ref,
    List<dynamic> milestones,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Milestones',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                TextButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.add, size: 18),
                  label: const Text('Add'),
                ),
              ],
            ),
            if (milestones.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 24),
                child: Center(
                  child: Text(
                    'No milestones yet',
                    style: TextStyle(color: AppColors.lightTextSecondary),
                  ),
                ),
              )
            else
              ...milestones.map(
                (m) => ListTile(
                  leading: Icon(
                    m.isCompleted
                        ? Icons.check_circle
                        : Icons.radio_button_unchecked,
                    color:
                        m.isCompleted ? AppColors.success : AppColors.lightTextSecondary,
                  ),
                  title: Text(m.title),
                  subtitle:
                      m.dueDate != null
                          ? Text(DateFormat('MMM d, yyyy').format(m.dueDate!))
                          : null,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _ProjectTimeTab extends ConsumerWidget {
  final Project project;

  const _ProjectTimeTab({required this.project});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final entriesAsync = ref.watch(projectTimeEntriesProvider(project.id!));

    return Column(
      children: [
        Expanded(
          child: entriesAsync.when(
            data: (entries) {
              if (entries.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.timer_outlined,
                        size: 48,
                        color: AppColors.lightTextSecondary,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No time entries yet',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Start tracking time for this project',
                        style: TextStyle(color: AppColors.lightTextSecondary),
                      ),
                    ],
                  ),
                );
              }

              final totalHours = entries.fold<double>(
                0,
                (sum, e) => sum + e.duration.inSeconds / 3600,
              );
              final totalValue = entries.fold<double>(
                0,
                (sum, e) => sum + (e.duration.inSeconds / 3600) * e.hourlyRate,
              );

              return ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  _buildTimeSummary(context, totalHours, totalValue),
                  const SizedBox(height: 16),
                  ...entries.map(
                    (e) => Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: _TimeEntryTile(entry: e),
                    ),
                  ),
                ],
              );
            },
            loading: () => const Center(child: LoadingDots()),
            error: (e, _) => Center(child: Text('Error: $e')),
          ),
        ),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 10,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          child: Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () =>
                      context.push('/time-tracking/add', extra: project.id),
                  icon: const Icon(Icons.add),
                  label: const Text('Add Entry'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: FilledButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.play_arrow),
                  label: const Text('Start Timer'),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTimeSummary(
    BuildContext context,
    double totalHours,
    double totalValue,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Total Hours',
                    style: TextStyle(
                      color: AppColors.lightTextSecondary,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    formatDuration(Duration(hours: totalHours.round())),
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Total Value',
                    style: TextStyle(
                      color: AppColors.lightTextSecondary,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    CurrencyFormatter.format(totalValue, project.currency),
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppColors.success,
                        ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TimeEntryTile extends StatelessWidget {
  final TimeEntry entry;

  const _TimeEntryTile({required this.entry});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: const CircleAvatar(
          child: Icon(Icons.timer_outlined, size: 18),
        ),
        title: Text(entry.description ?? 'No description'),
        subtitle: Text(
          DateFormat('MMM d, yyyy').format(entry.startedAt),
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              formatDuration(entry.duration),
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            Text(
              CurrencyFormatter.format(
                (entry.duration.inSeconds / 3600) * entry.hourlyRate,
                'USD',
              ),
              style: const TextStyle(fontSize: 12, color: AppColors.success),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProjectExpensesTab extends ConsumerWidget {
  final Project project;

  const _ProjectExpensesTab({required this.project});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final expensesAsync = ref.watch(
      expensesProvider(projectId: project.id),
    );

    return Column(
      children: [
        Expanded(
          child: expensesAsync.when(
            data: (expenses) {
              if (expenses.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.receipt_long_outlined,
                        size: 48,
                        color: AppColors.lightTextSecondary,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No expenses yet',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Track expenses for this project',
                        style: TextStyle(color: AppColors.lightTextSecondary),
                      ),
                    ],
                  ),
                );
              }

              final totalExpenses =
                  expenses.fold<double>(0, (sum, e) => sum + e.amount);

              return ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  _buildExpenseSummary(context, totalExpenses),
                  const SizedBox(height: 16),
                  ...expenses.map(
                    (e) => Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: ExpenseTile(expense: e),
                    ),
                  ),
                ],
              );
            },
            loading: () => const Center(child: LoadingDots()),
            error: (e, _) => Center(child: Text('Error: $e')),
          ),
        ),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 10,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          child: FilledButton.icon(
            onPressed: () =>
                context.push('/expenses/add', extra: {'projectId': project.id}),
            icon: const Icon(Icons.add),
            label: const Text('Add Expense'),
          ),
        ),
      ],
    );
  }

  Widget _buildExpenseSummary(BuildContext context, double total) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            const Icon(Icons.receipt_long, color: AppColors.error),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Total Expenses',
                    style: TextStyle(
                      color: AppColors.lightTextSecondary,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    CurrencyFormatter.format(total, project.currency),
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppColors.error,
                        ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
