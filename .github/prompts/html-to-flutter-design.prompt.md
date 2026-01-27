# HTML to Flutter Design Conversion Prompt

**Purpose:** Analyze HTML template designs and create comprehensive Flutter architecture documentation in the `/workspaces/CodeValdFortex/documents/2-SoftwareDesignAndArchitecture/flutter-designs/` folder.

**Project Context:** CodeValdFortex is a Flutter cross-platform frontend (Web primary, iOS, Android, Desktop) for the CodeVald platform, following MVVM architecture with Riverpod state management.

---

## Instructions

When I provide an HTML template, analyze its design patterns, components, and user interface structure, then create a comprehensive Flutter design specification document.

### Input Format

I will provide:
1. **HTML Template**: Complete HTML markup (may include inline CSS or references to external stylesheets)
2. **Template Purpose**: Brief description of what the template is for (e.g., "dashboard", "task management", "user profile")
3. **Design Name**: Name for the Flutter design document (e.g., "dashboard-design.md", "task-management-design.md")

### Output Format

Create a Markdown file in `/workspaces/CodeValdFortex/documents/2-SoftwareDesignAndArchitecture/flutter-designs/` with the following structure:

```markdown
# [Component Name] - Flutter Design Specification

**Document Version:** 1.0  
**Last Updated:** [Current Date]  
**Target Platforms:** Web (Primary), iOS, Android, Desktop  
**Reference:** [HTML Template Name/Source]

## 1. Overview
- Purpose and key features
- Design principles (emphasize component modularity)
- Target use cases
- Component splitting strategy (if needed)

### Component Size Guidelines
**Critical:** All widget files MUST be ≤ 500 lines. Split into multiple files if needed:
- Extract sub-widgets into separate files
- Create widget composition hierarchies
- Use barrel files (index.dart) to export related widgets

## 2. Architecture Pattern: MVVM
- Structure diagram
- Component layers
- Data flow

## 3. Data Models
- Complete Dart model classes with:
  - Properties and types
  - Constructors
  - fromJson/toJson methods
  - Enums for status/categories
- Example models from HTML structure

## 4. Widget Component Hierarchy
- Tree structure showing parent-child relationships
- Main layout breakdown
- Responsive layout variations

## 5. Detailed Widget Specifications
For each major widget:
- File location (lib/widgets/...)
- **File size check**: Ensure ≤ 500 lines; split if needed
- Complete Dart code structure (with splitting annotations)
- Properties and callbacks
- Build method implementation
- Sub-widget extraction strategy
- Responsive behavior
- Usage examples

### Widget Splitting Strategy
When a widget exceeds 500 lines:
1. Extract build helper methods into separate widgets
2. Group related sub-widgets in dedicated files
3. Create a barrel file for imports
4. Document the component hierarchy

## 6. ViewModel Architecture
- ViewModel class structure
- State properties
- Business logic methods
- Data transformations
- Error handling

## 7. Riverpod Provider Setup
- Provider definitions
- Selector providers
- Dependencies

## 8. View Implementation
- Main view widget
- Layout builders
- Event handlers
- Navigation

## 9. Responsive Design
- Breakpoint definitions
- Layout adaptations table
- ResponsiveBuilder patterns

## 10. File Structure
- Complete directory tree
- File naming conventions
- Component splitting examples (for widgets > 500 lines)

### Example Split Structure
```
lib/widgets/tasks/
├── task_card/                    # Complex widget split
│   ├── task_card.dart           # Main widget (< 500 lines)
│   ├── task_card_header.dart    # Extracted header
│   ├── task_card_content.dart   # Extracted content
│   ├── task_card_footer.dart    # Extracted footer
│   └── index.dart               # Barrel export
├── user_avatar_with_badge.dart  # Simple widget (< 500 lines)
└── task_status_badge.dart       # Simple widget (< 500 lines)
```

## 11. Required Packages
- Dependencies list with versions
- Package purposes

## 12. Theme Configuration
- Color schemes
- Typography
- Component themes
- Design tokens

## 13. API Integration
- Repository patterns
- API client methods
- Data mapping

## 14. Implementation Notes
- Special considerations
- Performance optimizations
- Accessibility features
- Testing strategies

## 15. Usage Example
- Complete runnable example
- Integration points

## 16. Related Documents
- Links to other design docs
- MVP task references
```

### Analysis Guidelines

When analyzing HTML templates:

1. **Identify UI Components**
   - Cards, buttons, forms, tables, charts
   - Navigation elements (sidebar, tabs, breadcrumbs)
   - Data display patterns (lists, grids, cards)
   - Interactive elements (dropdowns, modals, tooltips)

