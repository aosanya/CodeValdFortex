import 'package:flutter/foundation.dart';
import 'agency_status.dart';

/// Represents an agency in the system
@immutable
class Agency {
  final String id;
  final String name;
  final String description;
  final AgencyStatus status;
  final DateTime createdAt;
  final DateTime updatedAt;
  final Map<String, dynamic>? metadata;

  const Agency({
    required this.id,
    required this.name,
    required this.description,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    this.metadata,
  });

  /// Create from JSON
  factory Agency.fromJson(Map<String, dynamic> json) {
    // API uses 'state' field, not 'status'
    final statusValue = json['state'] as String? ?? json['status'] as String?;
    
    return Agency(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String? ?? '',
      status: statusValue != null 
          ? AgencyStatus.fromString(statusValue)
          : AgencyStatus.draft,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      metadata: json['metadata'] as Map<String, dynamic>?,
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'status': status.name,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'metadata': metadata,
    };
  }

  /// Create a copy with updated fields
  Agency copyWith({
    String? id,
    String? name,
    String? description,
    AgencyStatus? status,
    DateTime? createdAt,
    DateTime? updatedAt,
    Map<String, dynamic>? metadata,
  }) {
    return Agency(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      metadata: metadata ?? this.metadata,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Agency &&
        other.id == id &&
        other.name == name &&
        other.description == description &&
        other.status == status &&
        other.createdAt == createdAt &&
        other.updatedAt == updatedAt;
  }

  @override
  int get hashCode {
    return Object.hash(id, name, description, status, createdAt, updatedAt);
  }

  @override
  String toString() {
    return 'Agency(id: $id, name: $name, status: ${status.name})';
  }
}
