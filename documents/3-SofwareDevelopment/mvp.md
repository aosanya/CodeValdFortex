# MVP - Minimum Viable Product Task Breakdown (Frontend)

## Task Overview
- **Objective**: Build modern Flutter cross-platform application for CodeVald platform providing seamless user experience for agency management, work items, and agent orchestration on Web, iOS, Android, and Desktop
- **Success Criteria**: Production-ready Flutter application with core features that integrates with CodeValdCortex backend APIs
- **Dependencies**: Backend REST APIs from CodeValdCortex, Material Design widgets, state management architecture (Riverpod/Bloc)

## Documentation Structure
- **High-Level Overview**: This file (`mvp.md`) provides task tables, priorities, dependencies, and brief descriptions
- **Detailed Specifications**: Each task with detailed requirements is documented in `/documents/3-SofwareDevelopment/mvp-details/{TASK_ID}.md`
- **Reference Pattern**: Tasks reference their detail files using the format `See: mvp-details/{TASK_ID}.md`
- **Design Architecture**: Flutter design specifications are located in `/documents/2-SoftwareDesignAndArchitecture/flutter-designs/`
  - `dashboard-design.md`: Complete dashboard architecture, MVVM pattern, widget specs, responsive layouts
  - `design-patterns.md`: Reusable widget patterns (StatCard, MetricCard, ChartCard, DataTable)
  - `sign-in-design.md`: Authentication UI specifications with dual login methods
  - Tasks reference these design specs for implementation guidance

## Workflow Integration

### Task Management Process
1. **Task Assignment**: Pick tasks based on priority (P0 first) and dependencies
2. **Implementation**: Update "Status" column as work progresses (Not Started → In Progress → Testing → Complete)
3. **Completion Process** (MANDATORY):
   - Create detailed coding session document in `coding_sessions/` using format: `{TaskID}_{description}.md`
   - Add completed task to summary table in `mvp_done.md` with completion date
   - Remove completed task from this active `mvp.md` file
   - Update any dependent task references
   - Merge feature branch to main
4. **Dependencies**: Ensure prerequisite tasks are completed before starting dependent work

### Branch Management (MANDATORY)
```bash
# Create feature branch
git checkout -b feature/MVP-XXX_description

# Work, build validation, test
# ... development work ...

# Merge when complete and tested
git checkout main
git merge feature/MVP-XXX_description --no-ff
git branch -d feature/MVP-XXX_description
```

---

## Status Legend
- ✅ **Completed** - Task done, merged to main (see `mvp_done.md`)
- 🚀 **In Progress** - Currently being worked on
- 📋 **Not Started** - Ready to begin (dependencies met)
- ⏸️ **Blocked** - Waiting on dependencies
- ⚠️ **Deprecated** - Superseded by other work

---

## P0: Foundation & Infrastructure (CRITICAL)

*Core architecture, build system, and development environment*

| Task ID | Title | Description | Status | Priority | Effort | Skills | Dependencies | Details |
|---------|-------|-------------|--------|----------|--------|--------|--------------|---------|
| MVP-FL-002 | Design System Setup | Configure Material Design theme per design patterns (see: 2-SoftwareDesignAndArchitecture/flutter-designs/design-patterns.md), setup custom ThemeData with light/dark modes, create base widget library (StatCard, MetricCard, ChartCard, DataListCard per architecture), establish design tokens and breakpoints | 📋 Not Started | P0 | Medium | Flutter, Material Design | ~~MVP-FL-001~~ | [mvp-details/MVP-FL-002.md](mvp-details/MVP-FL-002.md) |
| MVP-FL-003 | Routing & Navigation | Implement go_router, define route structure, create navigation widgets (AppBar, Drawer, breadcrumbs), route guards, error page | 📋 Not Started | P0 | Medium | go_router, Dart | MVP-FL-002 | [mvp-details/MVP-FL-003.md](mvp-details/MVP-FL-003.md) |
| MVP-FL-004 | State Management Architecture | Implement MVVM pattern with Riverpod/Provider (see: dashboard-design.md architecture), setup ViewModels (DashboardViewModel, StatsViewModel), configure providers, create base state patterns, implement dev tools, establish state organization conventions per file structure spec | 📋 Not Started | P0 | Medium | Riverpod/Bloc, Dart, MVVM | MVP-FL-003 | [mvp-details/MVP-FL-004.md](mvp-details/MVP-FL-004.md) |
| MVP-FL-005 | API Client Layer | Create Dio instance with interceptors, error handling, request/response transformers, authentication token management, API service factory pattern | 📋 Not Started | P0 | Medium | Dio, Dart, REST APIs | MVP-FL-004 | [mvp-details/MVP-FL-005.md](mvp-details/MVP-FL-005.md) |

