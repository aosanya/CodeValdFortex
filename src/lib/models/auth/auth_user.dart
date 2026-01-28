import 'package:flutter/foundation.dart';

/// Represents an authenticated user in the system
@immutable
class AuthUser {
  final String id;
  final String email;
  final String name;
  final String? avatar;
  final String? role;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const AuthUser({
    required this.id,
    required this.email,
    required this.name,
    this.avatar,
    this.role,
    this.createdAt,
    this.updatedAt,
  });

  /// Create from JSON
  factory AuthUser.fromJson(Map<String, dynamic> json) {
    return AuthUser(
      id: json['id'] as String,
      email: json['email'] as String,
      name: json['name'] as String,
      avatar: json['avatar'] as String?,
      role: json['role'] as String?,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : null,
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'name': name,
      'avatar': avatar,
      'role': role,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  /// Create a copy with updated fields
  AuthUser copyWith({
    String? id,
    String? email,
    String? name,
    String? avatar,
    String? role,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return AuthUser(
      id: id ?? this.id,
      email: email ?? this.email,
      name: name ?? this.name,
      avatar: avatar ?? this.avatar,
      role: role ?? this.role,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is AuthUser &&
        other.id == id &&
        other.email == email &&
        other.name == name &&
        other.avatar == avatar &&
        other.role == role &&
        other.createdAt == createdAt &&
        other.updatedAt == updatedAt;
  }

  @override
  int get hashCode {
    return Object.hash(id, email, name, avatar, role, createdAt, updatedAt);
  }

  @override
  String toString() {
    return 'AuthUser(id: $id, email: $email, name: $name, role: $role)';
  }
}
