/// Granular permissions for application features
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

/// User roles with predefined permission sets
enum UserRole {
  admin,
  user,
  viewer,
  guest;

  /// Get all permissions for this role
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

  /// Parse role from string (case-insensitive)
  static UserRole fromString(String? roleString) {
    if (roleString == null) return UserRole.guest;

    return UserRole.values.firstWhere(
      (r) => r.name.toLowerCase() == roleString.toLowerCase(),
      orElse: () => UserRole.guest,
    );
  }

  /// Check if this role has a specific permission
  bool hasPermission(Permission permission) {
    return permissions.contains(permission);
  }
}
