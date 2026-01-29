# MVP-FL-104: Introduction Section

**Priority**: P0 (Critical)  
**Effort**: Medium  
**Skills**: Flutter, Rich Text, Forms  
**Dependencies**: MVP-FL-103  
**Status**: 📋 Not Started  
**Created**: 2026-01-29  

---

## Overview

Build the Introduction section for the Agency Designer, enabling users to define their agency's background, purpose, and scope through a rich text editing interface with auto-save, character limits, validation, and AI-powered content generation from uploaded documents.

This task migrates functionality from Cortex MVP-025 (Agency Introduction Editor) and adapts it for the Flutter/Fortex environment.

---

## User Stories

### Core Editing
- **As an agency designer**, I want to edit the agency introduction with rich text formatting so that I can create professional, well-structured content
- **As an agency designer**, I want to see character counts and limits for each field so that I maintain appropriate content length
- **As an agency designer**, I want auto-save functionality so that I don't lose my work if I navigate away or experience connectivity issues
- **As an agency designer**, I want to see save status indicators (saving/saved/error) so that I know my changes are persisted

### AI Assistance
- **As an agency designer**, I want to upload existing documents and have AI generate introduction content so that I can quickly bootstrap my agency definition
- **As an agency designer**, I want AI to suggest improvements to my introduction text so that I can create higher quality content

### Validation & UX
- **As an agency designer**, I want validation messages for empty or invalid content so that I know what needs to be fixed
- **As an agency designer**, I want to mark the section as complete when all required fields are filled so that I can track my progress through the designer

---

## Requirements

### Functional Requirements

#### 1. Introduction Form Fields

The introduction section should capture three key pieces of information:

1. **Background** (Required)
   - Description: The context and history that led to the agency's creation
   - Character limit: 2000 characters
   - Validation: Minimum 50 characters
   - Rich text support: Basic formatting (bold, italic, lists, links)

2. **Purpose** (Required)
   - Description: The agency's reason for existence and intended impact
   - Character limit: 1000 characters
   - Validation: Minimum 30 characters
   - Rich text support: Basic formatting

3. **Scope** (Required)
   - Description: Boundaries, focus areas, and what's included/excluded
   - Character limit: 1500 characters
   - Validation: Minimum 40 characters
   - Rich text support: Basic formatting

#### 2. Rich Text Editor Features

- **Formatting Options**:
  - Bold, italic, underline
  - Bulleted and numbered lists
  - Hyperlinks
  - Clear formatting option
  
- **Editor Behavior**:
  - Toolbar positioned above editor
  - Focus states with Material Design 3 styling
  - Keyboard shortcuts (Ctrl+B, Ctrl+I, Ctrl+U)
  - Paste text with formatting preservation (optional)
  - Mobile-optimized toolbar (condensed/overflow menu)

#### 3. Character Counter

- **Display Format**: "X / Y characters" below each editor
- **Color Coding**:
  - Green: 0-80% of limit
  - Amber: 80-95% of limit
  - Red: 95-100% of limit
  - Error state: Above 100%
- **Real-time Updates**: Counter updates on every keystroke
- **Validation**: Prevent submission if any field exceeds limit

#### 4. Auto-Save Functionality

- **Trigger Conditions**:
  - 2 seconds after last keystroke (debounced)
  - On focus loss (when user clicks away from editor)
  - On section navigation (when user switches sections)
  
- **Save Indicators**:
  - "Saving..." icon with spinner (during save)
  - "Saved" icon with checkmark (successful save)
  - "Error saving" icon with warning (failed save)
  - Timestamp of last save: "Last saved at 14:23"

- **Error Handling**:
  - Retry logic: 3 attempts with exponential backoff
  - Show snackbar error if save fails after retries
  - Keep local state until successful save
  - Allow manual retry via "Save" button

#### 5. Section Completion Tracking

- **Completion Criteria**:
  - All three fields have minimum character count met
  - No validation errors present
  - Successfully saved to backend
  
- **Integration with Designer**:
  - Update section completion status in agency_designer_state.dart
  - Show checkmark/badge in navigation when complete
  - Enable "Next Section" button when complete

