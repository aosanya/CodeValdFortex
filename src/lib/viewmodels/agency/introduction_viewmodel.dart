import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/agency/introduction_state.dart';
import '../../repositories/agency_repository.dart';
import '../../providers/agency_provider.dart';

/// Provider for introduction viewmodel (family by agencyId)
final introductionViewModelProvider = StateNotifierProvider.family<
    IntroductionViewModel,
    IntroductionState,
    String>((ref, agencyId) {
  final repository = ref.watch(agencyRepositoryProvider);
  return IntroductionViewModel(agencyId: agencyId, repository: repository);
});

/// ViewModel for managing agency introduction state and business logic
class IntroductionViewModel extends StateNotifier<IntroductionState> {
  final String agencyId;
  final AgencyRepository repository;
  Timer? _debounceTimer;
  int _saveAttempts = 0;

  IntroductionViewModel({
    required this.agencyId,
    required this.repository,
  }) : super(IntroductionState(agencyId: agencyId)) {
    _loadIntroduction();
  }

  /// Load introduction from backend
  Future<void> _loadIntroduction() async {
    try {
      final data = await repository.getIntroduction(agencyId);
      state = state.copyWith(
        background: data['background'] ?? '',
        purpose: data['purpose'] ?? '',
        scope: data['scope'] ?? '',
        saveStatus: SaveStatus.idle,
      );
    } catch (e) {
      // If introduction doesn't exist yet, start with empty state
      state = state.copyWith(saveStatus: SaveStatus.idle);
    }
  }

  /// Update background field
  void updateBackground(String value) {
    state = state.copyWith(background: value);
    _validate();
    _scheduleAutoSave();
  }

  /// Update purpose field
  void updatePurpose(String value) {
    state = state.copyWith(purpose: value);
    _validate();
    _scheduleAutoSave();
  }

  /// Update scope field
  void updateScope(String value) {
    state = state.copyWith(scope: value);
    _validate();
    _scheduleAutoSave();
  }

  /// Validate all fields
  void _validate() {
    final errors = <String, String>{};

    // Background validation
    if (state.background.isEmpty) {
      errors['background'] = 'Background is required';
    } else if (state.background.length < IntroductionState.backgroundMin) {
      errors['background'] =
          'Background must be at least ${IntroductionState.backgroundMin} characters';
    } else if (state.background.length > IntroductionState.backgroundLimit) {
      errors['background'] =
          'Background cannot exceed ${IntroductionState.backgroundLimit} characters';
    }

    // Purpose validation
    if (state.purpose.isEmpty) {
      errors['purpose'] = 'Purpose is required';
    } else if (state.purpose.length < IntroductionState.purposeMin) {
      errors['purpose'] =
          'Purpose must be at least ${IntroductionState.purposeMin} characters';
    } else if (state.purpose.length > IntroductionState.purposeLimit) {
      errors['purpose'] =
          'Purpose cannot exceed ${IntroductionState.purposeLimit} characters';
    }

    // Scope validation
    if (state.scope.isEmpty) {
      errors['scope'] = 'Scope is required';
    } else if (state.scope.length < IntroductionState.scopeMin) {
      errors['scope'] =
          'Scope must be at least ${IntroductionState.scopeMin} characters';
    } else if (state.scope.length > IntroductionState.scopeLimit) {
      errors['scope'] =
          'Scope cannot exceed ${IntroductionState.scopeLimit} characters';
    }

    state = state.copyWith(validationErrors: errors);
  }

  /// Schedule auto-save (debounced)
  void _scheduleAutoSave() {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(seconds: 2), () {
      saveIntroduction();
    });
  }

  /// Manual save with retry logic
  Future<void> saveIntroduction() async {
    if (!state.isValid) return;

    state = state.copyWith(saveStatus: SaveStatus.saving);

    try {
      await repository.saveIntroduction(
        agencyId,
        background: state.background,
        purpose: state.purpose,
        scope: state.scope,
      );

      state = state.copyWith(
        saveStatus: SaveStatus.saved,
        lastSavedAt: DateTime.now(),
        errorMessage: null,
      );
      _saveAttempts = 0;
    } catch (e) {
      _saveAttempts++;

      if (_saveAttempts < 3) {
        // Retry with exponential backoff
        await Future.delayed(Duration(milliseconds: 500 * _saveAttempts));
        await saveIntroduction();
      } else {
        state = state.copyWith(
          saveStatus: SaveStatus.error,
          errorMessage: e.toString(),
        );
        _saveAttempts = 0;
      }
    }
  }

  /// Save on focus loss
  void onFocusLost() {
    _debounceTimer?.cancel();
    saveIntroduction();
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    super.dispose();
  }
}
