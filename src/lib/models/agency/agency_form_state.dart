import 'package:flutter/foundation.dart';

/// Form state for creating/editing agencies
@immutable
class AgencyFormState {
  final String name;
  final String description;
  final Map<String, String> errors;
  final bool isModified;

  const AgencyFormState({
    this.name = '',
    this.description = '',
    this.errors = const {},
    this.isModified = false,
  });

  /// Check if form is valid
  bool get isValid => errors.isEmpty && name.trim().isNotEmpty;

  /// Check if form has any data
  bool get hasData => name.isNotEmpty || description.isNotEmpty;

  /// Create a copy with updated fields
  AgencyFormState copyWith({
    String? name,
    String? description,
    Map<String, String>? errors,
    bool? isModified,
  }) {
    return AgencyFormState(
      name: name ?? this.name,
      description: description ?? this.description,
      errors: errors ?? this.errors,
      isModified: isModified ?? this.isModified,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is AgencyFormState &&
        other.name == name &&
        other.description == description &&
        mapEquals(other.errors, errors) &&
        other.isModified == isModified;
  }

  @override
  int get hashCode {
    return Object.hash(name, description, errors, isModified);
  }

  @override
  String toString() {
    return 'AgencyFormState(name: $name, isValid: $isValid, isModified: $isModified)';
  }
}
