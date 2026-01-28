# MVP-FL-011: Protected Routes & Permissions

## Overview
**Priority**: P0  
**Effort**: Medium  
**Skills**: go_router, Authorization, Riverpod  
**Dependencies**: MVP-FL-010 (Login & Registration Screens) ✅

Implement comprehensive route protection with role-based access control using go_router. Add route guards to protect authenticated-only routes, implement permission checking based on user roles, handle unauthorized access, and manage session expiry gracefully.

## Requirements

### Functional Requirements

1. **Route Guards**
   - Protect routes that require authentication
   - Redirect unauthenticated users to sign-in page
   - Preserve intended destination for post-login redirect
   - Allow public routes (sign-in, sign-up) without authentication

2. **Role-Based Access Control**
   - Define user roles (admin, user, viewer, etc.)
   - Restrict routes based on user role
   - Show appropriate UI based on permissions
   - Handle permission denied scenarios

3. **Permission System**
   - Define granular permissions (read, write, delete, manage)
   - Check permissions before allowing actions
   - Permission-based UI rendering (hide/disable features)
   - Permission provider for easy access

4. **Unauthorized Handling**
   - Redirect to appropriate page on unauthorized access
   - Display clear error messages
   - Log unauthorized access attempts
   - Provide navigation back to allowed routes

5. **Session Management**
   - Handle session expiry gracefully
   - Auto-redirect to sign-in when session expires
   - Preserve user location for post-login redirect
   - Clear sensitive data on session expiry

## Technical Design

### Permission Model

```dart
enum Permission {
  // Agency permissions
  viewAgencies,
  createAgency,
  editAgency,
  deleteAgency,
  
  // Agent permissions
  viewAgents,
  createAgent,
  editAgent,
  deleteAgent,
  
  // Work item permissions
  viewWorkItems,
  createWorkItem,
  editWorkItem,
  deleteWorkItem,
  
  // Admin permissions
  manageUsers,
  manageRoles,
  viewSystemSettings,
  editSystemSettings,
}

enum UserRole {
  admin,      // Full access
  user,       // Standard user access
  viewer,     // Read-only access
  guest,      // Limited public access
}
```

### Route Protection Strategy

```dart
// In router.dart
redirect: (BuildContext context, GoRouterState state) {
  final isAuthenticated = ref.read(isAuthenticatedProvider);
  final user = ref.read(currentUserProvider);
  final isAuthRoute = _isAuthRoute(state.matchedLocation);
  
  // 1. Unauthenticated trying to access protected route
  if (!isAuthenticated && !isAuthRoute) {
    return '/sign-in?redirect=${Uri.encodeComponent(state.matchedLocation)}';
  }
  
  // 2. Authenticated trying to access auth route
  if (isAuthenticated && isAuthRoute) {
    return '/home';
  }
  
  // 3. Check role-based permissions
  if (isAuthenticated && !_hasRoutePermission(state.matchedLocation, user)) {
    return '/unauthorized';
  }
  
  return null; // Allow navigation
}
```

### File Structure

```
lib/
  models/
    permission.dart
    user_role.dart
  providers/
    permission_provider.dart
  utils/
    permission_checker.dart
  views/
    unauthorized_screen.dart
  widgets/
    permission_widget.dart
```

## Implementation

### 1. Permission Models

Create `lib/models/permission.dart`:
```dart
enum Permission {
  viewAgencies,
  createAgency,
  editAgency,
  deleteAgency,
  viewAgents,
  createAgent,
  editAgent,
  deleteAgent,
  viewWorkItems,
  createWorkItem,
  editWorkItem,
  deleteWorkItem,
  manageUsers,
  manageRoles,
  viewSystemSettings,
  editSystemSettings,
}

enum UserRole {
  admin,
  user,
  viewer,
  guest;
  
  List<Permission> get permissions {
    switch (this) {
      case UserRole.admin:
        return Permission.values; // All permissions
      case UserRole.user:
        return [
          Permission.viewAgencies,
          Permission.createAgency,
          Permission.editAgency,
          Permission.viewAgents,
          Permission.createAgent,
          Permission.editAgent,
          Permission.viewWorkItems,
          Permission.createWorkItem,
          Permission.editWorkItem,
        ];
      case UserRole.viewer:
        return [
          Permission.viewAgencies,
          Permission.viewAgents,
          Permission.viewWorkItems,
        ];
      case UserRole.guest:
        return [];
    }
  }
}
```