2. **Extract Design Patterns**
   - Layout structure (flex, grid, columns)
   - Spacing and alignment
   - Color schemes and themes
   - Typography hierarchy
   - Icon usage

3. **Map to Flutter Widgets**
   - HTML divs → Container/Column/Row
   - HTML cards → Card widget
   - HTML buttons → ElevatedButton/TextButton/OutlinedButton
   - HTML forms → Form with TextFormField
   - HTML tables → DataTable/ListView
   - HTML badges → Badge widget
   - HTML avatars → CircleAvatar
   - HTML dropdowns → DropdownButton/PopupMenuButton

4. **Identify State Requirements**
   - User input states
   - Loading states
   - Error states
   - Selected/active states
   - Filtered/sorted data

5. **Plan Responsive Behavior**
   - Mobile breakpoint (< 600px): Single column, simplified UI
   - Tablet breakpoint (600-899px): Two columns, expanded UI
   - Desktop breakpoint (900-1199px): Multi-column, full features
   - Wide breakpoint (≥ 1200px): Maximum columns, spacious layout

6. **Design for Modularity (500-Line Rule)**
   - Estimate widget complexity from HTML structure
   - Plan component splits BEFORE writing code
   - Identify natural boundaries (header, content, footer, actions)
   - Group related sub-widgets in feature folders
   - Document splitting strategy in widget specifications

7. **Define Data Flow**
   - User actions → ViewModel methods
   - API calls → Repository → ViewModel state
   - State changes → UI updates via notifyListeners
   - Navigation flows

### Flutter Best Practices

Apply these Flutter patterns in your design:

1. **MVVM Architecture**
   - Views are StatelessWidget (consume state)
   - ViewModels extend ChangeNotifier (manage state)
   - Models are immutable data classes
   - Repositories handle data operations

2. **State Management (Riverpod)**
   ```dart
   final viewModelProvider = ChangeNotifierProvider<MyViewModel>((ref) {
     return MyViewModel(repository: ref.read(repositoryProvider));
   });
   ```

3. **Responsive Design**
   ```dart
   ResponsiveBuilder(
     mobile: MobileLayout(),
     tablet: TabletLayout(),
     desktop: DesktopLayout(),
   )
   ```

4. **Widget Composition**
   - Create small, reusable widgets (≤ 500 lines each)
   - Use const constructors where possible
   - Extract repeated patterns into custom widgets
   - Split complex widgets: extract _buildX() methods into separate widget files
   - Organize split widgets in feature folders with barrel exports

5. **Theme Integration**
   ```dart
   Theme.of(context).colorScheme.primary
   Theme.of(context).textTheme.titleLarge
   ```

### File Naming Conventions

- Design documents: `[feature]-design.md` (kebab-case)
- Widget files: `[widget_name].dart` (snake_case)
- ViewModel files: `[feature]_viewmodel.dart`
- Model files: `[model_name]_model.dart`
- View files: `[feature]_view.dart`

### Package Recommendations

Include relevant packages based on HTML features:

- **fl_chart**: For charts and data visualization
- **data_table_2**: For advanced tables
- **badges**: For notification badges
- **responsive_framework**: For responsive layouts
- **go_router**: For navigation
- **dio**: For HTTP requests
- **cached_network_image**: For image loading
- **flutter_svg**: For SVG icons
- **intl**: For date/time formatting
- **shimmer**: For loading placeholders

### Quality Standards

Ensure your design documents:

1. **Completeness**: Cover all UI elements from the HTML template
2. **Code Quality**: Provide production-ready Dart code examples
3. **Clarity**: Use clear descriptions and comments
4. **Consistency**: Follow existing design pattern conventions
5. **Reusability**: Design for component reuse across features
6. **Accessibility**: Include WCAG 2.1 AA considerations
7. **Performance**: Note optimization strategies
8. **Modularity**: **CRITICAL** - Design ALL widgets to be ≤ 500 lines per file
   - Proactively split large widgets during design phase
   - Document component hierarchy for split widgets
   - Use composition over monolithic components
   - Create dedicated folders for complex features with multiple files

### Example Session

**User Input:**
```
HTML Template: [Provides HTML for a user profile page]
Purpose: User profile management with avatar, bio, statistics, and edit functionality
Design Name: user-profile-design.md
```

**Your Response:**
Create `/workspaces/CodeValdFortex/documents/2-SoftwareDesignAndArchitecture/flutter-designs/user-profile-design.md` containing:

