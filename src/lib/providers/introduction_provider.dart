import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/agency/agency_introduction.dart';
import '../models/agency/introduction_section.dart';
import '../repositories/introduction_repository.dart';

/// Provider for IntroductionRepository
final introductionRepositoryProvider = Provider<IntroductionRepository>((ref) {
  return IntroductionRepository();
});

/// State class for introduction management
class IntroductionState {
  final AgencyIntroduction? introduction;
  final bool isLoading;
  final bool isSaving;
  final String? errorMessage;
  final String? successMessage;

  const IntroductionState({
    this.introduction,
    this.isLoading = false,
    this.isSaving = false,
    this.errorMessage,
    this.successMessage,
  });

  IntroductionState copyWith({
    AgencyIntroduction? introduction,
    bool? isLoading,
    bool? isSaving,
    String? errorMessage,
    bool clearError = false,
    String? successMessage,
    bool clearSuccess = false,
  }) {
    return IntroductionState(
      introduction: introduction ?? this.introduction,
      isLoading: isLoading ?? this.isLoading,
      isSaving: isSaving ?? this.isSaving,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      successMessage:
          clearSuccess ? null : (successMessage ?? this.successMessage),
    );
  }
}

/// Introduction state notifier
class IntroductionNotifier extends StateNotifier<IntroductionState> {
  final IntroductionRepository _repository;
  final String agencyId;

  IntroductionNotifier(this._repository, this.agencyId)
      : super(const IntroductionState()) {
    loadIntroduction();
  }

  /// Load introduction for the agency
  Future<void> loadIntroduction() async {
    state = state.copyWith(isLoading: true, clearError: true);

    try {
      final introduction = await _repository.getIntroduction(agencyId);
      state = state.copyWith(
        introduction: introduction,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString(),
      );
    }
  }

  /// Create a new introduction
  Future<void> createIntroduction(AgencyIntroduction introduction) async {
    state = state.copyWith(isSaving: true, clearError: true);

    try {
      final created = await _repository.createIntroduction(introduction);
      state = state.copyWith(
        introduction: created,
        isSaving: false,
        successMessage: 'Introduction created successfully',
      );
    } catch (e) {
      state = state.copyWith(
        isSaving: false,
        errorMessage: e.toString(),
      );
    }
  }

  /// Update the introduction
  Future<void> updateIntroduction(AgencyIntroduction introduction) async {
    state = state.copyWith(isSaving: true, clearError: true);

    try {
      final updated = await _repository.updateIntroduction(introduction);
      state = state.copyWith(
        introduction: updated,
        isSaving: false,
        successMessage: 'Introduction updated successfully',
      );
    } catch (e) {
      state = state.copyWith(
        isSaving: false,
        errorMessage: e.toString(),
      );
    }
  }

  /// Delete the introduction
  Future<void> deleteIntroduction() async {
    state = state.copyWith(isSaving: true, clearError: true);

    try {
      await _repository.deleteIntroduction(agencyId);
      state = state.copyWith(
        introduction: null,
        isSaving: false,
        successMessage: 'Introduction deleted successfully',
      );
    } catch (e) {
      state = state.copyWith(
        isSaving: false,
        errorMessage: e.toString(),
      );
    }
  }

  /// Add a new section
  Future<void> addSection(IntroductionSection section) async {
    state = state.copyWith(isSaving: true, clearError: true);

    try {
      await _repository.addSection(agencyId, section);
      // Reload to get updated introduction
      await loadIntroduction();
      state = state.copyWith(
        isSaving: false,
        successMessage: 'Section added successfully',
      );
    } catch (e) {
      state = state.copyWith(
        isSaving: false,
        errorMessage: e.toString(),
      );
    }
  }

  /// Update a section
  Future<void> updateSection(
    String sectionId,
    IntroductionSection section,
  ) async {
    state = state.copyWith(isSaving: true, clearError: true);

    try {
      await _repository.updateSection(agencyId, sectionId, section);
      // Reload to get updated introduction
      await loadIntroduction();
      state = state.copyWith(
        isSaving: false,
        successMessage: 'Section updated successfully',
      );
    } catch (e) {
      state = state.copyWith(
        isSaving: false,
        errorMessage: e.toString(),
      );
    }
  }