### 2. Permission Provider

Create `lib/providers/permission_provider.dart`:
```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/permission.dart';
import 'auth_provider.dart';

final permissionProvider = Provider<PermissionChecker>((ref) {
  final user = ref.watch(currentUserProvider);
  return PermissionChecker(user);
});

class PermissionChecker {
  final AuthUser? user;
  
  PermissionChecker(this.user);
  
  bool hasPermission(Permission permission) {
    if (user == null) return false;
    final role = _getUserRole(user!.role);
    return role.permissions.contains(permission);
  }
  
  bool hasAnyPermission(List<Permission> permissions) {
    return permissions.any((p) => hasPermission(p));
  }
  
  bool hasAllPermissions(List<Permission> permissions) {
    return permissions.every((p) => hasPermission(p));
  }
  
  UserRole _getUserRole(String? roleString) {
    if (roleString == null) return UserRole.guest;
    return UserRole.values.firstWhere(
      (r) => r.name == roleString.toLowerCase(),
      orElse: () => UserRole.guest,
    );
  }
}
```

### 3. Enhanced Router with Route Guards

Update `lib/config/router.dart`:
```dart
final routerProvider = Provider<GoRouter>((ref) {
  final isAuthenticated = ref.watch(isAuthenticatedProvider);
  final user = ref.watch(currentUserProvider);

  return GoRouter(
    debugLogDiagnostics: true,
    initialLocation: isAuthenticated ? '/home' : '/sign-in',
    refreshListenable: _AuthNotifier(ref),
    redirect: (BuildContext context, GoRouterState state) {
      final location = state.matchedLocation;
      final isAuthRoute = location == '/sign-in' || 
                         location == '/sign-up' || 
                         location.startsWith('/auth');

      // Unauthenticated user trying to access protected route
      if (!isAuthenticated && !isAuthRoute && location != '/') {
        return '/sign-in?redirect=${Uri.encodeComponent(location)}';
      }

      // Authenticated user trying to access auth routes
      if (isAuthenticated && isAuthRoute) {
        final redirect = state.uri.queryParameters['redirect'];
        return redirect ?? '/home';
      }

      // Role-based route protection
      if (isAuthenticated && !_canAccessRoute(location, user)) {
        return '/unauthorized';
      }

      return null;
    },
    errorBuilder: (context, state) => ErrorScreen(error: state.error),
    routes: [
      // ... existing routes ...
      
      GoRoute(
        path: '/unauthorized',
        name: 'unauthorized',
        builder: (context, state) => const UnauthorizedScreen(),
      ),
    ],
  );
});

bool _canAccessRoute(String location, AuthUser? user) {
  if (user == null) return false;
  
  final role = _getUserRole(user.role);
  
  // Admin can access everything
  if (role == UserRole.admin) return true;
  
  // Define route restrictions
  if (location.startsWith('/settings') || location.startsWith('/admin')) {
    return role == UserRole.admin;
  }
  
  if (location.contains('/delete') || location.contains('/manage')) {
    return role == UserRole.admin || role == UserRole.user;
  }
  
  // Default: allow access for authenticated users
  return true;
}
```

### 4. Permission Widget

Create `lib/widgets/permission_widget.dart`:
```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/permission.dart';
import '../providers/permission_provider.dart';

class PermissionWidget extends ConsumerWidget {
  final Permission permission;
  final Widget child;
  final Widget? fallback;

  const PermissionWidget({
    super.key,
    required this.permission,
    required this.child,
    this.fallback,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final permissionChecker = ref.watch(permissionProvider);
    
    if (permissionChecker.hasPermission(permission)) {
      return child;
    }
    
    return fallback ?? const SizedBox.shrink();
  }
}

class MultiPermissionWidget extends ConsumerWidget {
  final List<Permission> permissions;
  final bool requireAll;
  final Widget child;
  final Widget? fallback;

  const MultiPermissionWidget({
    super.key,
    required this.permissions,
    this.requireAll = false,
    required this.child,
    this.fallback,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final permissionChecker = ref.watch(permissionProvider);
    
    final hasPermission = requireAll
        ? permissionChecker.hasAllPermissions(permissions)
        : permissionChecker.hasAnyPermission(permissions);
    
    if (hasPermission) {
      return child;
    }
    
    return fallback ?? const SizedBox.shrink();
  }
}
```

