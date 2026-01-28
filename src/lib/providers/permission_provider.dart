import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/auth/auth_user.dart';
import '../models/permission.dart';
import 'auth_provider.dart';

/// Provider for permission checking functionality
final permissionProvider = Provider<PermissionChecker>((ref) {
  final user = ref.watch(currentUserProvider);
  return PermissionChecker(user);
});

/// Utility class for checking user permissions
class PermissionChecker {
  final AuthUser? user;

  PermissionChecker(this.user);

  /// Get the user's role
  UserRole get userRole {
    if (user == null) return UserRole.guest;
    return UserRole.fromString(user!.role);
  }

  /// Check if user has a specific permission
  bool hasPermission(Permission permission) {
    if (user == null) return false;
    return userRole.hasPermission(permission);
  }

  /// Check if user has ANY of the specified permissions
  bool hasAnyPermission(List<Permission> permissions) {
    if (user == null) return false;
    return permissions.any((p) => hasPermission(p));
  }

  /// Check if user has ALL of the specified permissions
  bool hasAllPermissions(List<Permission> permissions) {
    if (user == null) return false;
    return permissions.every((p) => hasPermission(p));
  }

  /// Check if user has a specific role
  bool hasRole(UserRole role) {
    return userRole == role;
  }

  /// Check if user is an admin
  bool get isAdmin => userRole == UserRole.admin;

  /// Check if user is authenticated (not guest)
  bool get isAuthenticated => user != null && userRole != UserRole.guest;
}
