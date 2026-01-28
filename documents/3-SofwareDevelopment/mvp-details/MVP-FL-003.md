# MVP-FL-003: Routing & Navigation

## Overview
**Priority**: P0 (Critical)  
**Effort**: Medium  
**Skills Required**: Flutter, go_router, Dart, UI/UX  
**Dependencies**: ~~MVP-FL-002~~ ✅  
**Status**: Not Started

Implement comprehensive routing and navigation system using go_router package with route structure, navigation widgets (AppBar, Drawer, breadcrumbs), route guards for authentication, and error page handling.

## Objectives

1. Configure go_router with declarative route definitions
2. Define route structure for all main screens and sub-routes
3. Create navigation widgets (AppBar with breadcrumbs, Drawer with menu)
4. Implement route guards for authentication and authorization
5. Create custom error/404 page
6. Setup deep linking support for web platform

## Requirements

### Functional Requirements

1. **Route Configuration**
   - Declarative route tree with go_router
   - Named routes for all screens
   - Route parameters and query parameters support
   - Nested routes for complex layouts
   - Redirect logic for authentication flows

2. **Navigation Widgets**
   - App-wide AppBar with breadcrumb navigation
   - Responsive Drawer/NavigationRail for sidebar menu
   - Active route highlighting
   - Multi-level menu support
   - Quick navigation shortcuts

3. **Route Guards**
   - Authentication check on protected routes
   - Role-based access control
   - Redirect to login for unauthenticated users
   - Remember intended destination after login

4. **Error Handling**
   - Custom 404/Not Found page
   - Error page for invalid routes
   - Graceful degradation for navigation errors

### Technical Requirements

1. **go_router Setup**
   - Install go_router package
   - Configure GoRouter instance in `lib/config/router.dart`
   - Define route tree with all application routes
   - Setup route observers for analytics

2. **Route Structure** (Initial Routes)
   ```
   / (root)
   ├── /auth
   │   ├── /auth/login
   │   └── /auth/register
   ├── /dashboard (protected)
   ├── /work-items (protected)
   │   ├── /work-items/:id
   │   └── /work-items/create
   ├── /agencies (protected)
   │   └── /agencies/:id
   ├── /agents (protected)
   │   └── /agents/:id
   └── /settings (protected)
   ```

3. **Navigation Components**
   - AppBar widget in `lib/widgets/navigation/app_navigation_bar.dart`
   - Drawer widget in `lib/widgets/navigation/app_drawer.dart`
   - NavigationRail for desktop in `lib/widgets/navigation/app_navigation_rail.dart`
   - Breadcrumb widget in `lib/widgets/navigation/breadcrumb.dart`

4. **Performance**
   - Lazy loading of route screens
   - Efficient navigation state management
   - Minimal rebuild on route changes

## Technical Specifications

### Architecture

**File Structure:**
```
lib/
├── config/
│   └── router.dart              # GoRouter configuration
├── screens/
│   ├── home_screen.dart         # Root/landing page
│   ├── dashboard_screen.dart    # Main dashboard (from MVP-FL-008A)
│   ├── error_screen.dart        # 404/Error page
│   └── auth/
│       ├── login_screen.dart    # Placeholder for MVP-FL-010
│       └── register_screen.dart
├── widgets/
│   └── navigation/
│       ├── app_navigation_bar.dart    # Top AppBar with breadcrumbs
│       ├── app_drawer.dart            # Mobile drawer menu
│       ├── app_navigation_rail.dart   # Desktop sidebar
│       └── breadcrumb.dart            # Breadcrumb trail widget
└── utils/
    └── route_utils.dart         # Route helper functions
```

### Implementation Details

#### 1. GoRouter Configuration

**File:** `lib/config/router.dart`

```dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

final GoRouter appRouter = GoRouter(
  debugLogDiagnostics: true,
  initialLocation: '/',
  errorBuilder: (context, state) => ErrorScreen(error: state.error),
  redirect: (context, state) {
    // Authentication guard logic
    final isAuthenticated = /* check auth state */;
    final isAuthRoute = state.subloc.startsWith('/auth');
    
    if (!isAuthenticated && !isAuthRoute) {
      return '/auth/login';
    }
    if (isAuthenticated && isAuthRoute) {
      return '/dashboard';
    }
    return null; // No redirect
  },
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const HomeScreen(),
    ),
    GoRoute(
      path: '/auth/login',
      name: 'login',
      builder: (context, state) => const LoginScreen(),
    ),
    GoRoute(
      path: '/dashboard',
      name: 'dashboard',
      builder: (context, state) => const DashboardScreen(),
    ),
    GoRoute(
      path: '/work-items',
      name: 'work-items',
      builder: (context, state) => const WorkItemsScreen(),
      routes: [
        GoRoute(
          path: ':id',
          name: 'work-item-detail',
          builder: (context, state) {
            final id = state.params['id']!;
            return WorkItemDetailScreen(id: id);
          },
        ),
      ],
    ),
    // Additional routes...
  ],
);
```

#### 2. Navigation AppBar

**File:** `lib/widgets/navigation/app_navigation_bar.dart`

Features:
- Logo and branding
- Breadcrumb navigation trail
- Search bar (global search)
- Action buttons (theme toggle, notifications, profile)
- Responsive layout

