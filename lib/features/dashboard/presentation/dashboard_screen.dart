import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../core/widgets/loading_widget.dart';
import '../data/dashboard_provider.dart';
import '../../projects/domain/project.dart';
import '../../settings/data/premium_provider.dart';
import 'widgets/active_timer_banner.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  @override
  Widget build(BuildContext context) {
    final stats = ref.watch(dashboardStatsProvider);
    final isPremium = ref.watch(isPremiumProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        actions: [
          if (isPremium)
            Container(
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.amber.shade600, Colors.amber.shade800],
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.workspace_premium,
                    color: Colors.white,
                    size: 18,
                  ),
                  const SizedBox(width: 4),
                  const Text(
                    'PRO',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () => context.push('/settings'),
          ),
        ],
      ),
      floatingActionButton: const _QuickActionsFab(),
      body: stats.when(
        data: (data) => RefreshIndicator(
          onRefresh: () async {
            ref.invalidate(dashboardStatsProvider);
          },
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              if (isPremium) const ActiveTimerBanner(),
              _buildWelcomeSection(context),
              const SizedBox(height: 24),
              _buildSummaryCards(context, data, isPremium),
              const SizedBox(height: 24),
              if (isPremium)
                _buildMonthlyEarningsChart(context, data)
              else
                _buildMonthlyEarningsChartPlaceholder(context),
              const SizedBox(height: 24),
              _buildProjectStatusChart(context, data),
            ],
          ),
        ),
        loading: () => const Center(
          child: LoadingDots(),
        ),
        error: (e, _) => ErrorDisplay(
          message: e.toString(),
          onRetry: () => ref.invalidate(dashboardStatsProvider),
        ),
      ),
    );
  }

  Widget _buildWelcomeSection(BuildContext context) {
    final hour = DateTime.now().hour;
    String greeting;
    if (hour < 12) {
      greeting = 'Good morning';
    } else if (hour < 17) {
      greeting = 'Good afternoon';
    } else {
      greeting = 'Good evening';
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          greeting,
          style: Theme.of(
            context,
          ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        Text(
          "Here's your business overview",
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(color: AppColors.lightTextSecondary),
        ),
      ],
    );
  }

  Widget _buildSummaryCards(BuildContext context, DashboardStats stats, bool isPremium) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _StatCard(
                title: 'This Month',
                value: CurrencyFormatter.formatCompact(
                  stats.monthlyEarnings,
                  'USD',
                ),
                icon: Icons.trending_up,
                color: AppColors.statusPaid,
                onTap: () => context.go('/payments'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _StatCard(
                title: 'Expenses',
                value: CurrencyFormatter.formatCompact(
                  stats.expensesThisMonth,
                  'USD',
                ),
                icon: Icons.monetization_on_outlined,
                color: AppColors.error,
                onTap: () => context.push('/expenses'),
              ),
            ),
          ],
        ),
        if (isPremium) ...[
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _StatCard(
                  title: 'Net Profit',
                  value: CurrencyFormatter.formatCompact(
                    stats.profitThisMonth,
                    'USD',
                  ),
                  icon: Icons.account_balance_wallet,
                  color:
                      stats.profitThisMonth >= 0
                          ? AppColors.success
                          : AppColors.error,
                  onTap: () => context.go('/payments'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _StatCard(
                  title: 'Total Clients',
                  value: stats.totalClients.toString(),
                  icon: Icons.people,
                  color: AppColors.primary500,
                  onTap: () => context.go('/clients'),
                ),
              ),
            ],
          ),
        ] else ...[
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _StatCard(
                  title: 'Total Clients',
                  value: stats.totalClients.toString(),
                  icon: Icons.people,
                  color: AppColors.primary500,
                  onTap: () => context.go('/clients'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _StatCard(
                  title: 'Active Projects',
                  value: stats.activeProjects.toString(),
                  icon: Icons.folder_open,
                  color: AppColors.info,
                  onTap: () => context.go('/projects'),
                ),
              ),
            ],
          ),
        ],
        if (isPremium) ...[
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _StatCard(
                  title: 'Active Projects',
                  value: stats.activeProjects.toString(),
                  icon: Icons.folder_open,
                  color: AppColors.info,
                  onTap: () => context.go('/projects'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _StatCard(
                  title: 'Pending Invoices',
                  value: CurrencyFormatter.formatCompact(
                    stats.pendingInvoices,
                    'USD',
                  ),
                  icon: Icons.receipt_long,
                  color: AppColors.warning,
                  onTap: () => context.go('/invoices'),
                ),
              ),
            ],
          ),
        ],
        if (isPremium && stats.unbilledTimeValue > 0) ...[
          const SizedBox(height: 12),
          GestureDetector(
            onTap: () => context.push('/time-tracking'),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.info.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.info.withValues(alpha: 0.3)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.timer_outlined, color: AppColors.info),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Unbilled Time',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: AppColors.info,
                          ),
                        ),
                        Text(
                          CurrencyFormatter.format(
                            stats.unbilledTimeValue,
                            'USD',
                          ),
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.info,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Icon(Icons.chevron_right, color: AppColors.info),
                ],
              ),
            ),
          ),
        ],
        if (stats.overdueProjects > 0) ...[
          const SizedBox(height: 12),
          GestureDetector(
            onTap: () => context.push('/projects'),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.error.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.error.withValues(alpha: 0.3)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.warning, color: AppColors.error),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${stats.overdueProjects} overdue project${stats.overdueProjects > 1 ? 's' : ''}',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: AppColors.error,
                          ),
                        ),
                        const Text(
                          'Tap to view and take action',
                          style: TextStyle(fontSize: 12, color: AppColors.error),
                        ),
                      ],
                    ),
                  ),
                  const Icon(Icons.chevron_right, color: AppColors.error),
                ],
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildMonthlyEarningsChart(
    BuildContext context,
    DashboardStats stats,
  ) {
    final maxAmount = stats.monthlyEarningsData.fold(
      0.0,
      (max, e) {
        final combined = e.revenue + e.expenses;
        return combined > max ? combined : max;
      },
    );

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
                  'Revenue & Expenses',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Row(
                  children: [
                    _buildLegendItem(
                      'Revenue',
                      AppColors.success,
                    ),
                    const SizedBox(width: 12),
                    _buildLegendItem(
                      'Expenses',
                      AppColors.error,
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 24),
            SizedBox(
              height: 200,
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  maxY: maxAmount > 0 ? maxAmount * 1.2 : 100,
                  barTouchData: BarTouchData(
                    touchTooltipData: BarTouchTooltipData(
                      getTooltipItem: (group, groupIndex, rod, rodIndex) {
                        final data = stats.monthlyEarningsData[groupIndex];
                        final label = rodIndex == 0
                            ? 'Revenue: ${CurrencyFormatter.format(data.revenue, 'USD')}'
                            : 'Expenses: ${CurrencyFormatter.format(data.expenses, 'USD')}';
                        return BarTooltipItem(
                          label,
                          const TextStyle(color: Colors.white),
                        );
                      },
                    ),
                  ),
                  titlesData: FlTitlesData(
                    show: true,
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          if (value.toInt() >=
                              stats.monthlyEarningsData.length) {
                            return const SizedBox();
                          }
                          final month =
                              stats.monthlyEarningsData[value.toInt()].month;
                          return Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Text(
                              DateFormat('MMM').format(month),
                              style: TextStyle(
                                fontSize: 12,
                                color: AppColors.lightTextSecondary,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    leftTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                  ),
                  borderData: FlBorderData(show: false),
                  gridData: const FlGridData(show: false),
                  barGroups: stats.monthlyEarningsData.asMap().entries.map((
                    entry,
                  ) {
                    return BarChartGroupData(
                      x: entry.key,
                      barRods: [
                        BarChartRodData(
                          toY: entry.value.revenue,
                          color: AppColors.success,
                          width: 12,
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(4),
                            topRight: Radius.circular(4),
                          ),
                        ),
                        BarChartRodData(
                          toY: entry.value.expenses,
                          color: AppColors.error,
                          width: 12,
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(4),
                            topRight: Radius.circular(4),
                          ),
                        ),
                      ],
                      barsSpace: 4,
                    );
                  }).toList(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMonthlyEarningsChartPlaceholder(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Revenue & Expenses',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.amber.shade100,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.workspace_premium, size: 14, color: Colors.amber.shade800),
                      const SizedBox(width: 4),
                      Text(
                        'Pro',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: Colors.amber.shade800,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 150,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.bar_chart, size: 48, color: Colors.grey.shade400),
                    const SizedBox(height: 8),
                    Text(
                      'Upgrade to Pro to see',
                      style: TextStyle(color: Colors.grey.shade500),
                    ),
                    Text(
                      'Revenue & Expenses chart',
                      style: TextStyle(color: Colors.grey.shade500),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLegendItem(String label, Color color) {
    return Row(
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: const TextStyle(fontSize: 12, color: AppColors.lightTextSecondary),
        ),
      ],
    );
  }

  Widget _buildProjectStatusChart(BuildContext context, DashboardStats stats) {
    if (stats.projectStatusData.isEmpty) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Project Status',
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 40),
              Center(
                child: Text(
                  'No projects yet',
                  style: TextStyle(color: AppColors.lightTextSecondary),
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      );
    }

    final colors = {
      ProjectStatus.inProgress: AppColors.statusActive,
      ProjectStatus.completed: AppColors.statusDone,
      ProjectStatus.onHold: AppColors.statusOnHold,
      ProjectStatus.cancelled: AppColors.error,
    };

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Project Status',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                SizedBox(
                  height: 150,
                  width: 150,
                  child: PieChart(
                    PieChartData(
                      sectionsSpace: 2,
                      centerSpaceRadius: 40,
                      sections: stats.projectStatusData.map((item) {
                        final color =
                            colors[item.status] ?? AppColors.lightTextSecondary;
                        return PieChartSectionData(
                          color: color,
                          value: item.count.toDouble(),
                          title: '${item.count}',
                          radius: 35,
                          titleStyle: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ),
                const SizedBox(width: 24),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: stats.projectStatusData.map((item) {
                      final color =
                          colors[item.status] ?? AppColors.lightTextSecondary;
                      final label = switch (item.status) {
                        ProjectStatus.inProgress => 'In Progress',
                        ProjectStatus.completed => 'Completed',
                        ProjectStatus.onHold => 'On Hold',
                        ProjectStatus.cancelled => 'Cancelled',
                      };
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Row(
                          children: [
                            Container(
                              width: 12,
                              height: 12,
                              decoration: BoxDecoration(
                                color: color,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(label),
                            const Spacer(),
                            Text(
                              '${item.count}',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

}

class _QuickActionsFab extends StatefulWidget {
  const _QuickActionsFab();

  @override
  State<_QuickActionsFab> createState() => _QuickActionsFabState();
}

class _QuickActionsFabState extends State<_QuickActionsFab>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  bool _isOpen = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _toggle() {
    setState(() {
      _isOpen = !_isOpen;
      if (_isOpen) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    });
  }

  void _navigateAndClose(BuildContext context, String route) {
    _toggle();
    context.push(route);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        _buildAction(
          icon: Icons.repeat_outlined,
          label: 'Recurring',
          delay: 0.15,
          onTap: () => _navigateAndClose(context, '/recurring'),
        ),
        _buildAction(
          icon: Icons.timer_outlined,
          label: 'Time Tracking',
          delay: 0.1,
          onTap: () => _navigateAndClose(context, '/time-tracking'),
        ),
        _buildAction(
          icon: Icons.receipt_long_outlined,
          label: 'Expenses',
          delay: 0.05,
          onTap: () => _navigateAndClose(context, '/expenses'),
        ),
        const SizedBox(height: 12),
        FloatingActionButton(
          onPressed: _toggle,
          shape: const CircleBorder(),
          backgroundColor: AppColors.primary500,
          child: AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              return Transform.rotate(
                angle: _controller.value * 0.75,
                child: Icon(
                  _isOpen ? Icons.close : Icons.add_rounded,
                  color: Colors.white,
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildAction({
    required IconData icon,
    required String label,
    required double delay,
    required VoidCallback onTap,
  }) {
    final animation = Tween<Offset>(
      begin: const Offset(0, 1),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Interval(delay, delay + 0.15, curve: Curves.easeOut),
      ),
    );

    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, 80 * (1 - animation.value.dy)),
          child: Opacity(
            opacity: animation.value.dy.clamp(0, 1),
            child: Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: InkWell(
                onTap: onTap,
                borderRadius: BorderRadius.circular(24),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.15),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(icon, color: AppColors.primary500, size: 20),
                      const SizedBox(width: 8),
                      Text(label, style: const TextStyle(fontSize: 13)),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              const SizedBox(height: 12),
              Text(
                value,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                title,
                style: TextStyle(
                  color: AppColors.lightTextSecondary,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}


