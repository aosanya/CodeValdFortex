# MVP-FL-103: Agency Designer Navigation

## Overview
**Priority**: P0  
**Effort**: Medium  
**Skills**: Flutter, Dart, Routing, State Management, Responsive Design  
**Dependencies**: MVP-FL-102 (Create Agency Form)

Build the Agency Designer shell with tab-based navigation for 8 core sections (Introduction, Goals, Work Items, Roles, RACI Matrix, Workflows, Policy, Admin). This provides the navigation framework and layout structure for configuring agencies. Users navigate from agency creation to this designer view where they can build out their complete agency specification across multiple sections.

## Requirements

### Functional Requirements
1. **Navigation Structure**
   - Display 8 section tabs: Introduction, Goals, Work Items, Roles, RACI Matrix, Workflows, Policy, Admin
   - Allow switching between sections via tab navigation
   - Persist selected tab state during session
   - Show current active section with visual indicator

2. **Section Completion Tracking**
   - Display completion indicators (checkmark/icon) for completed sections
   - Track completion state per section (not started, in progress, complete)
   - Visual differentiation between section states

3. **Progress Persistence**
   - Auto-save or manual save progress across sections
   - Handle navigation away without losing work
   - Warn user of unsaved changes before leaving

4. **Responsive Layout**
   - **Desktop (>900px)**: Horizontal tab bar or navigation rail
   - **Tablet (600-900px)**: Horizontal scrollable tab bar
   - **Mobile (<600px)**: Dropdown selector or drawer navigation
   - Adapt layout based on screen width

5. **Section Placeholder Views**
   - Create placeholder widget for each of the 8 sections
   - Display section title and description
   - Show "Coming soon" or "Under development" state
   - Prepare structure for future implementation

## Technical Specifications

### Architecture
**Pattern**: MVVM with Riverpod state management

**File Structure**:
```
lib/
├── models/
│   └── agency/
│       ├── agency_designer_state.dart      # Designer navigation state
│       └── section_completion_state.dart   # Track section completion
├── viewmodels/
│   └── agency/
│       └── agency_designer_viewmodel.dart  # Navigation & state logic
├── views/
│   └── agency/
│       ├── agency_designer_view.dart       # Main designer shell
│       └── sections/
│           ├── introduction_section.dart
│           ├── goals_section.dart
│           ├── work_items_section.dart
│           ├── roles_section.dart
│           ├── raci_matrix_section.dart
│           ├── workflows_section.dart
│           ├── policy_section.dart
│           └── admin_section.dart
└── config/
    └── router.dart                          # Add designer route
```

### Design References
- **Navigation Pattern**: See `dashboard-design.md` sections 2-3 for AppBar and Sidebar patterns
- **Responsive Layout**: See `dashboard-design.md` section 6 for breakpoints and MediaQuery usage
- **Widget Component Structure**: See `design-patterns.md` for reusable patterns
- **State Management**: See MVP-FL-004 details for Riverpod MVVM architecture

### Implementation Details

#### 1. AgencyDesignerState Model
```dart
class AgencyDesignerState {
  final String agencyId;
  final String agencyName;
  final DesignerSection activeSection;
  final Map<DesignerSection, SectionCompletionStatus> sectionCompletion;
  final bool hasUnsavedChanges;
  final bool isSaving;
  
  const AgencyDesignerState({
    required this.agencyId,
    required this.agencyName,
    this.activeSection = DesignerSection.introduction,
    this.sectionCompletion = const {},
    this.hasUnsavedChanges = false,
    this.isSaving = false,
  });
}

enum DesignerSection {
  introduction,
  goals,
  workItems,
  roles,
  raciMatrix,
  workflows,
  policy,
  admin
}

enum SectionCompletionStatus {
  notStarted,
  inProgress,
  complete
}
```

#### 2. AgencyDesignerViewModel
```dart
class AgencyDesignerViewModel extends StateNotifier<AgencyDesignerState> {
  final AgencyRepository _repository;
  
  AgencyDesignerViewModel(this._repository, String agencyId, String agencyName)
      : super(AgencyDesignerState(agencyId: agencyId, agencyName: agencyName));
  
  // Switch to a different section
  void navigateToSection(DesignerSection section) {
    state = state.copyWith(activeSection: section);
  }
  
  // Mark section as complete
  void markSectionComplete(DesignerSection section) {
    final updatedCompletion = Map<DesignerSection, SectionCompletionStatus>.from(
      state.sectionCompletion
    );
    updatedCompletion[section] = SectionCompletionStatus.complete;
    
    state = state.copyWith(sectionCompletion: updatedCompletion);
  }
  
  // Save all progress
  Future<void> saveProgress() async {
    state = state.copyWith(isSaving: true);
    
    try {
      // TODO: Implement API call to save designer state
      await Future.delayed(Duration(seconds: 1)); // Placeholder
      
      state = state.copyWith(
        isSaving: false,
        hasUnsavedChanges: false,
      );
    } catch (e) {
      state = state.copyWith(isSaving: false);
      rethrow;
    }
  }
}
```