---

## P0: Work Items Feature - Proof of Concept (CRITICAL)

*First complete feature demonstrating full stack integration*

| Task ID | Title | Description | Status | Priority | Effort | Skills | Dependencies | Details |
|---------|-------|-------------|--------|----------|--------|--------|--------------|---------|
| MVP-FL-006 | Work Items State Management | Create Riverpod providers/Bloc for work items CRUD operations. Implement filtering, pagination state, error handling, optimistic updates | 📋 Not Started | P0 | Medium | Riverpod/Bloc, Dart | MVP-FL-005 | [mvp-details/MVP-FL-006.md](mvp-details/MVP-FL-006.md) |
| MVP-FL-007 | Work Items Widgets | Build Flutter widgets using Material Design: WorkItemList, WorkItemCard, WorkItemForm, WorkItemFilters, WorkItemDetail. Implement CRUD operations, form validation, loading states | 📋 Not Started | P0 | High | Flutter, Dart, Material Design | MVP-FL-006 | [mvp-details/MVP-FL-007.md](mvp-details/MVP-FL-007.md) |
| MVP-FL-008 | Work Items Screens & Integration | Create list screen with pagination/filtering, detail screen with edit capability, create/edit dialogs, integrate with state management, implement real-time updates | 📋 Not Started | P0 | High | Flutter, Riverpod/Bloc, Dart | MVP-FL-007 | [mvp-details/MVP-FL-008.md](mvp-details/MVP-FL-008.md) |
| MVP-FL-008A | Dashboard Layout Implementation | Implement responsive dashboard layout per architecture (see: dashboard-design.md), create ResponsiveLayout widget with mobile/tablet/desktop breakpoints, build DashboardScreen with AppBar/Drawer/Body structure, implement breadcrumb navigation | 📋 Not Started | P0 | High | Flutter, Responsive Design | MVP-FL-008 | [mvp-details/MVP-FL-008A.md](mvp-details/MVP-FL-008A.md) |
| MVP-FL-008B | Dashboard Widgets Library | Build dashboard widget components: StatCard, MetricCard with trend indicators, ChartCard container, DataListCard, TaskChecklist widget (per design-patterns.md), implement responsive grid layouts | 📋 Not Started | P0 | High | Flutter, Material Design | MVP-FL-008A | [mvp-details/MVP-FL-008B.md](mvp-details/MVP-FL-008B.md) |

---

## P0: Authentication & Authorization (CRITICAL)

*User authentication flow and protected routes*

| Task ID | Title | Description | Status | Priority | Effort | Skills | Dependencies | Details |
|---------|-------|-------------|--------|----------|--------|--------|--------------|---------|
| MVP-FL-009 | Authentication State Management | Implement auth provider/bloc, login/logout methods, token storage (shared_preferences/flutter_secure_storage), auto-refresh token logic, user profile management | 📋 Not Started | P0 | Medium | Riverpod/Bloc, JWT, Dart | MVP-FL-005 | [mvp-details/MVP-FL-009.md](mvp-details/MVP-FL-009.md) |
| MVP-FL-010 | Login & Registration Screens | Create login screen, registration screen, password reset flow, form validation, error display, remember me functionality, social auth placeholders | 📋 Not Started | P0 | Medium | Flutter, Forms, Validation | MVP-FL-009 | [mvp-details/MVP-FL-010.md](mvp-details/MVP-FL-010.md) |
| MVP-FL-011 | Protected Routes & Permissions | Implement route guards with go_router, role-based route access, permission checking, unauthorized redirect, session expiry handling | 📋 Not Started | P0 | Medium | go_router, Authorization, Dart | MVP-FL-010 | [mvp-details/MVP-FL-011.md](mvp-details/MVP-FL-011.md) |

