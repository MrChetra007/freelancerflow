import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
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
import '../../features/settings/presentation/premium_screen.dart';
import '../../features/settings/presentation/profile_screen.dart';
import '../supabase/supabase_client.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();
final _shellNavigatorKey = GlobalKey<NavigatorState>();

class SupabaseAuthNotifier extends ChangeNotifier {
  SupabaseAuthNotifier() {
    _subscription = SupabaseConfig.client.auth.onAuthStateChange.listen((_) {
      notifyListeners();
    });
  }

  late final StreamSubscription<AuthState> _subscription;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}

final _authNotifierProvider = Provider<SupabaseAuthNotifier>((ref) {
  final notifier = SupabaseAuthNotifier();
  ref.onDispose(() => notifier.dispose());
  return notifier;
});

GoRouter createRouter(SupabaseAuthNotifier authNotifier) {
  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/splash',
    refreshListenable: authNotifier,
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
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: const SplashScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(opacity: animation, child: child);
          },
        ),
      ),
      GoRoute(
        path: '/login',
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: const LoginScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(opacity: animation, child: child);
          },
        ),
      ),
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
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: const AddClientScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return SlideTransition(
              position:
                  Tween<Offset>(
                    begin: const Offset(0, 1),
                    end: Offset.zero,
                  ).animate(
                    CurveTween(curve: Curves.easeOutCubic).animate(animation),
                  ),
              child: child,
            );
          },
        ),
      ),
      GoRoute(
        path: '/clients/:id',
        pageBuilder: (context, state) {
          final id = state.pathParameters['id']!;
          return CustomTransitionPage(
            key: state.pageKey,
            child: AddClientScreen(clientId: id),
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) {
                  return SlideTransition(
                    position:
                        Tween<Offset>(
                          begin: const Offset(1, 0),
                          end: Offset.zero,
                        ).animate(
                          CurveTween(
                            curve: Curves.easeOutCubic,
                          ).animate(animation),
                        ),
                    child: child,
                  );
                },
          );
        },
      ),
      GoRoute(
        path: '/projects/add',
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: const AddProjectScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return SlideTransition(
              position:
                  Tween<Offset>(
                    begin: const Offset(0, 1),
                    end: Offset.zero,
                  ).animate(
                    CurveTween(curve: Curves.easeOutCubic).animate(animation),
                  ),
              child: child,
            );
          },
        ),
      ),
      GoRoute(
        path: '/projects/:id',
        pageBuilder: (context, state) {
          final id = state.pathParameters['id']!;
          return CustomTransitionPage(
            key: state.pageKey,
            child: AddProjectScreen(projectId: id),
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) {
                  return SlideTransition(
                    position:
                        Tween<Offset>(
                          begin: const Offset(1, 0),
                          end: Offset.zero,
                        ).animate(
                          CurveTween(
                            curve: Curves.easeOutCubic,
                          ).animate(animation),
                        ),
                    child: child,
                  );
                },
          );
        },
      ),
      GoRoute(
        path: '/payments/add',
        pageBuilder: (context, state) {
          final paymentId = state.extra as String?;
          return CustomTransitionPage(
            key: state.pageKey,
            child: AddPaymentScreen(paymentId: paymentId),
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) {
                  return SlideTransition(
                    position:
                        Tween<Offset>(
                          begin: const Offset(0, 1),
                          end: Offset.zero,
                        ).animate(
                          CurveTween(
                            curve: Curves.easeOutCubic,
                          ).animate(animation),
                        ),
                    child: child,
                  );
                },
          );
        },
      ),
      GoRoute(
        path: '/invoices/create',
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: const CreateInvoiceScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return SlideTransition(
              position:
                  Tween<Offset>(
                    begin: const Offset(0, 1),
                    end: Offset.zero,
                  ).animate(
                    CurveTween(curve: Curves.easeOutCubic).animate(animation),
                  ),
              child: child,
            );
          },
        ),
      ),
      GoRoute(
        path: '/invoices/:id',
        pageBuilder: (context, state) {
          final id = state.pathParameters['id']!;
          return CustomTransitionPage(
            key: state.pageKey,
            child: InvoiceDetailScreen(invoiceId: id),
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) {
                  return SlideTransition(
                    position:
                        Tween<Offset>(
                          begin: const Offset(1, 0),
                          end: Offset.zero,
                        ).animate(
                          CurveTween(
                            curve: Curves.easeOutCubic,
                          ).animate(animation),
                        ),
                    child: child,
                  );
                },
          );
        },
      ),
      GoRoute(
        path: '/settings',
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: const SettingsScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return SlideTransition(
              position:
                  Tween<Offset>(
                    begin: const Offset(1, 0),
                    end: Offset.zero,
                  ).animate(
                    CurveTween(curve: Curves.easeOutCubic).animate(animation),
                  ),
              child: child,
            );
          },
        ),
      ),
      GoRoute(
        path: '/profile',
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: const ProfileScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return SlideTransition(
              position:
                  Tween<Offset>(
                    begin: const Offset(1, 0),
                    end: Offset.zero,
                  ).animate(
                    CurveTween(curve: Curves.easeOutCubic).animate(animation),
                  ),
              child: child,
            );
          },
        ),
      ),
      GoRoute(
        path: '/premium',
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: const PremiumScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return SlideTransition(
              position:
                  Tween<Offset>(
                    begin: const Offset(0, 1),
                    end: Offset.zero,
                  ).animate(
                    CurveTween(curve: Curves.easeOutCubic).animate(animation),
                  ),
              child: child,
            );
          },
        ),
      ),
    ],
  );
}

final routerProvider = Provider<GoRouter>((ref) {
  final authNotifier = ref.watch(_authNotifierProvider);
  final router = createRouter(authNotifier);
  ref.onDispose(() => router.dispose());
  return router;
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
