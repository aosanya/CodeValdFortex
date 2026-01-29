import 'package:flutter/foundation.dart';

/// Valid agency categories
enum AgencyCategory {
  infrastructure('infrastructure', 'Infrastructure', '🏗️'),
  agriculture('agriculture', 'Agriculture', '🌾'),
  logistics('logistics', 'Logistics', '📦'),
  transportation('transportation', 'Transportation', '🚗'),
  healthcare('healthcare', 'Healthcare', '🏥'),
  education('education', 'Education', '🎓'),
  finance('finance', 'Finance', '💰'),
  retail('retail', 'Retail', '🛒'),
  energy('energy', 'Energy', '⚡'),
  other('other', 'Other', '📋');

  final String value;
  final String label;
  final String icon;

  const AgencyCategory(this.value, this.label, this.icon);

  static AgencyCategory fromValue(String value) {
    return AgencyCategory.values.firstWhere(
      (c) => c.value == value,
      orElse: () => AgencyCategory.other,
    );
  }
}

/// Form state for creating/editing agencies
@immutable
class AgencyFormState {
  final String name;
  final String description;
  final AgencyCategory category;
  final Map<String, String> errors;
  final bool isModified;

  const AgencyFormState({
    this.name = '',
    this.description = '',
    this.category = AgencyCategory.other,
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
    AgencyCategory? category,
    Map<String, String>? errors,
    bool? isModified,
  }) {
    return AgencyFormState(
      name: name ?? this.name,
      description: description ?? this.description,
      category: category ?? this.category,
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
        other.category == category &&
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