#### 3. AgencyDesignerView Widget
```dart
class AgencyDesignerView extends ConsumerWidget {
  final String agencyId;
  
  const AgencyDesignerView({super.key, required this.agencyId});
  
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final designerState = ref.watch(agencyDesignerViewModelProvider(agencyId));
    
    return Scaffold(
      appBar: AppBar(
        title: Text(designerState.agencyName),
        actions: [
          // Save button
          IconButton(
            icon: designerState.isSaving
                ? CircularProgressIndicator()
                : Icon(Icons.save),
            onPressed: designerState.isSaving
                ? null
                : () => ref.read(agencyDesignerViewModelProvider(agencyId).notifier)
                    .saveProgress(),
          ),
        ],
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          // Responsive layout switching
          if (constraints.maxWidth > 900) {
            return _buildDesktopLayout(context, ref, designerState);
          } else if (constraints.maxWidth > 600) {
            return _buildTabletLayout(context, ref, designerState);
          } else {
            return _buildMobileLayout(context, ref, designerState);
          }
        },
      ),
    );
  }
  
  Widget _buildDesktopLayout(
    BuildContext context,
    WidgetRef ref,
    AgencyDesignerState state,
  ) {
    return Row(
      children: [
        // Vertical navigation rail
        NavigationRail(
          selectedIndex: DesignerSection.values.indexOf(state.activeSection),
          onDestinationSelected: (index) {
            ref.read(agencyDesignerViewModelProvider(agencyId).notifier)
                .navigateToSection(DesignerSection.values[index]);
          },
          destinations: _buildNavigationDestinations(state),
        ),
        // Main content area
        Expanded(
          child: _buildSectionContent(state.activeSection),
        ),
      ],
    );
  }
  
  Widget _buildTabletLayout(
    BuildContext context,
    WidgetRef ref,
    AgencyDesignerState state,
  ) {
    return Column(
      children: [
        // Horizontal scrollable tab bar
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: _buildTabButtons(context, ref, state),
          ),
        ),
        Expanded(
          child: _buildSectionContent(state.activeSection),
        ),
      ],
    );
  }
  
  Widget _buildMobileLayout(
    BuildContext context,
    WidgetRef ref,
    AgencyDesignerState state,
  ) {
    return Column(
      children: [
        // Dropdown selector
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: DropdownButton<DesignerSection>(
            value: state.activeSection,
            isExpanded: true,
            items: DesignerSection.values.map((section) {
              return DropdownMenuItem(
                value: section,
                child: Row(
                  children: [
                    _getSectionIcon(section, state),
                    SizedBox(width: 8),
                    Text(_getSectionTitle(section)),
                  ],
                ),
              );
            }).toList(),
            onChanged: (section) {
              if (section != null) {
                ref.read(agencyDesignerViewModelProvider(agencyId).notifier)
                    .navigateToSection(section);
              }
            },
          ),
        ),
        Expanded(
          child: _buildSectionContent(state.activeSection),
        ),
      ],
    );
  }
}
```

#### 4. Responsive Breakpoints
```dart
class Breakpoints {
  static const double mobile = 600;
  static const double tablet = 900;
  static const double desktop = 1200;
  
  static bool isMobile(BuildContext context) =>
      MediaQuery.of(context).size.width < mobile;
  
  static bool isTablet(BuildContext context) =>
      MediaQuery.of(context).size.width >= mobile &&
      MediaQuery.of(context).size.width < desktop;
  
  static bool isDesktop(BuildContext context) =>
      MediaQuery.of(context).size.width >= desktop;
}
```

#### 5. Section Placeholder Widgets
Each section widget should follow this template:

