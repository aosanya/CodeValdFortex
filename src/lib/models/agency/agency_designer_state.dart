import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// Represents the current state of the Agency Designer
@immutable
class AgencyDesignerState {
  final String agencyId;
  final String agencyName;
  final DesignerSection activeSection;
  final Map<DesignerSection, SectionCompletionStatus> sectionCompletion;
  final bool hasUnsavedChanges;
  final bool isSaving;
  final String? error;

  const AgencyDesignerState({
    required this.agencyId,
    required this.agencyName,
    this.activeSection = DesignerSection.introduction,
    this.sectionCompletion = const {},
    this.hasUnsavedChanges = false,
    this.isSaving = false,
    this.error,
  });

  AgencyDesignerState copyWith({
    String? agencyId,
    String? agencyName,
    DesignerSection? activeSection,
    Map<DesignerSection, SectionCompletionStatus>? sectionCompletion,
    bool? hasUnsavedChanges,
    bool? isSaving,
    String? error,
  }) {
    return AgencyDesignerState(
      agencyId: agencyId ?? this.agencyId,
      agencyName: agencyName ?? this.agencyName,
      activeSection: activeSection ?? this.activeSection,
      sectionCompletion: sectionCompletion ?? this.sectionCompletion,
      hasUnsavedChanges: hasUnsavedChanges ?? this.hasUnsavedChanges,
      isSaving: isSaving ?? this.isSaving,
      error: error,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is AgencyDesignerState &&
        other.agencyId == agencyId &&
        other.agencyName == agencyName &&
        other.activeSection == activeSection &&
        mapEquals(other.sectionCompletion, sectionCompletion) &&
        other.hasUnsavedChanges == hasUnsavedChanges &&
        other.isSaving == isSaving &&
        other.error == error;
  }

  @override
  int get hashCode {
    return Object.hash(
      agencyId,
      agencyName,
      activeSection,
      sectionCompletion,
      hasUnsavedChanges,
      isSaving,
      error,
    );
  }
}

/// Designer section enum
enum DesignerSection {
  introduction,
  goals,
  workItems,
  roles,
  raciMatrix,
  workflows,
  policy,
  admin;

  String get displayName {
    switch (this) {
      case DesignerSection.introduction:
        return 'Introduction';
      case DesignerSection.goals:
        return 'Goals';
      case DesignerSection.workItems:
        return 'Work Items';
      case DesignerSection.roles:
        return 'Roles';
      case DesignerSection.raciMatrix:
        return 'RACI Matrix';
      case DesignerSection.workflows:
        return 'Workflows';
      case DesignerSection.policy:
        return 'Policy';
      case DesignerSection.admin:
        return 'Admin';
    }
  }

  IconData get icon {
    switch (this) {
      case DesignerSection.introduction:
        return Icons.info_outline;
      case DesignerSection.goals:
        return Icons.flag_outlined;
      case DesignerSection.workItems:
        return Icons.task_outlined;
      case DesignerSection.roles:
        return Icons.people_outline;
      case DesignerSection.raciMatrix:
        return Icons.table_chart_outlined;
      case DesignerSection.workflows:
        return Icons.account_tree_outlined;
      case DesignerSection.policy:
        return Icons.policy_outlined;
      case DesignerSection.admin:
        return Icons.settings_outlined;
    }
  }
}

/// Section completion status
enum SectionCompletionStatus {
  notStarted,
  inProgress,
  complete;

  String get displayName {
    switch (this) {
      case SectionCompletionStatus.notStarted:
        return 'Not Started';
      case SectionCompletionStatus.inProgress:
        return 'In Progress';
      case SectionCompletionStatus.complete:
        return 'Complete';
    }
  }

  IconData get icon {
    switch (this) {
      case SectionCompletionStatus.notStarted:
        return Icons.radio_button_unchecked;
      case SectionCompletionStatus.inProgress:
        return Icons.pending_outlined;
      case SectionCompletionStatus.complete:
        return Icons.check_circle_outline;
    }
  }
}
