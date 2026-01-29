import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/agency/agency_form_state.dart';
import '../../repositories/agency_repository.dart';

/// State for the agency form ViewModel
class AgencyFormViewModelState {
  final AgencyFormState formState;
  final AgencyFormState? originalFormState;
  final bool isLoading;
  final String? error;
  final String? createdId;
  final bool hasUnsavedChanges;

  const AgencyFormViewModelState({
    required this.formState,
    this.originalFormState,
    required this.isLoading,
    this.error,
    this.createdId,
    required this.hasUnsavedChanges,
  });

  bool get isValid => formState.isValid;

  AgencyFormViewModelState copyWith({
    AgencyFormState? formState,
    AgencyFormState? originalFormState,
    bool? isLoading,
    String? error,
    String? createdId,
    bool? hasUnsavedChanges,
  }) {
    return AgencyFormViewModelState(
      formState: formState ?? this.formState,
      originalFormState: originalFormState ?? this.originalFormState,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      createdId: createdId ?? this.createdId,
      hasUnsavedChanges: hasUnsavedChanges ?? this.hasUnsavedChanges,
    );
  }
}

/// ViewModel for managing agency form state and operations
class AgencyFormViewModel extends StateNotifier<AgencyFormViewModelState> {
  final AgencyRepository _repository;

  AgencyFormViewModel(this._repository)
      : super(const AgencyFormViewModelState(
          formState: AgencyFormState(),
          isLoading: false,
          hasUnsavedChanges: false,
        ));

  /// Update a form field
  void updateField(String field, dynamic value) {
    final currentState = state.formState;
    AgencyFormState newFormState;

    switch (field) {
      case 'name':
        newFormState = currentState.copyWith(name: value as String);
        break;
      case 'description':
        newFormState = currentState.copyWith(description: value as String);
        break;
      default:
        return;
    }

    // Validate
    final errors = _validate(newFormState);
    newFormState = newFormState.copyWith(
      errors: errors,
      isModified: true,
    );

    state = state.copyWith(
      formState: newFormState,
      hasUnsavedChanges: true,
    );
  }

  /// Validate form state
  Map<String, String> _validate(AgencyFormState formState) {
    final errors = <String, String>{};

    // Name validation
    if (formState.name.trim().isEmpty) {
      errors['name'] = 'Agency name is required';
    } else if (formState.name.trim().length < 3) {
      errors['name'] = 'Agency name must be at least 3 characters';
    } else if (formState.name.trim().length > 100) {
      errors['name'] = 'Agency name must not exceed 100 characters';
    }

    // Description validation
    if (formState.description.length > 500) {
      errors['description'] = 'Description must not exceed 500 characters';
    }

    return errors;
  }

  /// Create a new agency
  Future<bool> create() async {
    if (!state.formState.isValid) {
      return false;
    }

    state = state.copyWith(isLoading: true, error: null);

    try {
      final agency = await _repository.createAgency(
        name: state.formState.name.trim(),
        description: state.formState.description.trim(),
      );

      state = state.copyWith(
        isLoading: false,
        createdId: agency.id,
        hasUnsavedChanges: false,
      );

      return true;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      return false;
    }
  }

  /// Load existing agency for editing
  Future<void> loadForEdit(String id) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final agency = await _repository.getAgencyById(id);

      final formState = AgencyFormState(
        name: agency.name,
        description: agency.description,
      );

      state = state.copyWith(
        formState: formState,
        originalFormState: formState,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  /// Update an existing agency
  Future<bool> update(String id) async {
    if (!state.formState.isValid) {
      return false;
    }

    state = state.copyWith(isLoading: true, error: null);

    try {
      await _repository.updateAgency(
        id,
        {
          'name': state.formState.name.trim(),
          'description': state.formState.description.trim(),
        },
      );

      state = state.copyWith(
        isLoading: false,
        hasUnsavedChanges: false,
      );

      return true;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      return false;
    }
  }

  /// Reset form to initial state
  void reset() {
    state = AgencyFormViewModelState(
      formState: state.originalFormState ?? const AgencyFormState(),
      originalFormState: state.originalFormState,
      isLoading: false,
      hasUnsavedChanges: false,
    );
  }

  /// Clear all form data
  void clear() {
    state = const AgencyFormViewModelState(
      formState: AgencyFormState(),
      isLoading: false,
      hasUnsavedChanges: false,
    );
  }
}

/// Provider for AgencyRepository
final agencyRepositoryProvider = Provider<AgencyRepository>((ref) {
  return AgencyRepository();
});

/// Provider for AgencyFormViewModel
final agencyFormViewModelProvider =
    StateNotifierProvider<AgencyFormViewModel, AgencyFormViewModelState>((ref) {
  final repository = ref.watch(agencyRepositoryProvider);
  return AgencyFormViewModel(repository);
});