```dart
class IntroductionSection extends StatelessWidget {
  const IntroductionSection({super.key});
  
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.info_outline,
            size: 64,
            color: Theme.of(context).colorScheme.primary,
          ),
          SizedBox(height: 16),
          Text(
            'Introduction',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          SizedBox(height: 8),
          Text(
            'Configure agency overview, purpose, and objectives',
            style: Theme.of(context).textTheme.bodyLarge,
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 24),
          OutlinedButton.icon(
            onPressed: () {
              // TODO: Implement introduction configuration
            },
            icon: Icon(Icons.edit),
            label: Text('Configure Introduction'),
          ),
        ],
      ),
    );
  }
}
```

### Required Packages
```yaml
dependencies:
  flutter_riverpod: ^2.6.1
  go_router: ^15.0.1
  equatable: ^2.0.7
```

### Routing Configuration
Add designer route to router.dart:

```dart
GoRoute(
  path: '/agencies/:id/designer',
  name: 'agency-designer',
  builder: (context, state) {
    final id = state.pathParameters['id']!;
    return AgencyDesignerView(agencyId: id);
  },
),
```

## Acceptance Criteria

- [ ] Agency Designer view displays with proper agency name in app bar
- [ ] All 8 sections are accessible via navigation (Introduction, Goals, Work Items, Roles, RACI Matrix, Workflows, Policy, Admin)
- [ ] Desktop layout (>900px) shows vertical NavigationRail on left side
- [ ] Tablet layout (600-900px) shows horizontal scrollable tab bar
- [ ] Mobile layout (<600px) shows dropdown section selector
- [ ] Active section is visually highlighted in navigation
- [ ] Section completion indicators show proper status (not started, in progress, complete)
- [ ] Save button in app bar triggers save progress action
- [ ] Save button shows loading state while saving
- [ ] Each section placeholder displays proper icon, title, and description
- [ ] Navigation state persists when switching between sections
- [ ] No console errors or warnings in browser console
- [ ] `flutter analyze` passes with no errors
- [ ] Responsive layout switches properly at breakpoints (600px, 900px)
- [ ] Route `/agencies/:id/designer` navigates to designer view correctly

## Testing Requirements

### Manual Testing
1. **Navigation Testing**
   - Create agency and navigate to designer
   - Test all 8 section tabs
   - Verify active section highlighting
   - Test back navigation to agency list

2. **Responsive Testing**
   - Test at desktop width (>900px) - verify NavigationRail
   - Test at tablet width (600-900px) - verify horizontal tabs
   - Test at mobile width (<600px) - verify dropdown
   - Resize browser window and verify layout adapts

3. **State Persistence**
   - Switch between sections
   - Verify no data loss when navigating
   - Test save functionality

### Widget Tests
```dart
testWidgets('Agency designer displays all sections', (tester) async {
  await tester.pumpWidget(
    ProviderScope(
      child: MaterialApp(
        home: AgencyDesignerView(agencyId: 'test-agency-id'),
      ),
    ),
  );
  
  // Verify all section names appear
  expect(find.text('Introduction'), findsOneWidget);
  expect(find.text('Goals'), findsOneWidget);
  expect(find.text('Work Items'), findsOneWidget);
  // ... test other sections
});
```

## Implementation Notes

1. **Placeholder Sections**: This task focuses on navigation shell. Individual section implementations (Introduction content, Goals CRUD, etc.) will be separate tasks (MVP-FL-104+)

2. **Completion Tracking**: Initially, all sections will be "not started". Future tasks will implement logic to mark sections as in-progress or complete based on data.

3. **Save Functionality**: Initial save will be a no-op placeholder. Future tasks will implement actual API calls to persist designer state.

4. **Design Consistency**: Follow Material Design 3 guidelines, use theme colors, maintain consistent spacing (8px grid).

5. **Accessibility**: Ensure proper semantic labels, keyboard navigation support, screen reader compatibility.

## Related Tasks
- **Depends on**: MVP-FL-102 (Create Agency Form) - provides navigation entry point
- **Enables**: 
  - MVP-FL-104: Introduction Section Implementation
  - MVP-FL-105: Goals Section Implementation
  - MVP-FL-106: Work Items Section Implementation
  - And subsequent section implementation tasks

## Design References
- Dashboard navigation: `/documents/2-SoftwareDesignAndArchitecture/flutter-designs/dashboard-design.md`
- Widget patterns: `/documents/2-SoftwareDesignAndArchitecture/flutter-designs/design-patterns.md`
- MVVM architecture: `/documents/3-SofwareDevelopment/mvp-details/MVP-FL-004.md`
