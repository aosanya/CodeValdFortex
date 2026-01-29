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
import '../views/unauthorized_screen.dart';
import '../views/work_items/work_items_screen.dart';
import '../views/work_items/work_item_detail_screen.dart';
import '../views/agencies/agencies_screen.dart';
import '../views/agencies/agency_detail_screen.dart';
import '../views/agency/agency_selection/agency_selection_view.dart';
import '../views/agents/agents_screen.dart';
import '../views/agents/agent_detail_screen.dart';
import '../views/settings_screen.dart';
import '../providers/auth_provider.dart';
import '../models/permission.dart';

/// Provider for GoRouter instance
final routerProvider = Provider<GoRouter>((ref) {
  final isAuthenticated = ref.watch(isAuthenticatedProvider);
  final user = ref.watch(currentUserProvider);

  return GoRouter(
    debugLogDiagnostics: true,
    initialLocation: isAuthenticated ? '/agencies' : '/sign-in',
    refreshListenable: _AuthNotifier(ref),
    redirect: (BuildContext context, GoRouterState state) {
      final location = state.matchedLocation;
      final isAuthRoute =
          location == '/sign-in' ||
          location == '/sign-up' ||
          location.startsWith('/auth');

      // Allow unauthorized page
      if (location == '/unauthorized') {
        return null;
      }

      // Redirect to sign-in if accessing protected route while not authenticated
      if (!isAuthenticated && !isAuthRoute && location != '/') {
        return '/sign-in?redirect=${Uri.encodeComponent(location)}';
      }

      // Redirect to agency selection if accessing auth routes while authenticated
      if (isAuthenticated && isAuthRoute) {
        final redirect = state.uri.queryParameters['redirect'];
        return redirect ?? '/agencies';
      }

      // Role-based route protection
      if (isAuthenticated && !_canAccessRoute(location, user)) {
        return '/unauthorized';
      }

      return null; // No redirect needed
    },
    errorBuilder: (context, state) => ErrorScreen(error: state.error),
    routes: [
      GoRoute(
        path: '/',
        redirect: (context, state) {
          final isAuth = ref.read(isAuthenticatedProvider);
          return isAuth ? '/agencies' : '/sign-in';
        },
      ),

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

      // Agencies - New MVP-FL-101 implementation
      GoRoute(
        path: '/agencies',
        name: 'agencies',
        builder: (context, state) => const AgencySelectionView(),
        routes: [
          GoRoute(
            path: 'create',
            name: 'agency-create',
            builder: (context, state) =>
                const AgenciesScreen(), // Placeholder for create form
          ),
          GoRoute(
            path: ':id/designer',
            name: 'agency-designer',
            builder: (context, state) {
              final id = state.pathParameters['id']!;
              return AgencyDetailScreen(id: id); // Placeholder for designer
            },
          ),
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

      // Unauthorized
      GoRoute(
        path: '/unauthorized',
        name: 'unauthorized',
        builder: (context, state) => const UnauthorizedScreen(),
      ),
    ],
  );
});

/// Check if user can access a specific route based on their role
bool _canAccessRoute(String location, dynamic user) {
  if (user == null) return false;

  // Default to 'user' role if not specified
  final role = UserRole.fromString(user.role ?? 'user');

  // Admin can access everything
  if (role == UserRole.admin) return true;

  // Settings and admin routes require admin role
  if (location.startsWith('/settings') || location.startsWith('/admin')) {
    return false;
  }

  // Routes containing /delete or /manage require admin or user role
  if (location.contains('/delete') || location.contains('/manage')) {
    return role == UserRole.user || role == UserRole.admin;
  }

  // Default: allow access for authenticated users (user, viewer roles)
  return role == UserRole.user || role == UserRole.viewer;
}

/// Helper class to notify GoRouter when auth state changes
class _AuthNotifier extends ChangeNotifier {
  _AuthNotifier(this.ref) {
    ref.listen(isAuthenticatedProvider, (previous, next) => notifyListeners());
  }

  final Ref ref;
}
