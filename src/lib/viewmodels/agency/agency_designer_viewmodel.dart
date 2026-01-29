import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/agency/agency_designer_state.dart';

/// ViewModel for managing Agency Designer navigation and state
class AgencyDesignerViewModel extends StateNotifier<AgencyDesignerState> {
  AgencyDesignerViewModel(
    String agencyId,
    String agencyName,
  ) : super(AgencyDesignerState(
          agencyId: agencyId,
          agencyName: agencyName,
        )) {
    _initializeSectionCompletion();
  }

  /// Initialize section completion states
  void _initializeSectionCompletion() {
    final initialCompletion = <DesignerSection, SectionCompletionStatus>{};
    for (final section in DesignerSection.values) {
      initialCompletion[section] = SectionCompletionStatus.notStarted;
    }
    state = state.copyWith(sectionCompletion: initialCompletion);
  }

  /// Navigate to a different section
  void navigateToSection(DesignerSection section) {
    state = state.copyWith(activeSection: section);
  }

  /// Mark a section with a specific completion status
  void updateSectionStatus(
    DesignerSection section,
    SectionCompletionStatus status,
  ) {
    final updatedCompletion =
        Map<DesignerSection, SectionCompletionStatus>.from(
      state.sectionCompletion,
    );
    updatedCompletion[section] = status;

    state = state.copyWith(
      sectionCompletion: updatedCompletion,
      hasUnsavedChanges: true,
    );
  }

  /// Mark section as complete
  void markSectionComplete(DesignerSection section) {
    updateSectionStatus(section, SectionCompletionStatus.complete);
  }

  /// Mark section as in progress
  void markSectionInProgress(DesignerSection section) {
    updateSectionStatus(section, SectionCompletionStatus.inProgress);
  }

  /// Get completion status for a section
  SectionCompletionStatus getSectionStatus(DesignerSection section) {
    return state.sectionCompletion[section] ??
        SectionCompletionStatus.notStarted;
  }

  /// Save all progress to backend
  Future<void> saveProgress() async {
    if (state.isSaving) return;

    state = state.copyWith(isSaving: true, error: null);

    try {
      // TODO: Implement API call to save designer state
      // For now, just simulate save with delay
      await Future.delayed(const Duration(seconds: 1));

      state = state.copyWith(
        isSaving: false,
        hasUnsavedChanges: false,
      );
    } catch (e) {
      state = state.copyWith(
        isSaving: false,
        error: e.toString(),
      );
    }
  }

  /// Check if there are unsaved changes before navigation
  bool hasUnsavedChanges() {
    return state.hasUnsavedChanges;
  }

  /// Clear error message
  void clearError() {
    state = state.copyWith(error: null);
  }
}

/// Provider for AgencyDesignerViewModel
/// Takes agencyId and agencyName as parameters
final agencyDesignerViewModelProvider = StateNotifierProvider.family<
    AgencyDesignerViewModel,
    AgencyDesignerState,
    ({String agencyId, String agencyName})>(
  (ref, params) {
    return AgencyDesignerViewModel(
      params.agencyId,
      params.agencyName,
    );
  },
);
