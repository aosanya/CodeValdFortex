import 'package:flutter/foundation.dart';

/// State model for the agency introduction section
@immutable
class IntroductionState {
  final String agencyId;
  final String background;
  final String purpose;
  final String scope;
  final SaveStatus saveStatus;
  final DateTime? lastSavedAt;
  final String? errorMessage;
  final Map<String, String> validationErrors;

  const IntroductionState({
    required this.agencyId,
    this.background = '',
    this.purpose = '',
    this.scope = '',
    this.saveStatus = SaveStatus.idle,
    this.lastSavedAt,
    this.errorMessage,
    this.validationErrors = const {},
  });

  // Character limits
  static const int backgroundLimit = 2000;
  static const int purposeLimit = 1000;
  static const int scopeLimit = 1500;

  // Minimum requirements
  static const int backgroundMin = 50;
  static const int purposeMin = 30;
  static const int scopeMin = 40;

  // Computed properties
  bool get isBackgroundValid =>
      background.length >= backgroundMin && background.length <= backgroundLimit;

  bool get isPurposeValid =>
      purpose.length >= purposeMin && purpose.length <= purposeLimit;

  bool get isScopeValid =>
      scope.length >= scopeMin && scope.length <= scopeLimit;

  bool get isValid => isBackgroundValid && isPurposeValid && isScopeValid;

  bool get isComplete => isValid && validationErrors.isEmpty;

  IntroductionState copyWith({
    String? agencyId,
    String? background,
    String? purpose,
    String? scope,
    SaveStatus? saveStatus,
    DateTime? lastSavedAt,
    String? errorMessage,
    Map<String, String>? validationErrors,
  }) {
    return IntroductionState(
      agencyId: agencyId ?? this.agencyId,
      background: background ?? this.background,
      purpose: purpose ?? this.purpose,
      scope: scope ?? this.scope,
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
        other.background == background &&
        other.purpose == purpose &&
        other.scope == scope &&
        other.saveStatus == saveStatus &&
        other.lastSavedAt == lastSavedAt &&
        other.errorMessage == errorMessage &&
        mapEquals(other.validationErrors, validationErrors);
  }

  @override
  int get hashCode {
    return Object.hash(
      agencyId,
      background,
      purpose,
      scope,
      saveStatus,
      lastSavedAt,
      errorMessage,
      validationErrors,
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
