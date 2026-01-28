# Flutter Design Specifications

This directory contains comprehensive Flutter design specifications for the CodeValdFortex application. Each design document follows the MVVM architecture pattern with Riverpod state management and includes complete widget specifications, data models, responsive layouts, and implementation guidelines.

## Overview

All design specifications follow these principles:
- **MVVM Architecture**: Clear separation of Model, View, and ViewModel layers
- **Component Modularity**: All widgets ≤ 500 lines per file
- **Responsive Design**: Adapts to mobile, tablet, desktop, and wide breakpoints
- **State Management**: Riverpod with ChangeNotifier pattern
- **Material Design 3**: Consistent theming and design tokens
- **Accessibility**: WCAG 2.1 AA compliance

## Design Documents

### Core Application Designs

#### [Dashboard Design](dashboard-design.md)
**Purpose**: Main application dashboard with statistics, metrics, and activity overview  
**Status**: ✅ Complete  
**Key Features**:
- Responsive grid layout with stat cards and charts
- Real-time metrics and activity feed
- Quick actions and navigation
- Multi-breakpoint adaptive layout (mobile/tablet/desktop)

**Widget Components**:
- `DashboardView` - Main dashboard screen
- `StatCard` - Statistics display with trends
- `MetricCard` - Key performance indicators
- `ChartCard` - Data visualization container
- `ActivityFeed` - Recent activity timeline

**Related MVP Tasks**: MVP-FL-008A, MVP-FL-008B

---

#### [Sign-In Design](sign-in-design.md)
**Purpose**: Authentication interface with dual login methods  
**Status**: ✅ Complete  
**Key Features**:
- Email/password authentication
- OAuth social login (Google, GitHub)
- Password reset flow
- Remember me functionality
- Form validation with error states

**Widget Components**:
- `SignInView` - Main authentication screen
- `SignInForm` - Email/password form
- `SocialLoginButtons` - OAuth provider buttons
- `PasswordResetDialog` - Password recovery

**Related MVP Tasks**: MVP-FL-009, MVP-FL-010

---

#### [Task Management Design](task-management-design.md)
**Purpose**: Task creation, tracking, and workflow management  
**Status**: ✅ Complete  
**Key Features**:
- Task list with filtering and sorting
- Task detail view with edit capability
- Kanban board layout
- Task assignment and status updates
- Subtask and checklist management

**Widget Components**:
- `TaskListView` - Task list with filters
- `TaskCard` - Individual task display
- `TaskDetailView` - Task detail and edit
- `KanbanBoard` - Drag-and-drop task board
- `TaskForm` - Task creation/editing form

**Related MVP Tasks**: MVP-FL-007, MVP-FL-008

---

#### [File Manager Design](file-manager-design.md)
**Purpose**: Document and workflow artifact management interface  
**Status**: ✅ Complete  
**Created**: 2026-01-28  
**Key Features**:
- Hierarchical folder structure with categories
- Dual view modes: folder cards grid + file table
- Search and filter capabilities (file type, date, owner)
- File operations: upload, download, share, delete, favorite
- User collaboration with shared file indicators
- Responsive sidebar navigation

**Widget Components**:
- `FileManagerView` - Main file manager layout
- `FileManagerSidebar` - Category navigation and storage info
- `FolderCardGrid` - Grid view of folders
- `FileTable` - Detailed file list with sorting
- `FileTableRow` - Individual file row with actions
- `AvatarGroup` - Collaborator avatars
- `FileActionsMenu` - File operation dropdown

**Data Models**:
- `FileItem` - Individual file metadata
- `FolderItem` - Folder information
- `UserInfo` - User/owner details
- `FileCategory` - Navigation categories (My Files, Shared, Recent, Favorites, etc.)
- `FileSortOption` - Sort configurations

**Use Cases**:
- Workflow artifact storage and organization
- Team collaboration on documents
- Project documentation repository
- Media library management

**Related Features**: Workflow artifacts viewer, document management, team collaboration

---

### Reusable Pattern Library

#### [Design Patterns](design-patterns.md)
**Purpose**: Common reusable widget patterns and components  
**Status**: ✅ Complete  
**Key Patterns**:
- `StatCard` - Statistics display with icon, value, label, trend indicator
- `MetricCard` - KPI cards with comparison and progress
- `ChartCard` - Container for data visualizations
- `DataListCard` - List display with pagination
- `UserAvatar` - User profile images with badges
- `StatusBadge` - Status indicators with colors
- `ActionButton` - Consistent action buttons
- `LoadingState` - Loading placeholders and skeletons

**Guidelines**:
- Component composition over monolithic widgets
- Consistent spacing (8px grid system)
- Material Design 3 theming
- Responsive behavior patterns

---

## Design Document Structure

Each design specification follows this standard structure:

