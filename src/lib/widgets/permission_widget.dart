import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/permission.dart';
import '../providers/permission_provider.dart';

/// Widget that conditionally renders its child based on a single permission
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

/// Widget that conditionally renders based on multiple permissions
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

/// Widget that conditionally renders based on user role
class RoleWidget extends ConsumerWidget {
  final UserRole role;
  final Widget child;
  final Widget? fallback;

  const RoleWidget({
    super.key,
    required this.role,
    required this.child,
    this.fallback,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final permissionChecker = ref.watch(permissionProvider);

    if (permissionChecker.hasRole(role)) {
      return child;
    }

    return fallback ?? const SizedBox.shrink();
  }
}

/// Widget that only renders for admin users
class AdminWidget extends ConsumerWidget {
  final Widget child;
  final Widget? fallback;

  const AdminWidget({super.key, required this.child, this.fallback});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final permissionChecker = ref.watch(permissionProvider);

    if (permissionChecker.isAdmin) {
      return child;
    }

    return fallback ?? const SizedBox.shrink();
  }
}
