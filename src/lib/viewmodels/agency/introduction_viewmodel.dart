import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
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
  final _uuid = const Uuid();

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
      
      // Convert map to list of fields
      final fields = data.entries.map((entry) {
        return IntroductionField(
          id: _uuid.v4(),
          label: entry.key,
          content: entry.value as String,
        );
      }).toList();

      state = state.copyWith(
        fields: fields,
        saveStatus: SaveStatus.idle,
      );
    } catch (e) {
      // If introduction doesn't exist yet, start with one empty field
      state = state.copyWith(
        fields: [
          IntroductionField(
            id: _uuid.v4(),
            label: 'Overview',
            content: '',
          ),
        ],
        saveStatus: SaveStatus.idle,
      );
    }
  }

  /// Add a new field
  void addField() {
    final newField = IntroductionField(
      id: _uuid.v4(),
      label: '',
      content: '',
    );
    state = state.copyWith(fields: [...state.fields, newField]);
  }

  /// Remove a field by ID
  void removeField(String fieldId) {
    if (state.fields.length <= 1) return; // Keep at least one field
    state = state.copyWith(
      fields: state.fields.where((f) => f.id != fieldId).toList(),
    );
    _scheduleAutoSave();
  }

  /// Update field label
  void updateFieldLabel(String fieldId, String label) {
    state = state.copyWith(
      fields: state.fields.map((f) {
        return f.id == fieldId ? f.copyWith(label: label) : f;
      }).toList(),
    );
    _validate();
  }

  /// Update field content
  void updateFieldContent(String fieldId, String content) {
    state = state.copyWith(
      fields: state.fields.map((f) {
        return f.id == fieldId ? f.copyWith(content: content) : f;
      }).toList(),
    );
    _validate();
    _scheduleAutoSave();
  }

  /// Validate all fields
  void _validate() {
    final errors = <String, String>{};

    for (var i = 0; i < state.fields.length; i++) {
      final field = state.fields[i];
      
      if (field.label.trim().isEmpty) {
        errors['field_${field.id}_label'] = 'Label is required';
      }

      if (field.content.length > IntroductionState.fieldLimit) {
        errors['field_${field.id}_content'] =
            'Content cannot exceed ${IntroductionState.fieldLimit} characters';
      }
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
      // Convert fields to map
      final introductionData = <String, String>{};
      for (final field in state.fields) {
        if (field.label.trim().isNotEmpty) {
          introductionData[field.label] = field.content;
        }
      }

      await repository.saveIntroduction(agencyId, introductionData);

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