---

## P1: Agency Management Interface (CRITICAL)

*Core agency configuration and administration features*

| Task ID | Title | Description | Status | Priority | Effort | Skills | Dependencies | Details |
|---------|-------|-------------|--------|----------|--------|--------|--------------|---------|
| MVP-FL-012 | Agency Designer - Overview Section | Build agency overview screen using dashboard patterns: name, description, goals display, metadata panel, agency stats dashboard with MetricCards (see: design-patterns.md StatCard), quick actions menu | 📋 Not Started | P1 | Medium | Flutter, Dart, Material | MVP-FL-008B | [mvp-details/MVP-FL-012.md](mvp-details/MVP-FL-012.md) |
| MVP-FL-013 | Agency Designer - Roles & Teams | Create role management interface, team composition builder, RACI matrix editor, role assignment UI, permissions visualization | 📋 Not Started | P1 | High | Flutter, Dart, Complex Forms | MVP-FL-012 | [mvp-details/MVP-FL-013.md](mvp-details/MVP-FL-013.md) |
| MVP-FL-014 | Agency Designer - Configuration Panel | Build agency settings screen: token budgets UI, rate limits configuration, resource quotas, AI model selection, cost control dashboard with fl_chart (see: dashboard-design.md chart dependencies) | 📋 Not Started | P1 | High | Flutter, Dart, fl_chart | MVP-FL-013 | [mvp-details/MVP-FL-014.md](mvp-details/MVP-FL-014.md) |
| MVP-FL-015 | Agency Export Functionality | Implement export UI with format selection (PDF/Markdown/JSON), template chooser, custom branding options, download manager, export history | 📋 Not Started | P1 | Medium | Flutter, File APIs | MVP-FL-014 | [mvp-details/MVP-FL-015.md](mvp-details/MVP-FL-015.md) |
| MVP-FL-016 | AI-Powered Agency Creator UI | Build conversational AI interface for agency creation, chat-based flow, selective generation toggles, progress tracking, batch generation controls | 📋 Not Started | P1 | High | Flutter, Chat UI, AI Integration | MVP-FL-015 | [mvp-details/MVP-FL-016.md](mvp-details/MVP-FL-016.md) |

---

## P1: Kanban Board & Work Management (CRITICAL)

*Visual work item management and workflow automation*

| Task ID | Title | Description | Status | Priority | Effort | Skills | Dependencies | Details |
|---------|-------|-------------|--------|----------|--------|--------|--------------|---------|
| MVP-FL-017 | Kanban Board Core UI | Build draggable kanban board with columns (Open, In Progress, Review, Done), drag-and-drop gestures, column swimlanes, quick filters, board view switcher | 📋 Not Started | P1 | High | Flutter, Drag/Drop, State Mgmt | MVP-FL-008 | [mvp-details/MVP-FL-017.md](mvp-details/MVP-FL-017.md) |
| MVP-FL-018 | Work Item Detail Panel | Create detailed work item screen: description editor, comments section, attachment manager, activity timeline, status transitions, assignee picker | 📋 Not Started | P1 | High | Flutter, Rich Text, File Upload | MVP-FL-017 | [mvp-details/MVP-FL-018.md](mvp-details/MVP-FL-018.md) |
| MVP-FL-019 | Git Integration UI | Build file explorer tree view, code diff viewer, commit history, branch visualizer, merge request interface, conflict resolution UI | 📋 Not Started | P1 | High | Flutter, Code Editor, Git Viz | MVP-FL-018 | [mvp-details/MVP-FL-019.md](mvp-details/MVP-FL-019.md) |
| MVP-FL-020 | Workflow Automation UI | Create workflow builder interface, trigger configuration, action chaining, conditional logic editor, workflow templates, execution monitoring | 📋 Not Started | P1 | High | Flutter, Visual Programming | MVP-FL-019 | [mvp-details/MVP-FL-020.md](mvp-details/MVP-FL-020.md) |