#### 6. AI-Powered Content Generation (Future)

*Phase 1: Placeholder UI (This MVP)*
- Show "AI Assist" button (disabled with tooltip "Coming soon")
- Design modal dialog structure for future implementation

*Phase 2: Document Upload (Future MVP)*
- Upload PDF/DOCX documents
- AI extracts background, purpose, scope
- User reviews and accepts/edits generated content

*Phase 3: AI Refinement (Future MVP)*
- Suggest improvements to existing text
- Grammar/spelling corrections
- Clarity enhancements
- SMART criteria alignment

---

## Technical Design

### Architecture

```
views/agency/sections/
  introduction_section.dart        # UI with rich text editors

models/agency/
  introduction_state.dart          # Introduction data model

viewmodels/agency/
  introduction_viewmodel.dart      # Business logic, auto-save

repositories/
  agency_repository.dart           # API integration (update existing)
```

### Data Model

**File**: `lib/models/agency/introduction_state.dart`

```dart
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
}

enum SaveStatus {
  idle,      // No save in progress
  saving,    // Save request in flight
  saved,     // Successfully saved
  error,     // Save failed
}
```

### ViewModel

**File**: `lib/viewmodels/agency/introduction_viewmodel.dart`

```dart
import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/agency/introduction_state.dart';
import '../../repositories/agency_repository.dart';

/// Provider for introduction viewmodel (family by agencyId)
final introductionViewModelProvider = StateNotifierProvider.family<
    IntroductionViewModel,
    IntroductionState,
    String>((ref, agencyId) {
  final repository = ref.watch(agencyRepositoryProvider);
  return IntroductionViewModel(agencyId: agencyId, repository: repository);
});

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
```

### Repository API Integration

**File**: `lib/repositories/agency_repository.dart` (add methods)

```dart
/// Get introduction for an agency
Future<Map<String, dynamic>> getIntroduction(String agencyId) async {
  final response = await _dio.get('/agencies/$agencyId/introduction');
  return response.data;
}

/// Save introduction for an agency
Future<void> saveIntroduction(
  String agencyId, {
  required String background,
  required String purpose,
  required String scope,
}) async {
  await _dio.put('/agencies/$agencyId/introduction', data: {
    'background': background,
    'purpose': purpose,
    'scope': scope,
  });
}
```

### UI Implementation

**File**: `lib/views/agency/sections/introduction_section.dart`

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../viewmodels/agency/introduction_viewmodel.dart';
import '../../../models/agency/introduction_state.dart';

class IntroductionSection extends ConsumerWidget {
  final String agencyId;

  const IntroductionSection({super.key, required this.agencyId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final viewModel = ref.watch(introductionViewModelProvider(agencyId).notifier);
    final state = ref.watch(introductionViewModelProvider(agencyId));

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with save indicator
          Row(
            children: [
              Text(
                'Introduction',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const Spacer(),
              _buildSaveIndicator(context, state),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Define your agency\'s background, purpose, and scope',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
          ),
          const SizedBox(height: 32),

          // Background field
          _RichTextFieldWithCounter(
            label: 'Background',
            hint: 'Describe the context and history that led to this agency\'s creation...',
            value: state.background,
            onChanged: viewModel.updateBackground,
            onFocusLost: viewModel.onFocusLost,
            maxLength: IntroductionState.backgroundLimit,
            minLength: IntroductionState.backgroundMin,
            errorText: state.validationErrors['background'],
            minLines: 5,
            maxLines: 10,
          ),
          const SizedBox(height: 24),

          // Purpose field
          _RichTextFieldWithCounter(
            label: 'Purpose',
            hint: 'Explain why this agency exists and what impact it should have...',
            value: state.purpose,
            onChanged: viewModel.updatePurpose,
            onFocusLost: viewModel.onFocusLost,
            maxLength: IntroductionState.purposeLimit,
            minLength: IntroductionState.purposeMin,
            errorText: state.validationErrors['purpose'],
            minLines: 4,
            maxLines: 8,
          ),
          const SizedBox(height: 24),

          // Scope field
          _RichTextFieldWithCounter(
            label: 'Scope',
            hint: 'Define the boundaries, focus areas, and what is included or excluded...',
            value: state.scope,
            onChanged: viewModel.updateScope,
            onFocusLost: viewModel.onFocusLost,
            maxLength: IntroductionState.scopeLimit,
            minLength: IntroductionState.scopeMin,
            errorText: state.validationErrors['scope'],
            minLines: 4,
            maxLines: 8,
          ),
          const SizedBox(height: 32),

          // AI Assist button (placeholder for future)
          OutlinedButton.icon(
            onPressed: null, // Disabled for now
            icon: const Icon(Icons.auto_awesome),
            label: const Text('AI Assist'),
          ),
        ],
      ),
    );
  }