- Overview of profile management features
- UserProfileModel with properties (id, name, avatar, bio, stats)
- Widget hierarchy: ProfileView → ProfileHeader → ProfileStats → ProfileActions
- ProfileViewModel with methods: loadProfile(), updateProfile(), uploadAvatar()
- Responsive layout: mobile stacked, desktop two-column
- Theme configuration for profile cards and buttons
- API integration for profile CRUD operations
- Complete code examples for each widget

### Integration with Existing Architecture

Reference and align with existing design documents:

1. **Dashboard Design** (`dashboard-design.md`): Main layout patterns, navigation structure
2. **Design Patterns** (`design-patterns.md`): Reusable widget components
3. **Task Management Design** (`task-management-design.md`): Card patterns, user avatars, status badges

Ensure consistency in:
- Color scheme usage
- Typography scale
- Spacing system (8px grid)
- Breakpoint values
- State management patterns
- File organization

### Special Considerations

1. **HTML Classes to Flutter Themes**
   - Bootstrap classes → Material Design equivalents
   - Custom CSS → ThemeData extensions
   - CSS variables → Design tokens in Dart

2. **JavaScript Interactions to Flutter Logic**
   - onClick handlers → onTap callbacks
   - Form validation → TextFormField validators
   - AJAX calls → async ViewModel methods
   - DOM manipulation → State updates

3. **Complex HTML Structures**
   - Nested divs → Column/Row combinations or Stack
   - Absolute positioning → Stack with Positioned
   - Flex layouts → Expanded/Flexible widgets
   - Grid systems → GridView or responsive Column/Row

4. **Animation and Transitions**
   - CSS transitions → AnimatedContainer, AnimatedOpacity
   - CSS animations → AnimationController with Tween
   - Page transitions → PageRouteBuilder

### Output Validation

Before finalizing the design document, verify:

- [ ] All HTML UI elements have Flutter equivalents
- [ ] Data models match the information displayed in HTML
- [ ] ViewModel methods cover all user interactions
- [ ] Responsive behavior is defined for all breakpoints
- [ ] Code examples compile without errors
- [ ] **ALL widget files are ≤ 500 lines (with splitting strategy if needed)**
- [ ] File structure follows project conventions
- [ ] Complex widgets are split with barrel exports documented
- [ ] Required packages are listed with versions
- [ ] Theme configuration is complete
- [ ] API integration patterns are specified
- [ ] Related documents are cross-referenced

### Continuous Improvement

After creating each design document:

1. Update the main architecture index if needed
2. Cross-reference related design documents
3. Update MVP tasks to reference the new design
4. Note any new reusable patterns for design-patterns.md
5. Update package dependencies in the main documentation

---

## Quick Reference

### Common HTML → Flutter Mappings

| HTML Element | Flutter Widget |
|--------------|----------------|
| `<div>` | Container, Column, Row |
| `<span>` | Text |
| `<button>` | ElevatedButton, TextButton |
| `<input>` | TextField, TextFormField |
| `<select>` | DropdownButton |
| `<img>` | Image, CircleAvatar |
| `<a>` | TextButton, InkWell |
| `<ul>/<ol>` | ListView |
| `<table>` | DataTable, Table |
| `<form>` | Form |
| `<header>` | AppBar |
| `<nav>` | NavigationBar, Drawer |
| `<section>` | Card, Container |

### Bootstrap → Material Design

| Bootstrap | Material Design |
|-----------|----------------|
| `.btn-primary` | ElevatedButton with primary color |
| `.btn-outline` | OutlinedButton |
| `.card` | Card widget |
| `.badge` | Badge widget |
| `.alert` | SnackBar, AlertDialog |
| `.modal` | Dialog, showModalBottomSheet |
| `.navbar` | AppBar, BottomNavigationBar |
| `.container` | Container with constraints |
| `.row`/`.col` | Row/Column with Expanded |

### Design Token Mapping

```dart
// Spacing (Bootstrap uses rem, Flutter uses logical pixels)
bootstrap: mb-3 (1rem = 16px)
flutter: SizedBox(height: 16)

// Colors
bootstrap: bg-primary, text-danger
flutter: Theme.of(context).colorScheme.primary
        Theme.of(context).colorScheme.error

// Typography
bootstrap: fs-14, fw-semibold
flutter: Theme.of(context).textTheme.bodyMedium
        .copyWith(fontWeight: FontWeight.w600)

// Borders
bootstrap: border rounded
flutter: BoxDecoration(
          border: Border.all(color: Colors.grey),
          borderRadius: BorderRadius.circular(4),
        )
```

---

## Ready to Start

I'm ready to analyze HTML templates and create comprehensive Flutter design specifications. Provide the HTML template, its purpose, and desired design document name to begin.