```dart
class AppNavigationBar extends StatelessWidget implements PreferredSizeWidget {
  @override
  Widget build(BuildContext context) {
    return AppBar(
      leading: /* logo or menu icon */,
      title: BreadcrumbWidget(),
      actions: [
        IconButton(icon: Icon(Icons.search), onPressed: () {}),
        IconButton(icon: Icon(Icons.notifications), onPressed: () {}),
        UserProfileMenu(),
      ],
    );
  }
  
  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight);
}
```

#### 3. App Drawer

**File:** `lib/widgets/navigation/app_drawer.dart`

Features:
- User profile header
- Hierarchical menu structure
- Active route highlighting
- Icon + text menu items
- Collapsible sections

```dart
class AppDrawer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        children: [
          UserAccountsDrawerHeader(/* user info */),
          ListTile(
            leading: Icon(Icons.dashboard),
            title: Text('Dashboard'),
            onTap: () => context.go('/dashboard'),
            selected: /* check if active */,
          ),
          // More menu items...
        ],
      ),
    );
  }
}
```

#### 4. Breadcrumb Widget

**File:** `lib/widgets/navigation/breadcrumb.dart`

Features:
- Auto-generate from current route
- Clickable breadcrumb links
- Separator customization
- Responsive (hide on mobile if needed)

```dart
class BreadcrumbWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final location = GoRouter.of(context).location;
    final crumbs = _generateBreadcrumbs(location);
    
    return Row(
      children: crumbs.map((crumb) => /* crumb widget */).toList(),
    );
  }
  
  List<Breadcrumb> _generateBreadcrumbs(String location) {
    // Parse location and generate breadcrumb trail
  }
}
```

#### 5. Error Screen

**File:** `lib/screens/error_screen.dart`

Features:
- Friendly 404 message
- Navigation back to home
- Search functionality
- Suggested pages

### Dependencies

Add to `pubspec.yaml`:
```yaml
dependencies:
  go_router: ^13.0.0  # Latest stable version
```

### Route Guard Strategy

1. **Authentication Guard:**
   - Check if user is authenticated before allowing access to protected routes
   - Redirect to `/auth/login` if not authenticated
   - Store intended destination for post-login redirect

2. **Role-Based Access:**
   - Check user permissions for specific routes (e.g., admin-only pages)
   - Show 403 Forbidden page if insufficient permissions

3. **Implementation:**
   ```dart
   redirect: (context, state) {
     final authState = /* get auth state from provider */;
     final isProtected = !state.subloc.startsWith('/auth');
     
     if (isProtected && !authState.isAuthenticated) {
       return '/auth/login?redirect=${state.subloc}';
     }
     return null;
   }
   ```

### Responsive Navigation

- **Mobile (<600px):**
  - Drawer navigation (hamburger menu)
  - Compact AppBar
  - Hide breadcrumbs

- **Tablet (600-900px):**
  - NavigationRail (collapsed)
  - Show breadcrumbs
  - Compact icons

- **Desktop (>900px):**
  - NavigationRail (expanded)
  - Full breadcrumb trail
  - All navigation elements visible

## Acceptance Criteria

- [ ] go_router successfully installed and configured
- [ ] All initial routes defined and accessible
- [ ] AppBar with breadcrumb navigation displays correctly
- [ ] Drawer navigation works on mobile/tablet
- [ ] NavigationRail displays on desktop
- [ ] Active route highlighted in navigation menus
- [ ] Route guards redirect unauthenticated users to login
- [ ] Custom error page displays for invalid routes
- [ ] Navigation state preserved on browser refresh (web)
- [ ] Deep links work correctly (web platform)
- [ ] Breadcrumbs generate automatically from current route
- [ ] All navigation actions trigger correct route changes
- [ ] No console errors during navigation

## Testing Requirements

### Unit Tests
- Test route guard logic
- Test breadcrumb generation from route paths
- Test redirect logic for authentication

### Widget Tests
- Test AppBar renders correctly
- Test Drawer menu displays all items
- Test NavigationRail renders on desktop
- Test breadcrumb widget shows correct trail
- Test error screen displays

### Integration Tests
- Navigate between all routes
- Test authentication flow (login → protected route)
- Test deep linking
- Test browser back/forward buttons
- Test route parameters passing

## Validation Steps

1. **Route Navigation:**
   ```bash
   cd /workspaces/CodeValdFortex/src
   flutter run -d web-server --web-port=8090
   ```
   - Navigate to all routes manually
   - Verify URLs update correctly
   - Test browser back/forward

2. **Authentication Flow:**
   - Access protected route while logged out → should redirect to login
   - Login → should redirect back to intended destination

3. **Responsive Testing:**
   - Resize browser window
   - Verify Drawer appears on mobile
   - Verify NavigationRail appears on desktop

4. **Error Handling:**
   - Navigate to invalid route (e.g., `/invalid-route`)
   - Verify error page displays
   - Verify navigation back to home works

## Notes

- go_router v13+ uses different APIs than older versions (check migration guide)
- Route names should match screen names for consistency
- Use named routes instead of path strings where possible
- Consider adding route transition animations in future tasks
- Deep linking configuration may require platform-specific setup (iOS/Android)
- This task creates navigation infrastructure; actual screens will be built in subsequent tasks

## References

- [go_router documentation](https://pub.dev/packages/go_router)
- Dashboard design spec: `/documents/2-SoftwareDesignAndArchitecture/flutter-designs/dashboard-design.md`
- Design patterns: `/documents/2-SoftwareDesignAndArchitecture/flutter-designs/design-patterns.md`