  Widget _buildSaveIndicator(BuildContext context, IntroductionState state) {
    switch (state.saveStatus) {
      case SaveStatus.saving:
        return Row(
          children: [
            SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              'Saving...',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        );
      case SaveStatus.saved:
        final formattedTime = state.lastSavedAt != null
            ? '${state.lastSavedAt!.hour.toString().padLeft(2, '0')}:${state.lastSavedAt!.minute.toString().padLeft(2, '0')}'
            : '';
        return Row(
          children: [
            Icon(
              Icons.check_circle,
              size: 16,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(width: 8),
            Text(
              'Saved at $formattedTime',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        );
      case SaveStatus.error:
        return Row(
          children: [
            Icon(
              Icons.error_outline,
              size: 16,
              color: Theme.of(context).colorScheme.error,
            ),
            const SizedBox(width: 8),
            Text(
              'Error saving',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.error,
                  ),
            ),
          ],
        );
      case SaveStatus.idle:
        return const SizedBox.shrink();
    }
  }
}

/// Rich text field with character counter
class _RichTextFieldWithCounter extends StatefulWidget {
  final String label;
  final String hint;
  final String value;
  final Function(String) onChanged;
  final VoidCallback onFocusLost;
  final int maxLength;
  final int minLength;
  final String? errorText;
  final int minLines;
  final int maxLines;

  const _RichTextFieldWithCounter({
    required this.label,
    required this.hint,
    required this.value,
    required this.onChanged,
    required this.onFocusLost,
    required this.maxLength,
    required this.minLength,
    this.errorText,
    this.minLines = 3,
    this.maxLines = 10,
  });

  @override
  State<_RichTextFieldWithCounter> createState() =>
      _RichTextFieldWithCounterState();
}

class _RichTextFieldWithCounterState extends State<_RichTextFieldWithCounter> {
  late final TextEditingController _controller;
  late final FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.value);
    _focusNode = FocusNode();
    _focusNode.addListener(() {
      if (!_focusNode.hasFocus) {
        widget.onFocusLost();
      }
    });
  }

  @override
  void didUpdateWidget(_RichTextFieldWithCounter oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.value != _controller.text) {
      _controller.text = widget.value;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  Color _getCounterColor(BuildContext context) {
    final percentage = widget.value.length / widget.maxLength;
    if (percentage >= 1.0) {
      return Theme.of(context).colorScheme.error;
    } else if (percentage >= 0.95) {
      return Colors.red;
    } else if (percentage >= 0.80) {
      return Colors.amber;
    } else {
      return Colors.green;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.label,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _controller,
          focusNode: _focusNode,
          onChanged: widget.onChanged,
          maxLines: widget.maxLines,
          minLines: widget.minLines,
          decoration: InputDecoration(
            hintText: widget.hint,
            errorText: widget.errorText,
            border: const OutlineInputBorder(),
            helperText: 'Minimum ${widget.minLength} characters',
          ),
        ),
        const SizedBox(height: 4),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Text(
              '${widget.value.length} / ${widget.maxLength} characters',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: _getCounterColor(context),
                  ),
            ),
          ],
        ),
      ],
    );
  }
}
```

---

## Backend API Requirements

### Endpoints

```
GET /api/v1/agencies/:id/introduction
PUT /api/v1/agencies/:id/introduction
```

### Data Structure

```go
type AgencyIntroduction struct {
    AgencyID   string    `json:"agency_id" bson:"agency_id"`
    Background string    `json:"background" bson:"background"`
    Purpose    string    `json:"purpose" bson:"purpose"`
    Scope      string    `json:"scope" bson:"scope"`
    UpdatedAt  time.Time `json:"updated_at" bson:"updated_at"`
}
```

### Validation

- Background: 50-2000 characters
- Purpose: 30-1000 characters  
- Scope: 40-1500 characters

---

## Acceptance Criteria

- [ ] Introduction section replaces placeholder with fully functional editor
- [ ] Three rich text fields (Background, Purpose, Scope) with formatting toolbar
- [ ] Character counters display with color coding (green/amber/red)
- [ ] Character limits enforced (prevent exceeding max)
- [ ] Minimum character validation shows error messages
- [ ] Auto-save triggers 2 seconds after last keystroke
- [ ] Auto-save triggers on focus loss
- [ ] Save indicator shows status (saving/saved/error) with timestamp
- [ ] Failed saves retry up to 3 times with exponential backoff
- [ ] Section completion status updates in designer navigation when valid
- [ ] AI Assist button visible but disabled (placeholder for future)
- [ ] Responsive design: works on mobile, tablet, desktop
- [ ] Navigation from designer works correctly
- [ ] State persists when switching between sections
- [ ] `flutter analyze` passes with no new warnings
- [ ] Backend API returns introduction data correctly
- [ ] Backend API saves introduction data correctly

---

## Testing Strategy

### Manual Testing
1. Create new agency and navigate to Introduction section
2. Enter text in each field and verify character counter updates
3. Exceed character limit and verify error state
4. Wait 2 seconds and verify auto-save triggers
5. Click away from field and verify save triggers
6. Kill network connection and verify error state with retry
7. Switch to another section and back, verify data persists
8. Complete all fields validly and verify section marked complete

### Widget Testing
- Character counter color changes at thresholds
- Validation errors display correctly
- Save indicator states (idle/saving/saved/error)
- Text controller synchronization

### Integration Testing  
- Auto-save debounce timing
- Retry logic on network failure
- Section completion state propagation
- Navigation persistence

---

## Implementation Notes

### Phase 1 (This MVP)
- Basic TextField with manual character counting
- Simple auto-save with debouncing
- No rich text formatting yet (add in future MVP)
- AI Assist button disabled (UI placeholder only)

### Phase 2 (Future MVP)
- Add flutter_quill or similar for rich text editing
- Implement bold, italic, lists, links
- Add formatting toolbar
- Document upload for AI generation

### Phase 3 (Future MVP)
- AI-powered content generation from documents
- AI refinement suggestions
- Grammar and spell checking
- SMART criteria alignment

---

## Dependencies

- **flutter_riverpod**: ^2.6.1 (state management)
- **dio**: ^5.7.0 (HTTP client)

*Future*:
- **flutter_quill**: TBD (rich text editor)
- **file_picker**: TBD (document upload)

---

## Estimated Time

- Specification: 1 hour ✅
- State model implementation: 30 minutes
- ViewModel implementation: 1 hour
- UI implementation: 2 hours
- Backend API integration: 30 minutes
- Testing & debugging: 1 hour
- Documentation: 30 minutes

**Total**: ~6.5 hours

---

## Related Tasks

- MVP-FL-103: Agency Designer Navigation (prerequisite)
- MVP-FL-105: Goals Section (next section)
- MVP-FL-106: Work Items Section (future)

---

## References

- [Cortex MVP-025](../../CodeValdCortex/documents/3-SofwareDevelopment/mvp.md) - Original agency introduction specification
- [Agency Designer Architecture](../../2-SoftwareDesignAndArchitecture/flutter-designs/agency-designer-architecture.md)
- [MVVM Pattern](../../2-SoftwareDesignAndArchitecture/flutter-designs/mvvm-pattern.md)
- [Material Design 3 - Text Fields](https://m3.material.io/components/text-fields/overview)
