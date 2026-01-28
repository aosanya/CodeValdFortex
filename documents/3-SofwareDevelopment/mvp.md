# MVP - Minimum Viable Product Task Breakdown (Frontend)

## Task Overview
- **Objective**: Build modern Flutter cross-platform application for CodeVald platform providing seamless user experience for agency management, work items, and agent orchestration on Web, iOS, Android, and Desktop
- **Success Criteria**: Production-ready Flutter application with core features that integrates with CodeValdCortex backend APIs
- **Dependencies**: Backend REST APIs from CodeValdCortex, Material Design widgets, state management architecture (Riverpod)
- **Architecture Alignment**: Structured to match CodeValdCortex domain flow: Agency Selection → Agency Designer → Publishing → Instances → Work Execution → Agents

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
git checkout -b feature/MVP-FL-XXX_description

# Work, build validation, test
# ... development work ...

# Merge when complete and tested
git checkout main
git merge feature/MVP-FL-XXX_description --no-ff
git branch -d feature/MVP-FL-XXX_description
```

---

## Status Legend
- ✅ **Completed** - Task done, merged to main (see `mvp_done.md`)
- 🚀 **In Progress** - Currently being worked on
- 📋 **Not Started** - Ready to begin (dependencies met)
- ⏸️ **Blocked** - Waiting on dependencies
- ⚠️ **Deprecated** - Superseded by other work

---

## P0 - Phase 1: Foundation & Infrastructure ✅ COMPLETE

*Core architecture, build system, and development environment*

| Task ID | Title | Description | Status | Priority | Effort | Skills | Dependencies | Details |
|---------|-------|-------------|--------|----------|--------|--------|--------------|---------|
| ~~MVP-FL-001~~ | ~~Flutter Project Setup~~ | ~~Initialize Flutter project, configure platforms (web/mobile/desktop), setup dependencies~~ | ✅ Completed | P0 | Low | Flutter, Dart | None | - |
| ~~MVP-FL-002~~ | ~~Design System Setup~~ | ~~Setup Material Design, theme configuration, color schemes, typography~~ | ✅ Completed | P0 | Low | Flutter, Material Design | ~~MVP-FL-001~~ | - |
| ~~MVP-FL-003~~ | ~~Routing & Navigation~~ | ~~Configure go_router, define routes, navigation patterns~~ | ✅ Completed | P0 | Medium | go_router, Flutter | ~~MVP-FL-002~~ | - |
| ~~MVP-FL-004~~ | ~~State Management Architecture~~ | ~~Implement MVVM pattern with Riverpod/Provider, setup ViewModels, configure providers~~ | ✅ Completed | P0 | Medium | Riverpod, Dart, MVVM | ~~MVP-FL-003~~ | [mvp-details/MVP-FL-004.md](mvp-details/MVP-FL-004.md) |
| ~~MVP-FL-005~~ | ~~API Client Layer~~ | ~~Create Dio instance with interceptors, error handling, authentication token management~~ | ✅ Completed | P0 | Medium | Dio, Dart, REST APIs | ~~MVP-FL-004~~ | [mvp-details/MVP-FL-005.md](mvp-details/MVP-FL-005.md) |

---

## P0: Authentication & Authorization (CRITICAL)

*User authentication flow and protected routes - prerequisite for agency access*

| Task ID | Title | Description | Status | Priority | Effort | Skills | Dependencies | Details |
|---------|-------|-------------|--------|----------|--------|--------|--------------|---------|
| MVP-FL-009 | Authentication State Management | Implement auth provider with Riverpod, login/logout methods, token storage (flutter_secure_storage), auto-refresh token logic, user profile management | 📋 Not Started | P0 | Medium | Riverpod, JWT, Dart | MVP-FL-005 | - |
| MVP-FL-010 | Login & Registration Screens | Create login screen, registration screen, password reset flow, form validation, error display, remember me functionality | 📋 Not Started | P0 | Medium | Flutter, Forms, Validation | MVP-FL-009 | - |
| MVP-FL-011 | Protected Routes & Permissions | Implement route guards with go_router, role-based route access, permission checking, unauthorized redirect, session expiry handling | 📋 Not Started | P0 | Medium | go_router, Authorization | MVP-FL-010 | - |

---

## P0 - Phase 2: Agency Selection & Creation (CRITICAL)

*Initial agency management - migrated from Cortex MVP-022, MVP-024*

| Task ID | Title | Description | Status | Priority | Effort | Skills | Dependencies | Details |
|---------|-------|-------------|--------|----------|--------|--------|--------------|---------|
| MVP-FL-101 | Agency Selection Homepage | Build homepage UI for listing and selecting agencies. Display agency cards with name, description, status badges (draft/validated/published/active). Implement search/filter, sorting. Navigate to selected agency. Migrated from Cortex MVP-022 | 📋 Not Started | P0 | Medium | Flutter, Material Design | MVP-FL-011 | - |
| MVP-FL-102 | Create Agency Form | Implement agency creation form with name field, UUID generation, validation, error handling. Create new agency via POST /api/v1/agencies. Navigate to Agency Designer after creation. Migrated from Cortex MVP-024 | 📋 Not Started | P0 | Low | Flutter, Forms, Validation | MVP-FL-101 | - |

---

## P0 - Phase 3: Agency Designer - Core Sections (CRITICAL)

*Essential agency configuration - migrated from Cortex Agency Designer*

| Task ID | Title | Description | Status | Priority | Effort | Skills | Dependencies | Details |
|---------|-------|-------------|--------|----------|--------|--------|--------------|---------|
| MVP-FL-103 | Agency Designer Navigation | Build Agency Designer shell with tab navigation for 8 sections (Introduction, Goals, Work Items, Roles, RACI, Workflows, Policy, Admin). Implement section completion indicators, save progress, responsive layout. Persistent state across navigation | 📋 Not Started | P0 | Medium | Flutter, Routing, State Mgmt | MVP-FL-102 | - |
| MVP-FL-104 | Introduction Section | Build introduction editor for agency background, purpose, scope. Rich text editor, auto-save, character limits, validation. Migrated from Cortex MVP-025. AI-powered generation from uploaded documents | 📋 Not Started | P0 | Medium | Flutter, Rich Text, Forms | MVP-FL-103 | - |
| MVP-FL-105 | Goals Section | Implement Goals CRUD with list/create/edit/delete. SMART goal format, tags, prioritization. AI-powered goal generation/refinement from natural language. Migrated from Cortex MVP-029 | 📋 Not Started | P0 | High | Flutter, AI Integration, Forms | MVP-FL-104 | - |
| MVP-FL-106 | Work Items Section | Build Work Items CRUD with hierarchical deliverables tree builder (folders/files with AI prompt instructions). Work item code, title, description, tags, goal linking. AI-powered generation. Drag-and-drop tree editing. Migrated from Cortex MVP-030, MVP-043, MVP-054 | 📋 Not Started | P0 | High | Flutter, Tree UI, Drag-Drop | MVP-FL-105 | - |

---

## P0 - Phase 4: Agency Designer - Advanced Sections (CRITICAL)

*Advanced agency configuration features*

| Task ID | Title | Description | Status | Priority | Effort | Skills | Dependencies | Details |
|---------|-------|-------------|--------|----------|--------|--------|--------------|---------|
| MVP-FL-107 | Roles Section | Build Roles manager with CRUD operations. Role taxonomy: autonomy levels (L0-L4: Manual→Assisted→Conditional→High Automation→Full Autonomy), capabilities, token budgets, tags categorization. System vs custom roles filtering. AI-powered role generation. Migrated from Cortex MVP-044 | 📋 Not Started | P0 | High | Flutter, Forms, AI Integration | MVP-FL-106 | - |
| MVP-FL-108 | RACI Matrix Section | Implement interactive RACI matrix editor with grid layout. Map work items × roles with RACI assignments (Responsible, Accountable, Consulted, Informed). Modal editing, auto-save, validation. Migrated from Cortex MVP-045 | 📋 Not Started | P0 | High | Flutter, Grid UI, State Mgmt | MVP-FL-107 | - |
| MVP-FL-109 | Workflows Section | Build Workflow manager with list/create/edit/delete. Visual workflow designer with drag-and-drop: vertical column layout, work item step nodes, parallel/sequential execution, side drop zones. AI-powered workflow generation. Debounced saves (300ms). Migrated from Cortex MVP-051, MVP-052 | 📋 Not Started | P0 | High | Flutter, Drag-Drop, Visual Designer | MVP-FL-108 | - |
| MVP-FL-110 | AI Policy Section | Implement AI Policy configurator with policy rules definition, budget constraints, approval workflows, compliance frameworks selection (GDPR, SOC2, HIPAA, ISO27001). Policy validation and preview. Migrated from Cortex MVP-048 | 📋 Not Started | P0 | Medium | Flutter, Forms, Policy UI | MVP-FL-109 | - |
| MVP-FL-111 | Admin & Configuration Section | Build agency admin panel: token budgets (role & agent levels), rate limits, resource quotas, AI model selection, cost controls, monitoring dashboards. Migrated from Cortex MVP-046 | 📋 Not Started | P0 | Medium | Flutter, Dashboard, Forms | MVP-FL-110 | - |

---

## P0 - Phase 5: Publishing & Tagging (CRITICAL)

*Agency lifecycle management - validation, publishing, versioning*

| Task ID | Title | Description | Status | Priority | Effort | Skills | Dependencies | Details |
|---------|-------|-------------|--------|----------|--------|--------|--------------|---------|
| MVP-FL-112 | Publishing Toolbar & Validation | Build context-sensitive publishing toolbar with state-based button visibility (Validate/Publish/Tag/Pause/Resume/Drain/Stop). Implement pre-publish validation UI with checklist display (introduction, goals, roles, workflows, RACI complete), error highlighting. Migrated from Cortex MVP-PUB-005 | 📋 Not Started | P0 | Medium | Flutter, State Mgmt, Validation | MVP-FL-111 | - |
| MVP-FL-113 | Publish & Activate Dialog | Create publish dialog with version input (semantic versioning v1.0.0), description field, auto-activate checkbox, create-tag option. Show deployment manifest preview (agent spawn plan, workflow execution plan, resource allocation), confirmation flow, progress indicator. State transitions: draft→validated→published→active | 📋 Not Started | P0 | Medium | Flutter, Dialogs, Forms | MVP-FL-112 | - |
| MVP-FL-114 | Tag Management UI | Build tag creation dialog with tag types (release/snapshot/experimental/checkpoint), version input, description, metadata fields. Tag list view with filter/search, tag comparison viewer (diff display), restore from tag flow. SHA-256 content hashing. Migrated from Cortex MVP-PUB-002 | 📋 Not Started | P0 | Medium | Flutter, Lists, Dialogs | MVP-FL-113 | - |
| MVP-FL-115 | Versions Page | Implement versions/tags listing page with grouped cards by tag type, tag metadata display, instance count badges per tag. Actions: view instances, create new instance, compare tags, restore agency. Migrated from Cortex MVP-PUB-007 | 📋 Not Started | P0 | Medium | Flutter, Cards, Lists | MVP-FL-114 | - |
| MVP-FL-116 | Export System UI | Build export dialog with format selection (PDF/Markdown/JSON), template chooser, custom branding options, section selection checkboxes. Download manager, export history viewer. Aggregates data from all Agency Designer modules. Migrated from Cortex MVP-047 | 📋 Not Started | P0 | Medium | Flutter, File Download, Forms | MVP-FL-115 | - |

---

## P1 - Phase 6: Instance Management (CRITICAL)

*Multi-instance deployment from tag snapshots - migrated from Cortex MVP-PUB-007*

| Task ID | Title | Description | Status | Priority | Effort | Skills | Dependencies | Details |
|---------|-------|-------------|--------|----------|--------|--------|--------------|---------|
| MVP-FL-117 | Instance Creation UI | Build instance creation flow from tag: "Start Instance" dialog with instance name, environment selection (test/demo/production), resource allocation settings. Progress indicator, error handling. Navigate to instance dashboard after creation. Database-per-instance isolation | 📋 Not Started | P1 | Medium | Flutter, Dialogs, Forms | MVP-FL-116 | - |
| MVP-FL-118 | Instance List & Dashboard | Create instance listing page with grouped cards (by tag), flat searchable table view, instance count badges. 3-panel instance dashboard: overview (status, uptime, metrics), agents list with health, real-time metrics charts (fl_chart). Auto-refreshing status (polling or WebSocket) | 📋 Not Started | P1 | High | Flutter, Dashboard, Charts | MVP-FL-117 | - |
| MVP-FL-119 | Instance Lifecycle Controls | Implement instance lifecycle management UI: Stop, Restart, Delete actions with confirmation dialogs. Graceful shutdown progress tracking (30s timeout), health status indicators (pending/running/stopping/stopped/failed). Dropdown action menus per instance. State machine: pending→running→stopping→stopped | 📋 Not Started | P1 | Medium | Flutter, State Mgmt | MVP-FL-118 | - |

---

## P1 - Phase 7: Work Execution - Kanban & Git (CRITICAL)

*Work item execution management - migrated from Cortex Workbench*

| Task ID | Title | Description | Status | Priority | Effort | Skills | Dependencies | Details |
|---------|-------|-------------|--------|----------|--------|--------|--------------|---------|
| MVP-FL-120 | Workbench Kanban Board | Build kanban board UI with dynamic columns from workflow steps. Issue creation form with deliverables tree, drag-and-drop between columns (HTML5 Drag API), issue cards with metadata (assignee, tags, due date), filtering/search, real-time updates via WebSocket/polling. Migrated from Cortex MVP-WI-008 | 📋 Not Started | P1 | High | Flutter, Drag-Drop, State Mgmt | MVP-FL-119 | - |
| MVP-FL-121 | Issue Detail Panel | Create detailed issue view: description editor (rich text/markdown), comments section with threading, attachment manager (file upload), activity timeline, status transitions, assignee picker, tag management, linked work items | 📋 Not Started | P1 | High | Flutter, Rich Text, Forms | MVP-FL-120 | - |
| MVP-FL-122 | File Explorer UI | Build hierarchical file explorer with folder/file tree view, create/rename/delete operations, file content editor (code editor with syntax highlighting), breadcrumb navigation, search/filter. Git-in-ArangoDB integration. Migrated from Cortex MVP-WI-006 | 📋 Not Started | P1 | High | Flutter, Tree UI, File Handling | MVP-FL-121 | - |
| MVP-FL-123 | Git Integration UI | Implement Git operations UI: commit history viewer with SHA/author/message, branch visualizer (tree diagram), diff viewer with syntax highlighting (side-by-side or unified), merge conflict resolution UI with three-way merge, pull request interface | 📋 Not Started | P1 | High | Flutter, Code Editor, Git Viz | MVP-FL-122 | - |
| MVP-FL-124 | Workflow Automation UI | Create workflow automation configuration UI: trigger setup (issue state changes, git events, schedule), action chaining (sequential/parallel), conditional logic builder (if/then/else), workflow templates library, execution monitoring dashboard with run history | 📋 Not Started | P1 | High | Flutter, Visual Programming | MVP-FL-123 | - |

---

## P1 - Phase 8: Agent Management Dashboard (CRITICAL)

*Agent lifecycle monitoring and control interface*

| Task ID | Title | Description | Status | Priority | Effort | Skills | Dependencies | Details |
|---------|-------|-------------|--------|----------|--------|--------|--------------|---------|
| MVP-FL-125 | Agent List & Monitoring View | Build agent directory with list/grid views, status indicators (Registered/Scheduled/Starting/Healthy/Degraded/Backoff/Draining/Quarantined/Stopped/Retired), health badges, filter by state/type/agency/instance, search, sort, bulk actions. Display agent-to-instance mappings with instance name/status | 📋 Not Started | P1 | Medium | Flutter, Tables, Filtering | MVP-FL-124 | - |
| MVP-FL-126 | Agent Detail Dashboard | Create comprehensive agent screen using dashboard layout patterns: status FSM visualization (interactive state diagram), health metrics with ChartCard widgets (CPU/memory/token usage), run history DataTable (run states: Pending/Running/Waiting I/O/Waiting HITL/Succeeded/Failed), logs viewer with filtering, configuration panel, control buttons (start/stop/restart) | 📋 Not Started | P1 | High | Flutter, fl_chart, Real-time Data | MVP-FL-125 | - |
| MVP-FL-127 | Agent Creation Wizard | Build multi-step wizard: agent type selection from roles (display role capabilities/autonomy level), configuration form (token budget, rate limits), capability selection checkboxes, policy assignment dropdown, template chooser, AI-assisted creation suggestions based on work item context | 📋 Not Started | P1 | High | Flutter, Multi-step Forms | MVP-FL-126 | - |
| MVP-FL-128 | Real-time Agent Monitoring | Implement WebSocket/SSE connection for live updates, real-time metrics charts (streaming data with fl_chart), event stream viewer (agent events, state transitions), alert notifications (toast/snackbar), performance graphs (time-series). Integration with property broadcasting system | 📋 Not Started | P1 | High | WebSockets, Charts, Flutter | MVP-FL-127 | - |

---

## P1 - Phase 9: Property Broadcasting & Real-time Features (CRITICAL)

*Real-time property updates for tracking and monitoring use cases (UC-TRACK-001 Safiri Salama)*

| Task ID | Title | Description | Status | Priority | Effort | Skills | Dependencies | Details |
|---------|-------|-------------|--------|----------|--------|--------|--------------|---------|
| MVP-FL-129 | Property Subscription UI | Build property subscription manager: browse available properties from agents, subscribe/unsubscribe actions, favorites list, notification preferences (frequency, filters), filter configuration (geofencing, property masking). Persistent subscriptions across sessions | 📋 Not Started | P1 | Medium | Flutter, Forms | MVP-FL-128 | - |
| MVP-FL-130 | Real-time Map Visualization | Create interactive map widget: real-time location markers (agents/vehicles), agent tracking with trails, geofence display (polygons, circles), route visualization with ETA, heat maps for density, cluster view for performance. Using google_maps_flutter or flutter_map. Privacy controls for sensitive locations | 📋 Not Started | P1 | High | Flutter, google_maps_flutter | MVP-FL-129 | - |
| MVP-FL-131 | Property Dashboard & Analytics | Build real-time property dashboard using MetricCard/ChartCard patterns: metric cards with trend indicators (↑↓), time-series charts with fl_chart (broadcast intervals, property changes), property history viewer, comparison views (multi-agent), export data (CSV/JSON), custom widgets for domain-specific properties (speed, temperature, etc.) | 📋 Not Started | P1 | High | Flutter, fl_chart, Streams | MVP-FL-130 | - |

---

## P1 - Phase 10: Testing & Quality Assurance (CRITICAL)

*Comprehensive testing suite for production readiness*

| Task ID | Title | Description | Status | Priority | Effort | Skills | Dependencies | Details |
|---------|-------|-------------|--------|----------|--------|--------|--------------|---------|
| MVP-FL-132 | Unit Testing Setup | Configure Flutter test framework, setup testing utilities (mockito, faker), create test helpers, mock API layer (dio_mock), establish coverage thresholds (>80%), CI integration with GitHub Actions | 📋 Not Started | P1 | Medium | Flutter Test, Mockito, Dart | MVP-FL-131 | - |
| MVP-FL-133 | Widget Testing Suite | Write widget tests for all major components: agency designer sections, kanban board, agent dashboard, forms. Test user interactions (tap, drag, input), accessibility testing (semantics, screen reader), golden tests for UI regression, visual regression tests | 📋 Not Started | P1 | High | Flutter Test, Golden Tests | MVP-FL-132 | - |
| MVP-FL-134 | Integration Testing | Build integration tests for complete user flows: agency creation → design → publish → activate, work item creation → assignment → completion, agent spawning → execution. API integration tests, routing tests, authentication flow tests, end-to-end critical paths | 📋 Not Started | P1 | High | Integration Test, Mockito | MVP-FL-133 | - |
| MVP-FL-135 | E2E Testing | Setup integration_test package, write E2E tests for critical user journeys on real devices/emulators, cross-platform testing (web/iOS/Android), mobile-specific tests, performance tests (frame rate, load time, bundle size) | 📋 Not Started | P1 | Medium | integration_test, E2E Testing | MVP-FL-134 | - |

---

## P1 - Phase 11: Deployment & DevOps (CRITICAL)

*Production deployment pipeline and infrastructure*

| Task ID | Title | Description | Status | Priority | Effort | Skills | Dependencies | Details |
|---------|-------|-------------|--------|----------|--------|--------|--------------|---------|
| MVP-FL-136 | Build Optimization | Configure production builds for all platforms (web/mobile/desktop): code splitting (deferred imports), lazy loading (images, routes), app size optimization (tree shaking, obfuscation), asset optimization (image compression, font subsetting), caching strategy (service workers for web) | 📋 Not Started | P1 | Medium | Flutter Build, Performance | MVP-FL-135 | - |
| MVP-FL-137 | Docker & Web Deployment | Create Dockerfile for Flutter web build (multi-stage build with nginx), Nginx configuration for SPA routing, environment variable injection (.env handling), health checks, container optimization (Alpine Linux, layer caching), CDN configuration for static assets | 📋 Not Started | P1 | Medium | Docker, Nginx, DevOps | MVP-FL-136 | - |
| MVP-FL-138 | CI/CD Pipeline | Setup GitHub Actions workflow: automated testing on PR (unit, widget, integration), build validation for all platforms (web/iOS/Android), app store deployment (TestFlight, Play Console), version bumping, changelog generation, rollback procedures, deployment notifications | 📋 Not Started | P1 | Medium | CI/CD, GitHub Actions | MVP-FL-137 | - |
| MVP-FL-139 | Monitoring & Analytics | Integrate error tracking (Sentry for crash reporting), analytics (Firebase Analytics or GA4 for user behavior), performance monitoring (Firebase Performance or custom metrics), user tracking (sessions, feature usage), dashboards (Grafana/Firebase Console), alerting (Slack/email on critical errors) | 📋 Not Started | P1 | Medium | Monitoring, Analytics | MVP-FL-138 | - |

---

## P2: Enhanced User Experience (IMPORTANT)

*Polish and advanced features for better usability*

| Task ID | Title | Description | Status | Priority | Effort | Skills | Dependencies | Details |
|---------|-------|-------------|--------|----------|--------|--------|--------------|---------|
| MVP-FL-140 | Dark Mode & Theming | Implement ThemeMode switcher (light/dark/system), custom theme builder with color palettes, user theme preferences with Riverpod state persistence, theme animation transitions, platform-adaptive themes (Material for Android, Cupertino for iOS) | 📋 Not Started | P2 | Medium | Flutter Theming, Material | MVP-FL-139 | - |
| MVP-FL-141 | Advanced Search & Filtering | Build global search widget (search across agencies, work items, agents), advanced filter builder with boolean logic (AND/OR), saved search queries, search suggestions (autocomplete), search history, faceted search (filter by multiple dimensions) | 📋 Not Started | P2 | High | Flutter, Search UX, State Mgmt | MVP-FL-140 | - |
| MVP-FL-142 | Notification System | Create notification center UI (inbox), real-time notifications (WebSocket/SSE), notification preferences (per notification type), push notifications (FCM for mobile), local notifications (flutter_local_notifications), notification history with read/unread states | 📋 Not Started | P2 | Medium | Flutter, FCM, local_notifications | MVP-FL-141 | - |
| MVP-FL-143 | Platform-Adaptive Experience | Optimize layouts using responsive breakpoints (mobile <600px, tablet 600-900px, desktop 900-1200px, wide >1200px), adaptive navigation (BottomNavigationBar on mobile, NavigationRail on tablet, Drawer on desktop), touch/mouse interactions, offline-first capabilities with local storage (sqflite, hive) | 📋 Not Started | P2 | High | Responsive Flutter, Offline-first | MVP-FL-142 | - |
| MVP-FL-144 | Accessibility Enhancements | Implement Semantics widgets for screen readers, keyboard navigation (focus traversal, shortcuts), screen reader support (TalkBack/VoiceOver testing), focus management (FocusNode, autofocus), high contrast mode, font scaling support, accessibility testing with Flutter DevTools | 📋 Not Started | P2 | Medium | Accessibility, Semantics | MVP-FL-143 | - |

---

## P2: Advanced Features (FUTURE ENHANCEMENT)

*Next-generation capabilities and integrations*

| Task ID | Title | Description | Status | Priority | Effort | Skills | Dependencies | Details |
|---------|-------|-------------|--------|----------|--------|--------|--------------|---------|
| MVP-FL-145 | A2A Protocol UI Integration | Build external agent discovery UI (browse A2A-compatible agents), agent card viewer (capabilities, trust score, SLA), task delegation interface (select agent, configure task), A2A agent monitoring (health, performance), trust score visualization (OAuth 2.0 integration) | 📋 Not Started | P2 | High | Flutter, Complex Data | MVP-FL-144 | - |
| MVP-FL-146 | Compliance Dashboard | Create compliance framework selector (GDPR, SOC2, HIPAA, ISO27001), policy visualization (compliance rules tree), compliance reports (PDF generation), audit trail viewer (filterable table), violation alerts (real-time notifications), remediation workflow (assign/track fixes) | 📋 Not Started | P2 | High | Flutter, Compliance UX, Reports | MVP-FL-145 | - |
| MVP-FL-147 | Advanced Analytics & Reporting | Build custom report builder (drag-and-drop metrics/dimensions), data visualization library with fl_chart (line, bar, area, pie, radar, scatter charts), export to various formats (PDF, Excel, CSV), scheduled reports (cron-like), dashboard templates library, KPI tracking with MetricCards, drill-down capabilities | 📋 Not Started | P2 | High | Flutter, fl_chart, Data Viz | MVP-FL-146 | - |
| MVP-FL-148 | Collaboration Features | Implement real-time collaborative editing (CRDT-based text editor), comments & mentions (@user notifications), activity feed (per agency/work item), user presence indicators (online/offline/typing), team chat integration (embedded or external link) | 📋 Not Started | P2 | High | Flutter, Streams, CRDT | MVP-FL-147 | - |

---

## Deprecated Tasks (From Old Structure)

The following task IDs from the previous MVP structure are deprecated and replaced by the new phased approach:

### Old P0 Work Items PoC (Replaced by Phase 3)
- ~~MVP-FL-006~~ Work Items State Management → Now part of MVP-FL-106
- ~~MVP-FL-007~~ Work Items Widgets → Now part of MVP-FL-106
- ~~MVP-FL-008~~ Work Items Screens & Integration → Now part of MVP-FL-106
- ~~MVP-FL-008A~~ Dashboard Layout Implementation → Integrated across phases
- ~~MVP-FL-008B~~ Dashboard Widgets Library → Integrated across phases

### Old P1 Agency Management (Replaced by Phases 2-5)
- ~~MVP-FL-012~~ Agency Designer - Overview Section → Split into MVP-FL-103-111
- ~~MVP-FL-013~~ Agency Designer - Roles & Teams → MVP-FL-107, MVP-FL-108
- ~~MVP-FL-014~~ Agency Designer - Configuration Panel → MVP-FL-111
- ~~MVP-FL-015~~ Agency Export Functionality → MVP-FL-116
- ~~MVP-FL-016~~ AI-Powered Agency Creator UI → MVP-FL-104-106 (AI features integrated)

### Old P1 Kanban (Replaced by Phase 7)
- ~~MVP-FL-017~~ Kanban Board Core UI → MVP-FL-120
- ~~MVP-FL-018~~ Work Item Detail Panel → MVP-FL-121
- ~~MVP-FL-019~~ Git Integration UI → MVP-FL-123
- ~~MVP-FL-020~~ Workflow Automation UI → MVP-FL-124

### Old P1 Agent Management (Replaced by Phase 8)
- ~~MVP-FL-021~~ Agent List & Monitoring View → MVP-FL-125
- ~~MVP-FL-022~~ Agent Detail Dashboard → MVP-FL-126
- ~~MVP-FL-023~~ Agent Creation Wizard → MVP-FL-127
- ~~MVP-FL-024~~ Real-time Agent Monitoring → MVP-FL-128

### Old P1 Property Broadcasting (Renumbered to Phase 9)
- ~~MVP-FL-025~~ Property Subscription UI → MVP-FL-129
- ~~MVP-FL-026~~ Real-time Map Visualization → MVP-FL-130
- ~~MVP-FL-027~~ Property Dashboard & Analytics → MVP-FL-131

### Old P1 Testing (Renumbered to Phase 10)
- ~~MVP-FL-028~~ Unit Testing Setup → MVP-FL-132
- ~~MVP-FL-029~~ Widget Testing Suite → MVP-FL-133
- ~~MVP-FL-030~~ Integration Testing → MVP-FL-134
- ~~MVP-FL-031~~ E2E Testing → MVP-FL-135

### Old P1 Deployment (Renumbered to Phase 11)
- ~~MVP-FL-032~~ Build Optimization → MVP-FL-136
- ~~MVP-FL-033~~ Docker & Web Deployment → MVP-FL-137
- ~~MVP-FL-034~~ CI/CD Pipeline → MVP-FL-138
- ~~MVP-FL-035~~ Monitoring & Analytics → MVP-FL-139

### Old P2 Enhanced UX (Renumbered)
- ~~MVP-FL-036~~ Dark Mode & Theming → MVP-FL-140
- ~~MVP-FL-037~~ Advanced Search & Filtering → MVP-FL-141
- ~~MVP-FL-038~~ Notification System → MVP-FL-142
- ~~MVP-FL-039~~ Platform-Adaptive Experience → MVP-FL-143
- ~~MVP-FL-040~~ Accessibility Enhancements → MVP-FL-144

### Old P2 Advanced Features (Renumbered)
- ~~MVP-FL-041~~ A2A Protocol UI Integration → MVP-FL-145
- ~~MVP-FL-042~~ Compliance Dashboard → MVP-FL-146
- ~~MVP-FL-043~~ Advanced Analytics & Reporting → MVP-FL-147
- ~~MVP-FL-044~~ Collaboration Features → MVP-FL-148

---

## Bugs and Issues

### Resolved Bugs

_(None yet)_

### Active Bugs

_(None)_

---

## Task Summary by Priority

### P0 (Blocking - Must Complete First)
- **Phase 1: Foundation**: 5 tasks ✅ COMPLETE (MVP-FL-001 through MVP-FL-005)
- **Authentication**: 3 tasks (MVP-FL-009 through MVP-FL-011)
- **Phase 2: Agency Selection**: 2 tasks (MVP-FL-101, MVP-FL-102)
- **Phase 3: Agency Designer Core**: 4 tasks (MVP-FL-103 through MVP-FL-106)
- **Phase 4: Agency Designer Advanced**: 5 tasks (MVP-FL-107 through MVP-FL-111)
- **Phase 5: Publishing & Tagging**: 5 tasks (MVP-FL-112 through MVP-FL-116)

**Total P0**: 24 tasks (5 completed, 19 remaining)

### P1 (Critical - Core Features)
- **Phase 6: Instance Management**: 3 tasks (MVP-FL-117 through MVP-FL-119)
- **Phase 7: Work Execution**: 5 tasks (MVP-FL-120 through MVP-FL-124)
- **Phase 8: Agent Management**: 4 tasks (MVP-FL-125 through MVP-FL-128)
- **Phase 9: Property Broadcasting**: 3 tasks (MVP-FL-129 through MVP-FL-131)
- **Phase 10: Testing**: 4 tasks (MVP-FL-132 through MVP-FL-135)
- **Phase 11: Deployment**: 4 tasks (MVP-FL-136 through MVP-FL-139)

**Total P1**: 23 tasks

### P2 (Important - Quality & Enhancement)
- **Enhanced UX**: 5 tasks (MVP-FL-140 through MVP-FL-144)
- **Advanced Features**: 4 tasks (MVP-FL-145 through MVP-FL-148)

**Total P2**: 9 tasks

**Grand Total Active Tasks**: 56 tasks (5 completed, 51 remaining)

---

## Implementation Sequence

### Phase 1: Foundation (Weeks 1-2) ✅ COMPLETE
1. ~~MVP-FL-001~~ - Flutter Project Setup ✅
2. ~~MVP-FL-002~~ - Design System Setup ✅
3. ~~MVP-FL-003~~ - Routing & Navigation ✅
4. ~~MVP-FL-004~~ - State Management ✅
5. ~~MVP-FL-005~~ - API Client Layer ✅

### Authentication (Week 3) - NEXT PRIORITY
6. MVP-FL-009 - Authentication State Management
7. MVP-FL-010 - Login & Registration Screens
8. MVP-FL-011 - Protected Routes & Permissions

### Phase 2: Agency Selection (Week 4)
9. MVP-FL-101 - Agency Selection Homepage
10. MVP-FL-102 - Create Agency Form

### Phase 3: Agency Designer Core (Weeks 5-8)
11. MVP-FL-103 - Agency Designer Navigation
12. MVP-FL-104 - Introduction Section
13. MVP-FL-105 - Goals Section
14. MVP-FL-106 - Work Items Section

### Phase 4: Agency Designer Advanced (Weeks 9-12)
15. MVP-FL-107 - Roles Section
16. MVP-FL-108 - RACI Matrix Section
17. MVP-FL-109 - Workflows Section
18. MVP-FL-110 - AI Policy Section
19. MVP-FL-111 - Admin & Configuration Section

### Phase 5: Publishing & Tagging (Weeks 13-15)
20. MVP-FL-112 - Publishing Toolbar & Validation
21. MVP-FL-113 - Publish & Activate Dialog
22. MVP-FL-114 - Tag Management UI
23. MVP-FL-115 - Versions Page
24. MVP-FL-116 - Export System UI

### Phase 6: Instance Management (Weeks 16-18)
25. MVP-FL-117 - Instance Creation UI
26. MVP-FL-118 - Instance List & Dashboard
27. MVP-FL-119 - Instance Lifecycle Controls

### Phase 7: Work Execution (Weeks 19-22)
28. MVP-FL-120 - Workbench Kanban Board
29. MVP-FL-121 - Issue Detail Panel
30. MVP-FL-122 - File Explorer UI
31. MVP-FL-123 - Git Integration UI
32. MVP-FL-124 - Workflow Automation UI

### Phase 8: Agent Management (Weeks 23-26)
33. MVP-FL-125 - Agent List & Monitoring View
34. MVP-FL-126 - Agent Detail Dashboard
35. MVP-FL-127 - Agent Creation Wizard
36. MVP-FL-128 - Real-time Agent Monitoring

### Phase 9: Property Broadcasting (Weeks 27-28)
37. MVP-FL-129 - Property Subscription UI
38. MVP-FL-130 - Real-time Map Visualization
39. MVP-FL-131 - Property Dashboard & Analytics

### Phase 10: Testing (Weeks 29-31)
40. MVP-FL-132 - Unit Testing Setup
41. MVP-FL-133 - Widget Testing Suite
42. MVP-FL-134 - Integration Testing
43. MVP-FL-135 - E2E Testing

### Phase 11: Deployment (Weeks 32-34)
44. MVP-FL-136 - Build Optimization
45. MVP-FL-137 - Docker & Web Deployment
46. MVP-FL-138 - CI/CD Pipeline
47. MVP-FL-139 - Monitoring & Analytics

### P2: Enhancements (Weeks 35+)
48. MVP-FL-140-148 - Enhanced UX & Advanced Features

---

## Architecture Notes

**Design Architecture**:
- See `/documents/2-SoftwareDesignAndArchitecture/flutter-designs/` for comprehensive design specs
  - `dashboard-design.md`: Complete dashboard architecture, MVVM pattern, component specs, file structure
  - `design-patterns.md`: Reusable widget patterns (StatCard, DataTable, Charts, Navigation)
  - `api-client.md`: API client architecture and patterns

**Backend Integration**:
- All backend APIs provided by CodeValdCortex (Go + ArangoDB)
- REST APIs with OpenAPI documentation
- WebSocket/SSE for real-time features
- JWT-based authentication

**Frontend Stack**:
- **Framework**: Flutter 3.x + Dart 3.x
- **State Management**: Riverpod (MVVM pattern)
- **Routing**: go_router
- **HTTP Client**: Dio with interceptors
- **UI**: Material Design 3
- **Charts**: fl_chart
- **Maps**: google_maps_flutter / flutter_map
- **Storage**: flutter_secure_storage, shared_preferences

**Platforms**:
- Web (primary deployment target)
- iOS (secondary)
- Android (secondary)
- Desktop (macOS, Windows, Linux - future)

**Responsive Breakpoints**:
- Mobile: <600px
- Tablet: 600-900px
- Desktop: 900-1200px
- Wide: >1200px

**Testing Strategy**:
- Unit tests: >80% coverage
- Widget tests: All major components
- Integration tests: Critical user flows
- E2E tests: Cross-platform validation
- Golden tests: UI regression prevention

**Deployment**:
- Web: Docker + Nginx
- Mobile: App Store (iOS), Play Store (Android)
- CI/CD: GitHub Actions
- Monitoring: Sentry + Firebase Analytics

---

**Note**: This document contains only active and pending tasks. All completed tasks are moved to `mvp_done.md` to maintain a clean, actionable backlog.