1. **Overview**: Purpose, features, design principles, component splitting strategy
2. **Architecture Pattern**: MVVM diagram and data flow
3. **Data Models**: Complete Dart model classes with JSON serialization
4. **Widget Component Hierarchy**: Tree structure showing relationships
5. **Detailed Widget Specifications**: Code examples for each major widget
6. **ViewModel Architecture**: State management and business logic
7. **Riverpod Provider Setup**: Provider definitions and dependencies
8. **View Implementation**: Main view widgets and layout builders
9. **Responsive Design**: Breakpoint definitions and layout adaptations
10. **File Structure**: Complete directory organization
11. **Required Packages**: Dependencies with versions and purposes
12. **Theme Configuration**: Color schemes, typography, design tokens
13. **API Integration**: Repository patterns and API client methods
14. **Implementation Notes**: Special considerations, performance, accessibility
15. **Usage Example**: Complete runnable examples
16. **Related Documents**: Cross-references to other design docs

## Design Tokens

### Spacing System (8px Grid)
- `spacing4`: 4px
- `spacing8`: 8px  
- `spacing12`: 12px
- `spacing16`: 16px
- `spacing24`: 24px
- `spacing32`: 32px

### Breakpoints
- **Mobile**: < 600px (single column, simplified UI)
- **Tablet**: 600-899px (two columns, expanded UI)
- **Desktop**: 900-1199px (multi-column, full features)
- **Wide**: ≥ 1200px (maximum columns, spacious layout)

### Border Radius
- `radiusSmall`: 4px
- `radiusMedium`: 8px
- `radiusLarge`: 12px
- `radiusRound`: 50% (circular)

### Icon Sizes
- `iconSmall`: 16px
- `iconMedium`: 20px
- `iconLarge`: 24px
- `iconXLarge`: 32px

## Package Dependencies

### Core State Management
- `flutter_riverpod`: ^2.4.9 - State management
- `freezed`: ^2.4.5 - Immutable models
- `json_serializable`: ^6.7.1 - JSON serialization

### UI Components
- `cached_network_image`: ^3.3.0 - Image loading with cache
- `flutter_svg`: ^2.0.9 - SVG icon support
- `fl_chart`: ^0.66.0 - Charts and data visualization
- `badges`: ^3.1.2 - Notification badges

### Utilities
- `intl`: ^0.18.1 - Date/time formatting
- `go_router`: ^13.0.0 - Navigation
- `dio`: ^5.4.0 - HTTP client

## Widget Size Guidelines

**CRITICAL**: All widget files MUST be ≤ 500 lines to maintain:
- Code readability and maintainability
- Single responsibility principle
- Easy testing and debugging
- Better code organization

### Splitting Strategy
When a widget exceeds 500 lines:
1. Extract build helper methods into separate widgets
2. Group related sub-widgets in dedicated files
3. Create a barrel file (`index.dart`) for imports
4. Document the component hierarchy

Example:
```
lib/widgets/complex_feature/
├── complex_widget.dart        # Main widget (< 500 lines)
├── complex_widget_header.dart # Extracted header
├── complex_widget_content.dart # Extracted content
├── complex_widget_footer.dart # Extracted footer
└── index.dart                 # Barrel export
```

## Integration with MVP Tasks

Design specifications are referenced by MVP implementation tasks:

| Design Document | Related MVP Tasks |
|-----------------|-------------------|
| dashboard-design.md | MVP-FL-008A, MVP-FL-008B |
| sign-in-design.md | MVP-FL-009, MVP-FL-010 |
| task-management-design.md | MVP-FL-007, MVP-FL-008 |
| file-manager-design.md | Future: Workflow artifacts viewer |
| design-patterns.md | All widget-building tasks |

## Creating New Design Specifications

When creating a new design document, use the [HTML to Flutter Design Conversion Prompt](../../../.github/prompts/html-to-flutter-design.prompt.md) for guidance. The prompt ensures:

- Complete MVVM architecture specification
- Responsive design patterns
- Widget size compliance (≤ 500 lines)
- API integration patterns
- Accessibility features
- Testing strategies

## Next Steps

### Upcoming Design Work
- Agent Management Interface
- Workflow Builder
- Real-time Collaboration Features
- Settings & Configuration Screens
- Notification Center

### Design System Enhancements
- Animation guidelines
- Micro-interactions library
- Accessibility patterns
- Performance optimization guides
- Testing patterns and mocks

---

**Last Updated**: 2026-01-28  
**Maintained By**: CodeVald Development Team  
**Related Documentation**:
- [MVP Task Tracking](../../3-SofwareDevelopment/mvp.md)
- [State Management Architecture](../state-management.md)
- [Coding Sessions](../../3-SofwareDevelopment/coding_sessions/)