---

## P1: Agent Management Dashboard (CRITICAL)

*Agent lifecycle monitoring and control interface*

| Task ID | Title | Description | Status | Priority | Effort | Skills | Dependencies | Details |
|---------|-------|-------------|--------|----------|--------|--------|--------------|---------|
| MVP-FL-021 | Agent List & Monitoring View | Build agent directory with list/grid views, status indicators, health badges, filter by state/type/agency, search, sort, bulk actions | 📋 Not Started | P1 | Medium | Flutter, Dart, Tables | MVP-FL-011 | [mvp-details/MVP-FL-021.md](mvp-details/MVP-FL-021.md) |
| MVP-FL-022 | Agent Detail Dashboard | Create comprehensive agent screen using dashboard layout patterns: status FSM visualization, health metrics with ChartCard widgets, run history DataTable, logs viewer, configuration panel, control buttons (start/stop/restart) | 📋 Not Started | P1 | High | Flutter, fl_chart, Real-time Data | MVP-FL-021 | [mvp-details/MVP-FL-022.md](mvp-details/MVP-FL-022.md) |
| MVP-FL-023 | Agent Creation Wizard | Build multi-step wizard: agent type selection, configuration form, capability selection, policy assignment, template chooser, AI-assisted creation | 📋 Not Started | P1 | High | Flutter, Multi-step Forms | MVP-FL-022 | [mvp-details/MVP-FL-023.md](mvp-details/MVP-FL-023.md) |
| MVP-FL-024 | Real-time Agent Monitoring | Implement WebSocket/Stream connection for live updates, real-time metrics charts, event stream viewer, alert notifications, performance graphs | 📋 Not Started | P1 | High | WebSockets, Charts, Flutter | MVP-FL-023 | [mvp-details/MVP-FL-024.md](mvp-details/MVP-FL-024.md) |

---

## P1: Property Broadcasting & Real-time Features (CRITICAL)

*Real-time property updates for tracking and monitoring use cases*

| Task ID | Title | Description | Status | Priority | Effort | Skills | Dependencies | Details |
|---------|-------|-------------|--------|----------|--------|--------|--------------|---------|
| MVP-FL-025 | Property Subscription UI | Build property subscription manager: browse available properties, subscribe/unsubscribe, favorites list, notification preferences, filter configuration | 📋 Not Started | P1 | Medium | Flutter, Dart, Forms | MVP-FL-024 | [mvp-details/MVP-FL-025.md](mvp-details/MVP-FL-025.md) |
| MVP-FL-026 | Real-time Map Visualization | Create interactive map widget per dashboard architecture: real-time location markers, agent tracking, geofence display, route visualization, heat maps, cluster view (using google_maps_flutter or flutter_map) | 📋 Not Started | P1 | High | Flutter, google_maps_flutter | MVP-FL-025 | [mvp-details/MVP-FL-026.md](mvp-details/MVP-FL-026.md) |
| MVP-FL-027 | Property Dashboard & Analytics | Build real-time property dashboard using MetricCard/ChartCard patterns (see: design-patterns.md): metric cards with trend indicators, time-series charts with fl_chart, property history, comparison views, export data, custom widgets | 📋 Not Started | P1 | High | Flutter, fl_chart, Streams | MVP-FL-026 | [mvp-details/MVP-FL-027.md](mvp-details/MVP-FL-027.md) |

---

## P1: Testing & Quality Assurance (CRITICAL)

*Comprehensive testing suite for production readiness*

