import 'package:flutter/foundation.dart';

/// Represents a single introduction field with label and content
@immutable
class IntroductionField {
  final String id;
  final String label;
  final String content;

  const IntroductionField({
    required this.id,
    required this.label,
    required this.content,
  });

  IntroductionField copyWith({
    String? id,
    String? label,
    String? content,
  }) {
    return IntroductionField(
      id: id ?? this.id,
      label: label ?? this.label,
      content: content ?? this.content,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is IntroductionField &&
        other.id == id &&
        other.label == label &&
        other.content == content;
  }

  @override
  int get hashCode => Object.hash(id, label, content);
}

/// State model for the agency introduction section
@immutable
class IntroductionState {
  final String agencyId;
  final List<IntroductionField> fields;
  final SaveStatus saveStatus;
  final DateTime? lastSavedAt;
  final String? errorMessage;
  final Map<String, String> validationErrors;

  const IntroductionState({
    required this.agencyId,
    this.fields = const [],
    this.saveStatus = SaveStatus.idle,
    this.lastSavedAt,
    this.errorMessage,
    this.validationErrors = const {},
  });

  // Character limit per field
  static const int fieldLimit = 1000;

  // Computed properties
  bool get isValid {
    // All fields must have labels and content within limit
    for (final field in fields) {
      if (field.label.trim().isEmpty) return false;
      if (field.content.length > fieldLimit) return false;
    }
    return true;
  }

  bool get isComplete => isValid && validationErrors.isEmpty && fields.isNotEmpty;

  IntroductionState copyWith({
    String? agencyId,
    List<IntroductionField>? fields,
    SaveStatus? saveStatus,
    DateTime? lastSavedAt,
    String? errorMessage,
    Map<String, String>? validationErrors,
  }) {
    return IntroductionState(
      agencyId: agencyId ?? this.agencyId,
      fields: fields ?? this.fields,
      saveStatus: saveStatus ?? this.saveStatus,
      lastSavedAt: lastSavedAt ?? this.lastSavedAt,
      errorMessage: errorMessage ?? this.errorMessage,
      validationErrors: validationErrors ?? this.validationErrors,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is IntroductionState &&
        other.agencyId == agencyId &&
        listEquals(other.fields, fields) &&
        other.saveStatus == saveStatus &&
        other.lastSavedAt == lastSavedAt &&
        other.errorMessage == errorMessage &&
        mapEquals(other.validationErrors, validationErrors);
  }

  @override
  int get hashCode {
    return Object.hash(
      agencyId,
      Object.hashAll(fields),
      saveStatus,
      lastSavedAt,
      errorMessage,
      Object.hashAll(validationErrors.entries),
    );
  }
}

/// Save status for introduction section
enum SaveStatus {
  idle, // No save in progress
  saving, // Save request in flight
  saved, // Successfully saved
  error, // Save failed
}