### 5. Unauthorized Screen

Create `lib/views/unauthorized_screen.dart`:
```dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class UnauthorizedScreen extends StatelessWidget {
  const UnauthorizedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Access Denied'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.lock_outline,
                size: 80,
                color: Theme.of(context).colorScheme.error,
              ),
              const SizedBox(height: 24),
              Text(
                'Access Denied',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 16),
              Text(
                'You don\'t have permission to access this page.',
                style: Theme.of(context).textTheme.bodyLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              ElevatedButton.icon(
                onPressed: () => context.go('/home'),
                icon: const Icon(Icons.home),
                label: const Text('Go to Home'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
```

## Usage Examples

### 1. Protecting Routes

Routes are automatically protected via the global redirect function in the router.

### 2. Conditional UI Rendering

```dart
// Show button only if user has permission
PermissionWidget(
  permission: Permission.createAgency,
  child: ElevatedButton(
    onPressed: () => context.push('/agencies/create'),
    child: const Text('Create Agency'),
  ),
)

// Show different UI based on multiple permissions
MultiPermissionWidget(
  permissions: [Permission.editAgency, Permission.deleteAgency],
  requireAll: false, // User needs at least one
  child: Row(
    children: [
      IconButton(icon: Icon(Icons.edit), onPressed: _edit),
      IconButton(icon: Icon(Icons.delete), onPressed: _delete),
    ],
  ),
  fallback: const Text('Read-only access'),
)
```

### 3. Programmatic Permission Check

```dart
final permissionChecker = ref.read(permissionProvider);

if (permissionChecker.hasPermission(Permission.deleteAgency)) {
  await deleteAgency(id);
} else {
  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(content: Text('Permission denied')),
  );
}
```

## Acceptance Criteria

1. ✅ Protected routes redirect unauthenticated users to sign-in
2. ✅ Post-login redirect returns user to intended destination
3. ✅ Role-based route access works correctly
4. ✅ Permission checks prevent unauthorized actions
5. ✅ Unauthorized screen displays for permission violations
6. ✅ Session expiry redirects to sign-in
7. ✅ Permission widgets hide/show UI based on user permissions
8. ✅ Admin role has full access
9. ✅ Viewer role has read-only access
10. ✅ Guest role has no access to protected routes

## Testing Requirements

1. **Route Protection Tests**
   - Unauthenticated user cannot access protected routes
   - Authenticated user can access allowed routes
   - Redirect preserves query parameters

2. **Permission Tests**
   - Each role has correct permissions
   - Permission checks work correctly
   - Permission widgets render correctly

3. **Integration Tests**
   - Full authentication flow with route protection
   - Role change updates permissions
   - Session expiry handling

## Security Considerations

- ✅ All protected routes require authentication
- ✅ Backend must also enforce permissions (frontend is not security boundary)
- ✅ Sensitive routes require appropriate role
- ✅ Permission checks on both navigation and actions
- ⚠️ User role comes from backend (trusted source)
- ⚠️ Permission changes require token refresh

## Implementation Checklist

- [ ] Create permission.dart with Permission and UserRole enums
- [ ] Create permission_provider.dart with PermissionChecker
- [ ] Update router.dart with route guards and role checks
- [ ] Create unauthorized_screen.dart
- [ ] Create permission_widget.dart for conditional rendering
- [ ] Update AuthUser model if role field needs adjustment
- [ ] Test route protection with different roles
- [ ] Test permission widgets
- [ ] Document permission system
- [ ] Commit changes

## Notes

- Current router already has basic auth redirect, this enhances it with roles
- Permission system is extensible for future requirements
- Backend API must return user role in auth response
- Consider caching permission checks for performance

## Status

📋 Not Started