| Task ID | Title | Description | Status | Priority | Effort | Skills | Dependencies | Details |
|---------|-------|-------------|--------|----------|--------|--------|--------------|---------|
| MVP-FL-028 | Unit Testing Setup | Configure Flutter test framework, setup testing utilities, create test helpers, mock API layer, establish coverage thresholds (>80%), CI integration | 📋 Not Started | P1 | Medium | Flutter Test, Mockito, Dart | MVP-FL-008 | [mvp-details/MVP-FL-028.md](mvp-details/MVP-FL-028.md) |
| MVP-FL-029 | Widget Testing Suite | Write widget tests, test user interactions, accessibility testing, golden tests, visual regression tests | 📋 Not Started | P1 | High | Flutter Test, Golden Tests | MVP-FL-028 | [mvp-details/MVP-FL-029.md](mvp-details/MVP-FL-029.md) |
| MVP-FL-030 | Integration Testing | Build integration tests for state flows, API integration tests, routing tests, authentication flow tests, end-to-end critical paths | 📋 Not Started | P1 | High | Integration Test, Mockito | MVP-FL-029 | [mvp-details/MVP-FL-030.md](mvp-details/MVP-FL-030.md) |
| MVP-FL-031 | E2E Testing | Setup integration_test package, write E2E tests for critical user journeys, cross-platform testing, mobile tests, performance tests | 📋 Not Started | P1 | Medium | integration_test, E2E Testing | MVP-FL-030 | [mvp-details/MVP-FL-031.md](mvp-details/MVP-FL-031.md) |

---

## P1: Deployment & DevOps (CRITICAL)

*Production deployment pipeline and infrastructure*

| Task ID | Title | Description | Status | Priority | Effort | Skills | Dependencies | Details |
|---------|-------|-------------|--------|----------|--------|--------|--------------|---------|
| MVP-FL-032 | Build Optimization | Configure production builds (web/mobile/desktop), code splitting, lazy loading, app size optimization, asset optimization, caching strategy | 📋 Not Started | P1 | Medium | Flutter Build, Performance | MVP-FL-031 | [mvp-details/MVP-FL-032.md](mvp-details/MVP-FL-032.md) |
| MVP-FL-033 | Docker & Web Deployment | Create Dockerfile for web build, Nginx configuration for Flutter web, environment variable injection, health checks, container optimization | 📋 Not Started | P1 | Medium | Docker, Nginx, DevOps | MVP-FL-032 | [mvp-details/MVP-FL-033.md](mvp-details/MVP-FL-033.md) |
| MVP-FL-034 | CI/CD Pipeline | Setup GitHub Actions workflow, automated testing, build validation (web/iOS/Android), app store deployment, rollback procedures | 📋 Not Started | P1 | Medium | CI/CD, GitHub Actions | MVP-FL-033 | [mvp-details/MVP-FL-034.md](mvp-details/MVP-FL-034.md) |
| MVP-FL-035 | Monitoring & Analytics | Integrate error tracking (Sentry/Firebase Crashlytics), analytics (GA4/Firebase Analytics), performance monitoring, user tracking, dashboards, alerting | 📋 Not Started | P1 | Medium | Monitoring, Analytics | MVP-FL-034 | [mvp-details/MVP-FL-035.md](mvp-details/MVP-FL-035.md) |

---

## P2: Enhanced User Experience (IMPORTANT)

*Polish and advanced features for better usability*