  /// Delete a section
  Future<void> deleteSection(String sectionId) async {
    state = state.copyWith(isSaving: true, clearError: true);

    try {
      await _repository.deleteSection(agencyId, sectionId);
      // Reload to get updated introduction
      await loadIntroduction();
      state = state.copyWith(
        isSaving: false,
        successMessage: 'Section deleted successfully',
      );
    } catch (e) {
      state = state.copyWith(
        isSaving: false,
        errorMessage: e.toString(),
      );
    }
  }

  /// Reorder sections
  Future<void> reorderSections(List<String> sectionIds) async {
    state = state.copyWith(isSaving: true, clearError: true);

    try {
      await _repository.reorderSections(agencyId, sectionIds);
      // Reload to get updated introduction
      await loadIntroduction();
      state = state.copyWith(
        isSaving: false,
        successMessage: 'Sections reordered successfully',
      );
    } catch (e) {
      state = state.copyWith(
        isSaving: false,
        errorMessage: e.toString(),
      );
    }
  }

  /// Apply a template
  Future<void> applyTemplate(String template) async {
    state = state.copyWith(isLoading: true, clearError: true);

    try {
      final introduction = await _repository.applyTemplate(agencyId, template);
      state = state.copyWith(
        introduction: introduction,
        isLoading: false,
        successMessage: 'Template applied successfully',
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString(),
      );
    }
  }

  /// Generate introduction using AI
  Future<void> generateIntroduction({
    required List<String> keywords,
    String? template,
    Map<String, dynamic>? agencyContext,
  }) async {
    state = state.copyWith(isLoading: true, clearError: true);

    try {
      final response = await _repository.generateIntroduction(
        agencyId: agencyId,
        keywords: keywords,
        template: template,
        agencyContext: agencyContext,
      );

      final introduction = AgencyIntroduction.fromJson(
          response['introduction'] as Map<String, dynamic>);
      final confidence = response['confidence'] as double?;
      final explanation = response['explanation'] as String?;

      state = state.copyWith(
        introduction: introduction,
        isLoading: false,
        successMessage: explanation ??
            'Introduction generated successfully (confidence: ${(confidence ?? 0) * 100}%)',
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString(),
      );
    }
  }

  /// Refine a section using AI
  Future<void> refineSection({
    required String sectionId,
    required IntroductionSection section,
    required String refinementText,
    Map<String, dynamic>? agencyContext,
  }) async {
    state = state.copyWith(isSaving: true, clearError: true);

    try {
      final response = await _repository.refineSection(
        agencyId: agencyId,
        sectionId: sectionId,
        section: section,
        refinementText: refinementText,
        agencyContext: agencyContext,
      );

      final refined = IntroductionSection.fromJson(
          response['section'] as Map<String, dynamic>);
      final changed = response['changed'] as bool? ?? false;
      final explanation = response['explanation'] as String?;

      if (changed) {
        // Reload to get updated introduction
        await loadIntroduction();
        state = state.copyWith(
          isSaving: false,
          successMessage: explanation ?? 'Section refined successfully',
        );
      } else {
        state = state.copyWith(
          isSaving: false,
          successMessage: explanation ?? 'No changes needed',
        );
      }
    } catch (e) {
      state = state.copyWith(
        isSaving: false,
        errorMessage: e.toString(),
      );
    }
  }

  /// Clear error message
  void clearError() {
    state = state.copyWith(clearError: true);
  }

  /// Clear success message
  void clearSuccess() {
    state = state.copyWith(clearSuccess: true);
  }

  /// Refresh introduction
  Future<void> refresh() async {
    await loadIntroduction();
  }
}

/// Provider factory for introduction state
final introductionProvider = StateNotifierProvider.family<IntroductionNotifier,
    IntroductionState, String>((ref, agencyId) {
  final repository = ref.watch(introductionRepositoryProvider);
  return IntroductionNotifier(repository, agencyId);
});

/// Provider for available templates
final templatesProvider = FutureProvider.family<List<String>, String>(
  (ref, agencyId) async {
    final repository = ref.watch(introductionRepositoryProvider);
    return repository.getTemplates(agencyId);
  },
);
