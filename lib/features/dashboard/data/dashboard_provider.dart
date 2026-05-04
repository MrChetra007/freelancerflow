import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../clients/data/clients_provider.dart';
import '../../projects/data/projects_provider.dart';
import '../../projects/domain/project.dart';
import '../../payments/data/payments_provider.dart';
import '../../payments/domain/payment.dart';
import '../../invoices/data/invoices_provider.dart';
import '../../invoices/domain/invoice.dart';
import '../../expenses/data/expense_provider.dart';
import '../../expenses/domain/expense.dart';
import '../../time_tracking/data/time_entry_provider.dart' as time;
import '../../time_tracking/domain/time_entry.dart';

final dashboardStatsProvider = FutureProvider<DashboardStats>((ref) async {
  final clients = await ref.watch(clientsProvider.future);
  final projects = await ref.watch(projectsProvider.future);
  final payments = await ref.watch(paymentsProvider.future);
  final invoices = await ref.watch(invoicesProvider.future);
  final expenses = await ref.watch(expensesProvider().future);
  final activeTimer = await ref.watch(time.activeTimerProvider.future);

  final now = DateTime.now();
  final thisMonth = now.month;
  final thisYear = now.year;

  final monthlyEarnings = payments
      .where(
        (p) =>
            p.status == PaymentStatus.paid &&
            p.paidDate != null &&
            p.paidDate!.month == thisMonth &&
            p.paidDate!.year == thisYear,
      )
      .fold(0.0, (sum, p) => sum + p.amountPaid);

  final expensesThisMonth = expenses
      .where(
        (e) =>
            e.date.month == thisMonth &&
            e.date.year == thisYear,
      )
      .fold(0.0, (sum, e) => sum + e.amount);

  final totalEarnings = payments
      .where((p) => p.status == PaymentStatus.paid)
      .fold(0.0, (sum, p) => sum + p.amountPaid);

  final activeProjects = projects
      .where((p) => p.status == ProjectStatus.inProgress)
      .length;

  final overdueProjects = projects
      .where(
        (p) =>
            p.status == ProjectStatus.inProgress &&
            p.deadline != null &&
            p.deadline!.isBefore(now),
      )
      .length;

  final pendingInvoices = invoices
      .where(
        (i) =>
            i.status == InvoiceStatus.sent || i.status == InvoiceStatus.overdue,
      )
      .fold(0.0, (sum, i) => sum + i.total);

  final unbilledTimeEntries = await ref.watch(
    time.allUnbilledTimeEntriesProvider.future,
  ).catchError((_) => <TimeEntry>[]);

  final unbilledTimeValue = unbilledTimeEntries.fold<double>(
    0,
    (sum, e) => sum + (e.duration.inSeconds / 3600) * e.hourlyRate,
  );

  final monthlyEarningsData = _getMonthlyEarnings(
    payments: payments,
    expenses: expenses,
    now: now,
  );
  final projectStatusData = _getProjectStatusData(projects);

  return DashboardStats(
    totalClients: clients.length,
    activeProjects: activeProjects,
    overdueProjects: overdueProjects,
    monthlyEarnings: monthlyEarnings,
    expensesThisMonth: expensesThisMonth,
    profitThisMonth: monthlyEarnings - expensesThisMonth,
    totalEarnings: totalEarnings,
    pendingInvoices: pendingInvoices,
    unbilledTimeValue: unbilledTimeValue,
    hasActiveTimer: activeTimer != null,
    monthlyEarningsData: monthlyEarningsData,
    projectStatusData: projectStatusData,
  );
});

List<MonthlyEarningData> _getMonthlyEarnings({
  required List<Payment> payments,
  required List<Expense> expenses,
  required DateTime now,
}) {
  final result = <MonthlyEarningData>[];
  for (int i = 5; i >= 0; i--) {
    final month = DateTime(now.year, now.month - i);
    final earnings = payments
        .where(
          (p) =>
              p.status == PaymentStatus.paid &&
              p.paidDate != null &&
              p.paidDate!.year == month.year &&
              p.paidDate!.month == month.month,
        )
        .fold(0.0, (sum, p) => sum + p.amountPaid);
    final monthExpenses = expenses
        .where(
          (e) =>
              e.date.year == month.year &&
              e.date.month == month.month,
        )
        .fold(0.0, (sum, e) => sum + e.amount);
    result.add(
      MonthlyEarningData(
        month: month,
        revenue: earnings,
        expenses: monthExpenses,
      ),
    );
  }
  return result;
}

List<ProjectStatusCount> _getProjectStatusData(List<Project> projects) {
  final counts = <ProjectStatus, int>{};
  for (final project in projects) {
    counts[project.status] = (counts[project.status] ?? 0) + 1;
  }
  return counts.entries
      .map((e) => ProjectStatusCount(status: e.key, count: e.value))
      .toList();
}

class DashboardStats {
  final int totalClients;
  final int activeProjects;
  final int overdueProjects;
  final double monthlyEarnings;
  final double expensesThisMonth;
  final double profitThisMonth;
  final double totalEarnings;
  final double pendingInvoices;
  final double unbilledTimeValue;
  final bool hasActiveTimer;
  final List<MonthlyEarningData> monthlyEarningsData;
  final List<ProjectStatusCount> projectStatusData;

  DashboardStats({
    required this.totalClients,
    required this.activeProjects,
    required this.overdueProjects,
    required this.monthlyEarnings,
    required this.expensesThisMonth,
    required this.profitThisMonth,
    required this.totalEarnings,
    required this.pendingInvoices,
    required this.unbilledTimeValue,
    required this.hasActiveTimer,
    required this.monthlyEarningsData,
    required this.projectStatusData,
  });
}

class MonthlyEarningData {
  final DateTime month;
  final double revenue;
  final double expenses;

  MonthlyEarningData({
    required this.month,
    required this.revenue,
    required this.expenses,
  });
}

class ProjectStatusCount {
  final ProjectStatus status;
  final int count;

  ProjectStatusCount({required this.status, required this.count});
}