| Task ID | Title | Description | Status | Priority | Effort | Skills | Dependencies | Details |
|---------|-------|-------------|--------|----------|--------|--------|--------------|---------|
| MVP-FL-036 | Dark Mode & Theming | Implement ThemeMode switcher per AppTheme spec (see: dashboard-design.md Theme Configuration), dark/light themes, custom theme builder, user theme preferences with provider, theme persistence, platform-adaptive themes | 📋 Not Started | P2 | Medium | Flutter Theming, Material/Cupertino | MVP-FL-011 | [mvp-details/MVP-FL-036.md](mvp-details/MVP-FL-036.md) |
| MVP-FL-037 | Advanced Search & Filtering | Build global search widget, advanced filter builder, saved search queries, search suggestions, search history, faceted search | 📋 Not Started | P2 | High | Flutter, Search UX, State Mgmt | MVP-FL-036 | [mvp-details/MVP-FL-037.md](mvp-details/MVP-FL-037.md) |
| MVP-FL-038 | Notification System | Create notification center, real-time notifications, notification preferences, push notifications (FCM), local notifications, notification history | 📋 Not Started | P2 | Medium | Flutter, FCM, local_notifications | MVP-FL-037 | [mvp-details/MVP-FL-038.md](mvp-details/MVP-FL-038.md) |
| MVP-FL-039 | Platform-Adaptive Experience | Optimize layouts using ScreenBreakpoints (600/900/1200/1800px per architecture spec), mobile/tablet/desktop/wide layouts, touch/mouse interactions, platform-specific navigation (Drawer vs NavigationRail), offline-first capabilities with local storage | 📋 Not Started | P2 | High | Responsive Flutter, Offline-first | MVP-FL-038 | [mvp-details/MVP-FL-039.md](mvp-details/MVP-FL-039.md) |
| MVP-FL-040 | Accessibility Enhancements | Semantics implementation, keyboard navigation, screen reader support (TalkBack/VoiceOver), focus management, accessibility testing | 📋 Not Started | P2 | Medium | Accessibility, Semantics | MVP-FL-039 | [mvp-details/MVP-FL-040.md](mvp-details/MVP-FL-040.md) |

---

## P2: Advanced Features (FUTURE ENHANCEMENT)

*Next-generation capabilities and integrations*

| Task ID | Title | Description | Status | Priority | Effort | Skills | Dependencies | Details |
|---------|-------|-------------|--------|----------|--------|--------|--------------|---------|
| MVP-FL-041 | A2A Protocol UI Integration | Build external agent discovery UI, agent card viewer, task delegation interface, A2A agent monitoring, trust score visualization | 📋 Not Started | P2 | High | Flutter, Dart, Complex Data | MVP-FL-024 | [mvp-details/MVP-FL-041.md](mvp-details/MVP-FL-041.md) |
| MVP-FL-042 | Compliance Dashboard | Create compliance framework selector, policy visualization, compliance reports, audit trail viewer, violation alerts, remediation workflow | 📋 Not Started | P2 | High | Flutter, Compliance UX, Reports | MVP-FL-041 | [mvp-details/MVP-FL-042.md](mvp-details/MVP-FL-042.md) |
| MVP-FL-043 | Advanced Analytics & Reporting | Build custom report builder using dashboard widget patterns, data visualization library with fl_chart (line, bar, area, pie, radar charts per architecture), export to various formats, scheduled reports, dashboard templates, KPI tracking with MetricCards | 📋 Not Started | P2 | High | Flutter, fl_chart, Data Viz | MVP-FL-042 | [mvp-details/MVP-FL-043.md](mvp-details/MVP-FL-043.md) |
| MVP-FL-044 | Collaboration Features | Implement real-time collaborative editing, comments & mentions, activity feed, user presence indicators, team chat integration | 📋 Not Started | P2 | High | Flutter, Streams, CRDT | MVP-FL-043 | [mvp-details/MVP-FL-044.md](mvp-details/MVP-FL-044.md) |

---

## Bugs and Issues

### Resolved Bugs

_(None yet)_

### Active Bugs

_(None)_

---

## Task Summary by Priority

### P0 (Blocking - Must Complete First)
- **Foundation & Infrastructure**: 5 tasks (MVP-FL-001 through MVP-FL-005)
- **Work Items PoC**: 3 tasks (MVP-FL-006 through MVP-FL-008)
- **Dashboard Implementation**: 2 tasks (MVP-FL-008A, MVP-FL-008B)
- **Authentication**: 3 tasks (MVP-FL-009 through MVP-FL-011)

**Total P0**: 13 tasks

