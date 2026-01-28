import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../views/home_screen.dart';
import '../views/dashboard_screen.dart';
import '../views/error_screen.dart';
import '../views/auth/login_screen.dart';
import '../views/auth/register_screen.dart';
import '../views/auth/sign_in/sign_in_view.dart';
import '../views/auth/sign_up/sign_up_view.dart';
import '../views/work_items/work_items_screen.dart';
import '../views/work_items/work_item_detail_screen.dart';
import '../views/agencies/agencies_screen.dart';
import '../views/agencies/agency_detail_screen.dart';
import '../views/agents/agents_screen.dart';
import '../views/agents/agent_detail_screen.dart';
import '../views/settings_screen.dart';
import '../providers/auth_provider.dart';

/// Provider for GoRouter instance
final routerProvider = Provider<GoRouter>((ref) {
  final isAuthenticated = ref.watch(isAuthenticatedProvider);

  return GoRouter(
    debugLogDiagnostics: true,
    initialLocation: isAuthenticated ? '/home' : '/sign-in',
    refreshListenable: _AuthNotifier(ref),
    redirect: (BuildContext context, GoRouterState state) {
      final isAuthRoute =
          state.matchedLocation == '/sign-in' ||
          state.matchedLocation == '/sign-up' ||
          state.matchedLocation.startsWith('/auth');

      // Redirect to sign-in if accessing protected route while not authenticated
      if (!isAuthenticated && !isAuthRoute && state.matchedLocation != '/') {
        return '/sign-in?redirect=${Uri.encodeComponent(state.matchedLocation)}';
      }

      // Redirect to home if accessing auth routes while authenticated
      if (isAuthenticated && isAuthRoute) {
        return '/home';
      }

      return null; // No redirect needed
    },
    errorBuilder: (context, state) => ErrorScreen(error: state.error),
    routes: [
      GoRoute(path: '/', redirect: (context, state) => '/home'),

      // Home
      GoRoute(
        path: '/home',
        name: 'home',
        builder: (context, state) => const HomeScreen(),
      ),

      // New Authentication Routes (MVP-FL-010)
      GoRoute(
        path: '/sign-in',
        name: 'sign-in',
        builder: (context, state) => const SignInView(),
      ),
      GoRoute(
        path: '/sign-up',
        name: 'sign-up',
        builder: (context, state) => const SignUpView(),
      ),

      // Legacy Authentication Routes (can be deprecated later)
      GoRoute(
        path: '/auth/login',
        name: 'login',
        builder: (context, state) {
          final redirect = state.uri.queryParameters['redirect'];
          return LoginScreen(redirectTo: redirect);
        },
      ),
      GoRoute(
        path: '/auth/register',
        name: 'register',
        builder: (context, state) => const RegisterScreen(),
      ),

      // Dashboard
      GoRoute(
        path: '/dashboard',
        name: 'dashboard',
        builder: (context, state) => const DashboardScreen(),
      ),

      // Work Items
      GoRoute(
        path: '/work-items',
        name: 'work-items',
        builder: (context, state) => const WorkItemsScreen(),
        routes: [
          GoRoute(
            path: 'create',
            name: 'work-item-create',
            builder: (context, state) => const WorkItemDetailScreen(),
          ),
          GoRoute(
            path: ':id',
            name: 'work-item-detail',
            builder: (context, state) {
              final id = state.pathParameters['id']!;
              return WorkItemDetailScreen(id: id);
            },
          ),
        ],
      ),

      // Agencies
      GoRoute(
        path: '/agencies',
        name: 'agencies',
        builder: (context, state) => const AgenciesScreen(),
        routes: [
          GoRoute(
            path: ':id',
            name: 'agency-detail',
            builder: (context, state) {
              final id = state.pathParameters['id']!;
              return AgencyDetailScreen(id: id);
            },
          ),
        ],
      ),

      // Agents
      GoRoute(
        path: '/agents',
        name: 'agents',
        builder: (context, state) => const AgentsScreen(),
        routes: [
          GoRoute(
            path: ':id',
            name: 'agent-detail',
            builder: (context, state) {
              final id = state.pathParameters['id']!;
              return AgentDetailScreen(id: id);
            },
          ),
        ],
      ),

      // Settings
      GoRoute(
        path: '/settings',
        name: 'settings',
        builder: (context, state) => const SettingsScreen(),
      ),
    ],
  );
});

/// Helper class to notify GoRouter when auth state changes
class _AuthNotifier extends ChangeNotifier {
  _AuthNotifier(this.ref) {
    ref.listen(isAuthenticatedProvider, (previous, next) => notifyListeners());
  }

  final Ref ref;
}
