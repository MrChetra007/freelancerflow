import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../features/auth/presentation/splash_screen.dart';
import '../../features/auth/presentation/login_screen.dart';
import '../../features/dashboard/presentation/dashboard_screen.dart';
import '../../features/clients/presentation/clients_screen.dart';
import '../../features/clients/presentation/add_client_screen.dart';
import '../../features/projects/presentation/projects_screen.dart';
import '../../features/projects/presentation/add_project_screen.dart';
import '../../features/payments/presentation/payments_screen.dart';
import '../../features/payments/presentation/add_payment_screen.dart';
import '../../features/invoices/presentation/invoices_screen.dart';
import '../../features/invoices/presentation/create_invoice_screen.dart';
import '../../features/invoices/presentation/invoice_detail_screen.dart';
import '../../features/settings/presentation/settings_screen.dart';
import '../supabase/supabase_client.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();
final _shellNavigatorKey = GlobalKey<NavigatorState>();

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/splash',
    redirect: (context, state) {
      final isLoggedIn = SupabaseConfig.client.auth.currentSession != null;
      final isOnSplash = state.matchedLocation == '/splash';
      final isOnLogin = state.matchedLocation == '/login';

      if (!isLoggedIn && !isOnLogin && !isOnSplash) {
        return '/login';
      }

      if (isLoggedIn && (isOnLogin || isOnSplash)) {
        return '/dashboard';
      }

      return null;
    },
    routes: [
      GoRoute(
        path: '/splash',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
      ShellRoute(
        navigatorKey: _shellNavigatorKey,
        builder: (context, state, child) => MainShell(child: child),
        routes: [
          GoRoute(
            path: '/dashboard',
            pageBuilder: (context, state) =>
                const NoTransitionPage(child: DashboardScreen()),
          ),
          GoRoute(
            path: '/clients',
            pageBuilder: (context, state) =>
                const NoTransitionPage(child: ClientsScreen()),
          ),
          GoRoute(
            path: '/projects',
            pageBuilder: (context, state) =>
                const NoTransitionPage(child: ProjectsScreen()),
          ),
          GoRoute(
            path: '/payments',
            pageBuilder: (context, state) =>
                const NoTransitionPage(child: PaymentsScreen()),
          ),
          GoRoute(
            path: '/invoices',
            pageBuilder: (context, state) =>
                const NoTransitionPage(child: InvoicesScreen()),
          ),
        ],
      ),
      GoRoute(
        path: '/clients/add',
        builder: (context, state) => const AddClientScreen(),
      ),
      GoRoute(
        path: '/clients/:id',
        builder: (context, state) {
          final id = state.pathParameters['id']!;
          return AddClientScreen(clientId: id);
        },
      ),
      GoRoute(
        path: '/projects/add',
        builder: (context, state) => const AddProjectScreen(),
      ),
      GoRoute(
        path: '/projects/:id',
        builder: (context, state) {
          final id = state.pathParameters['id']!;
          return AddProjectScreen(projectId: id);
        },
      ),
      GoRoute(
        path: '/payments/add',
        builder: (context, state) {
          final paymentId = state.extra as String?;
          return AddPaymentScreen(paymentId: paymentId);
        },
      ),
      GoRoute(
        path: '/invoices/create',
        builder: (context, state) => const CreateInvoiceScreen(),
      ),
      GoRoute(
        path: '/invoices/:id',
        builder: (context, state) {
          final id = state.pathParameters['id']!;
          return InvoiceDetailScreen(invoiceId: id);
        },
      ),
      GoRoute(
        path: '/settings',
        builder: (context, state) => const SettingsScreen(),
      ),
    ],
  );
});

class MainShell extends StatefulWidget {
  final Widget child;

  const MainShell({super.key, required this.child});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _currentIndex = 0;

  static const _destinations = [
    '/dashboard',
    '/clients',
    '/projects',
    '/payments',
    '/invoices',
  ];

  void _onDestinationSelected(int index) {
    if (_currentIndex != index) {
      setState(() => _currentIndex = index);
      context.go(_destinations[index]);
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final location = GoRouterState.of(context).matchedLocation;
    final index = _destinations.indexOf(location);
    if (index != -1 && index != _currentIndex) {
      setState(() => _currentIndex = index);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: widget.child,
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: _onDestinationSelected,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.dashboard_outlined),
            selectedIcon: Icon(Icons.dashboard_rounded),
            label: 'Dashboard',
          ),
          NavigationDestination(
            icon: Icon(Icons.people_outline),
            selectedIcon: Icon(Icons.people_rounded),
            label: 'Clients',
          ),
          NavigationDestination(
            icon: Icon(Icons.folder_outlined),
            selectedIcon: Icon(Icons.folder_rounded),
            label: 'Projects',
          ),
          NavigationDestination(
            icon: Icon(Icons.payments_outlined),
            selectedIcon: Icon(Icons.payments_rounded),
            label: 'Payments',
          ),
          NavigationDestination(
            icon: Icon(Icons.receipt_long_outlined),
            selectedIcon: Icon(Icons.receipt_long_rounded),
            label: 'Invoices',
          ),
        ],
      ),
    );
  }
}
