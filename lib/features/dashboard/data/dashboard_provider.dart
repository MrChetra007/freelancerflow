import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../clients/data/clients_provider.dart';
import '../../projects/data/projects_provider.dart';
import '../../projects/domain/project.dart';
import '../../payments/data/payments_provider.dart';
import '../../payments/domain/payment.dart';
import '../../invoices/data/invoices_provider.dart';
import '../../invoices/domain/invoice.dart';

final dashboardStatsProvider = FutureProvider<DashboardStats>((ref) async {
  final clients = await ref.watch(clientsProvider.future);
  final projects = await ref.watch(projectsProvider.future);
  final payments = await ref.watch(paymentsProvider.future);
  final invoices = await ref.watch(invoicesProvider.future);

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

  final monthlyEarningsData = _getMonthlyEarnings(payments, now);
  final projectStatusData = _getProjectStatusData(projects);

  return DashboardStats(
    totalClients: clients.length,
    activeProjects: activeProjects,
    overdueProjects: overdueProjects,
    monthlyEarnings: monthlyEarnings,
    totalEarnings: totalEarnings,
    pendingInvoices: pendingInvoices,
    monthlyEarningsData: monthlyEarningsData,
    projectStatusData: projectStatusData,
  );
});

List<MonthlyEarning> _getMonthlyEarnings(List<Payment> payments, DateTime now) {
  final result = <MonthlyEarning>[];
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
    result.add(MonthlyEarning(month: month, amount: earnings));
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
  final double totalEarnings;
  final double pendingInvoices;
  final List<MonthlyEarning> monthlyEarningsData;
  final List<ProjectStatusCount> projectStatusData;

  DashboardStats({
    required this.totalClients,
    required this.activeProjects,
    required this.overdueProjects,
    required this.monthlyEarnings,
    required this.totalEarnings,
    required this.pendingInvoices,
    required this.monthlyEarningsData,
    required this.projectStatusData,
  });
}

class MonthlyEarning {
  final DateTime month;
  final double amount;

  MonthlyEarning({required this.month, required this.amount});
}

class ProjectStatusCount {
  final ProjectStatus status;
  final int count;

  ProjectStatusCount({required this.status, required this.count});
}
