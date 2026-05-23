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
import '../../projects/data/projects_provider.dart';
import '../../projects/domain/project.dart';
import '../data/clients_provider.dart';
import '../domain/client.dart';

class ClientDetailScreen extends ConsumerStatefulWidget {
  final String clientId;

  const ClientDetailScreen({super.key, required this.clientId});

  @override
  ConsumerState<ClientDetailScreen> createState() =>
      _ClientDetailScreenState();
}

class _ClientDetailScreenState extends ConsumerState<ClientDetailScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _tabController.addListener(() {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final clientAsync = ref.watch(singleClientProvider(widget.clientId));

    return Scaffold(
      body: clientAsync.when(
        data: (client) {
          if (client == null) {
            return const Center(child: Text('Client not found'));
          }
          return NestedScrollView(
            headerSliverBuilder: (context, innerBoxIsScrolled) {
              return [
                _buildSliverAppBar(client),
                _buildTabBar(),
              ];
            },
            body: TabBarView(
              controller: _tabController,
              children: [
                _ClientOverviewTab(client: client),
                _ClientProjectsTab(client: client),
                _ClientTimeTab(client: client),
                _ClientExpensesTab(client: client),
              ],
            ),
          );
        },
        loading: () => const Center(child: LoadingDots()),
        error: (e, _) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.error_outline,
                size: 48,
                color: AppColors.error,
              ),
              const SizedBox(height: 16),
              Text(e.toString()),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () =>
                    ref.invalidate(singleClientProvider(widget.clientId)),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: _buildFAB(context),
    );
  }

  Widget _buildFAB(BuildContext context) {
    final tabIndex = _tabController.index;
    return FloatingActionButton.extended(
      key: ValueKey(tabIndex),
      onPressed: () {
        switch (tabIndex) {
          case 0:
            context.push('/clients/${widget.clientId}/edit');
          case 1:
            context.push('/projects/add');
          case 2:
            context.push('/time-tracking/add', extra: widget.clientId);
          case 3:
            context.push(
              '/expenses/add',
              extra: {'clientId': widget.clientId},
            );
        }
      },
      icon: Icon(
        switch (tabIndex) {
          0 => Icons.edit,
          1 => Icons.folder,
          2 => Icons.timer,
          3 => Icons.receipt_long,
          _ => Icons.add,
        },
      ),
      label: Text(
        switch (tabIndex) {
          0 => 'Edit',
          1 => 'New Project',
          2 => 'Log Time',
          3 => 'Add Expense',
          _ => 'Add',
        },
      ),
    );
  }

  Widget _buildSliverAppBar(Client client) {
    return SliverAppBar(
      expandedHeight: 200,
      floating: false,
      pinned: true,
      title: Text(
        client.name,
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        overflow: TextOverflow.ellipsis,
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.edit_outlined),
          onPressed: () => context.push('/clients/${client.id}/edit'),
        ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          padding: const EdgeInsets.fromLTRB(16, 60, 16, 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Row(
                children: [
                  Hero(
                    tag: 'client_avatar_${client.id}',
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: _parseColor(client.avatarColor),
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          client.name[0].toUpperCase(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (client.company != null && client.company!.isNotEmpty)
                          Text(
                            client.company!,
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(color: AppColors.lightTextSecondary),
                            overflow: TextOverflow.ellipsis,
                          ),
                        if (client.email != null && client.email!.isNotEmpty)
                          Text(
                            client.email!,
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(color: AppColors.lightTextSecondary),
                            overflow: TextOverflow.ellipsis,
                          ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                client.name,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 8),
              if (client.tags.isNotEmpty)
                Wrap(
                  spacing: 4,
                  runSpacing: 4,
                  children:
                      client.tags
                          .map(
                            (tag) => Chip(
                              label: Text(
                                tag,
                                style: const TextStyle(fontSize: 11),
                              ),
                              padding: EdgeInsets.zero,
                              materialTapTargetSize:
                                  MaterialTapTargetSize.shrinkWrap,
                            ),
                          )
                          .toList(),
                ),
              if (client.tags.isNotEmpty) const SizedBox(height: 4),
              Row(
                children: [
                  const Icon(
                    Icons.access_time,
                    size: 16,
                    color: AppColors.lightTextSecondary,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    CurrencyFormatter.format(
                      client.defaultHourlyRate,
                      client.currency,
                    ),
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.lightTextSecondary,
                        ),
                  ),
                  const SizedBox(width: 16),
                  const Icon(
                    Icons.payments_outlined,
                    size: 16,
                    color: AppColors.lightTextSecondary,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    client.currency,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.lightTextSecondary,
                        ),
                  ),
                ],
              ),
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
        Tab(text: 'Overview'),
        Tab(text: 'Projects'),
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

  Color _parseColor(String hex) {
    try {
      return Color(int.parse(hex.replaceAll('#', '0xff')));
    } catch (_) {
      return AppColors.primary500;
    }
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

class _ClientOverviewTab extends ConsumerWidget {
  final Client client;

  const _ClientOverviewTab({required this.client});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final projectsAsync = ref.watch(clientProjectsProvider(client.id!));
    final expensesAsync = ref.watch(expensesProvider(clientId: client.id));
    final timeEntriesAsync = ref.watch(clientTimeEntriesProvider(client.id!));

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Client Information',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const Divider(),
                _infoRow('Name', client.name),
                if (client.company != null) _infoRow('Company', client.company!),
                if (client.email != null) _infoRow('Email', client.email!),
                if (client.phone != null) _infoRow('Phone', client.phone!),
                if (client.country != null) _infoRow('Country', client.country!),
                _infoRow('Currency', client.currency),
                _infoRow(
                  'Hourly Rate',
                  CurrencyFormatter.format(
                    client.defaultHourlyRate,
                    client.currency,
                  ),
                ),
                if (client.notes != null) _infoRow('Notes', client.notes!),
                _infoRow(
                  'Created',
                  DateFormat('MMM d, yyyy').format(client.createdAt),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        projectsAsync.when(
          data: (projects) => _summaryCard(
            context,
            'Projects',
            '${projects.length} total',
            '${projects.where((p) => p.status == ProjectStatus.inProgress).length} active',
            Icons.folder_outlined,
          ),
          loading: () => const SizedBox.shrink(),
          error: (_, __) => const SizedBox.shrink(),
        ),
        const SizedBox(height: 12),
        timeEntriesAsync.when(
          data: (entries) {
            final totalHours = entries.fold<double>(
              0,
              (sum, e) => sum + e.duration.inSeconds / 3600,
            );
            return _summaryCard(
              context,
              'Time Tracked',
              formatDuration(Duration(hours: totalHours.round())),
              '${entries.length} entries',
              Icons.timer_outlined,
            );
          },
          loading: () => const SizedBox.shrink(),
          error: (_, __) => const SizedBox.shrink(),
        ),
        const SizedBox(height: 12),
        expensesAsync.when(
          data: (expenses) {
            final total = expenses.fold<double>(
              0,
              (sum, e) => sum + e.amount,
            );
            return _summaryCard(
              context,
              'Expenses',
              CurrencyFormatter.format(total, client.currency),
              '${expenses.length} entries',
              Icons.receipt_long_outlined,
            );
          },
          loading: () => const SizedBox.shrink(),
          error: (_, __) => const SizedBox.shrink(),
        ),
      ],
    );
  }

  Widget _infoRow(String label, String value) {
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

  Widget _summaryCard(
    BuildContext context,
    String title,
    String value,
    String subtitle,
    IconData icon,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.primary500.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: AppColors.primary500),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: AppColors.lightTextSecondary,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    value,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  Text(
                    subtitle,
                    style: const TextStyle(fontSize: 11),
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

class _ClientProjectsTab extends ConsumerWidget {
  final Client client;

  const _ClientProjectsTab({required this.client});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final projectsAsync = ref.watch(clientProjectsProvider(client.id!));

    return projectsAsync.when(
      data: (projects) {
        if (projects.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.folder_outlined,
                  size: 48,
                  color: AppColors.lightTextSecondary,
                ),
                const SizedBox(height: 16),
                Text(
                  'No projects yet',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                Text(
                  'Create a project for this client',
                  style: TextStyle(color: AppColors.lightTextSecondary),
                ),
              ],
            ),
          );
        }
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: projects.length,
          itemBuilder: (context, index) {
            final project = projects[index];
            final statusColor = _statusColor(project.status);
            return Card(
              margin: const EdgeInsets.only(bottom: 8),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: statusColor.withValues(alpha: 0.1),
                  child: Icon(Icons.folder, color: statusColor),
                ),
                title: Text(project.title),
                subtitle: Text(
                  CurrencyFormatter.format(project.budget, project.currency),
                ),
                trailing: Text(
                  _statusLabel(project.status),
                  style: TextStyle(color: statusColor, fontSize: 12),
                ),
                onTap: () => context.push('/projects/${project.id}'),
              ),
            );
          },
        );
      },
      loading: () => const Center(child: LoadingDots()),
      error: (e, _) => Center(child: Text('Error: $e')),
    );
  }

  Color _statusColor(ProjectStatus status) {
    return switch (status) {
      ProjectStatus.inProgress => AppColors.statusActive,
      ProjectStatus.completed => AppColors.statusDone,
      ProjectStatus.onHold => AppColors.statusOnHold,
      ProjectStatus.cancelled => AppColors.error,
    };
  }

  String _statusLabel(ProjectStatus status) {
    return switch (status) {
      ProjectStatus.inProgress => 'In Progress',
      ProjectStatus.completed => 'Completed',
      ProjectStatus.onHold => 'On Hold',
      ProjectStatus.cancelled => 'Cancelled',
    };
  }
}

class _ClientTimeTab extends ConsumerWidget {
  final Client client;

  const _ClientTimeTab({required this.client});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final entriesAsync = ref.watch(clientTimeEntriesProvider(client.id!));

    return entriesAsync.when(
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
                  'Track time for this client',
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
            Card(
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
                            formatDuration(
                              Duration(hours: totalHours.round()),
                            ),
                            style: Theme.of(context).textTheme.titleLarge
                                ?.copyWith(fontWeight: FontWeight.bold),
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
                            CurrencyFormatter.format(
                              totalValue,
                              client.currency,
                            ),
                            style: Theme.of(context).textTheme.titleLarge
                                ?.copyWith(
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
            ),
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
        subtitle: Text(DateFormat('MMM d, yyyy').format(entry.startedAt)),
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
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.success,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ClientExpensesTab extends ConsumerWidget {
  final Client client;

  const _ClientExpensesTab({required this.client});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final expensesAsync = ref.watch(expensesProvider(clientId: client.id));

    return expensesAsync.when(
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
                  'Track expenses for this client',
                  style: TextStyle(color: AppColors.lightTextSecondary),
                ),
              ],
            ),
          );
        }

        final total = expenses.fold<double>(0, (sum, e) => sum + e.amount);

        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Card(
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
                            CurrencyFormatter.format(
                              total,
                              client.currency,
                            ),
                            style: Theme.of(context).textTheme.titleLarge
                                ?.copyWith(
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
            ),
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
    );
  }
}