### P1 (Critical - Core Features)
- **Agency Management**: 5 tasks (MVP-FL-012 through MVP-FL-016)
- **Kanban & Work Management**: 4 tasks (MVP-FL-017 through MVP-FL-020)
- **Agent Management**: 4 tasks (MVP-FL-021 through MVP-FL-024)
- **Real-time Features**: 3 tasks (MVP-FL-025 through MVP-FL-027)
- **Testing**: 4 tasks (MVP-FL-028 through MVP-FL-031)
- **Deployment**: 4 tasks (MVP-FL-032 through MVP-FL-035)

**Total P1**: 24 tasks

### P2 (Important - Quality & Enhancement)
- **Enhanced UX**: 5 tasks (MVP-FL-036 through MVP-FL-040)
- **Advanced Features**: 4 tasks (MVP-FL-041 through MVP-FL-044)

**Total P2**: 9 tasks

**Grand Total Active Tasks**: 46 tasks

---

## Implementation Sequence

### Phase 1: Foundation (Weeks 1-2)
1. MVP-FL-001 - Flutter Project Setup
2. MVP-FL-002 - Design System Setup
3. MVP-FL-003 - Routing & Navigation
4. MVP-FL-004 - State Management
5. MVP-FL-005 - API Client Layer

### Phase 2: Work Items PoC & Dashboard (Weeks 3-6)
6. MVP-FL-006 - Work Items State Management
7. MVP-FL-007 - Work Items Widgets
8. MVP-FL-008 - Work Items Screens & Integration
8A. MVP-FL-008A - Dashboard Layout Implementation (per architecture spec)
8B. MVP-FL-008B - Dashboard Widgets Library (StatCard, MetricCard, ChartCard)

### Phase 3: Authentication (Week 7)
9. MVP-FL-009 - Authentication State Management
10. MVP-FL-010 - Login & Registration Screens
11. MVP-FL-011 - Protected Routes & Permissions

### Phase 4: Core Features (Weeks 7-12)
- Agency Management (MVP-FL-012 through MVP-FL-016)
- Kanban Board (MVP-FL-017 through MVP-FL-020)
- Agent Management (MVP-FL-021 through MVP-FL-024)

### Phase 5: Testing & Deployment (Weeks 13-15)
- Testing Suite (MVP-FL-028 through MVP-FL-031)
- Deployment Pipeline (MVP-FL-032 through MVP-FL-035)

### Phase 6: Enhancement (Weeks 16+)
- Real-time Features (MVP-FL-025 through MVP-FL-027)
- UX Enhancements (MVP-FL-036 through MVP-FL-040)
- Advanced Features (MVP-FL-041 through MVP-FL-044)

---

**Architecture Notes**:
- **Design Architecture**: See `/documents/2-SoftwareDesignAndArchitecture/flutter-designs/` for comprehensive design specs
  - `dashboard-design.md`: Complete dashboard architecture, MVVM pattern, component specs, file structure
  - `design-patterns.md`: Reusable widget patterns (StatCard, DataTable, Charts, Navigation)
- **Backend Integration**: All backend APIs provided by CodeValdCortex (Go + ArangoDB)
- **Frontend Stack**: Flutter + Dart + Riverpod/Provider (MVVM) + Material Design + Dio
- **Platforms**: Web (primary), iOS, Android, Desktop (macOS, Windows, Linux)
- **Responsive Breakpoints**: Mobile (<600px), Tablet (600-900px), Desktop (900-1200px), Wide (>1200px)
- **Communication**: REST APIs with WebSocket/Stream support for real-time features
- **Deployment**: Web (Docker + Nginx), Mobile (App Store/Play Store), Desktop (platform installers)
- **State Management**: Riverpod/Provider with ViewModel pattern (DashboardViewModel, StatsViewModel, etc.)
- **Required Packages**: provider/riverpod, fl_chart, flutter_svg, badges, responsive_framework, data_table_2
- **Testing**: Flutter Test + Widget Tests + Integration Tests + Golden Tests

**Note**: This document contains only active and pending tasks. All completed tasks are moved to `mvp_done.md` to maintain a clean, actionable backlog.
