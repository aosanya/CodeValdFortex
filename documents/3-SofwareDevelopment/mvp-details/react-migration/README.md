# Flutter Migration Domain

**Domain**: Frontend Architecture Migration  
**Status**: Planning Phase  
**Priority**: P1 (Strategic Foundation)  
**Estimated Timeline**: 8-10 weeks

---

## Domain Overview

This domain covers the complete migration from the current Templ+HTMX+Alpine.js frontend to a **Flutter** cross-platform application called **CodeValdFortex**. The migration addresses critical architectural concerns around separation of concerns, scalability, and maintainability while enabling web, mobile, and desktop deployment from a single codebase.

### Problem Statement

**Current Issues:**
- **Backend Bloat**: Presentation layer logic mixed with business logic in Go handlers
- **Tight Coupling**: Templ templates tightly coupled to Go backend
- **Limited Tooling**: Alpine.js/HTMX ecosystem lacks robust modern tooling
- **Platform Limitations**: Web-only, no native mobile/desktop support
- **Scalability Concerns**: Difficult to maintain as complexity grows

**Solution:**
- **Thin Go API Backend**: Pure REST API exposing business logic (CodeValdCortex)
- **Flutter Cross-Platform Frontend**: All UI/presentation logic in CodeValdFortex
- **Multi-Platform**: Single codebase for Web, iOS, Android, Desktop
- **Clear Separation**: Backend = data/orchestration, Frontend = user experience
- **Incremental Migration**: Domain-by-domain rollout to minimize risk

---

## Architecture Overview

### System Architecture

```
Development Container:
/workspaces/
├── CodeValdCortex/          (Go Backend - REST API)
│   ├── internal/api/        (NEW: REST API handlers)
│   └── internal/{domain}/   (Business logic)
│
└── CodeValdFortex/          (Flutter Frontend - Cross-Platform)
    ├── lib/features/        (Feature modules)
    ├── lib/widgets/         (Reusable widgets)
    ├── lib/services/        (API client, state)
    └── lib/models/          (Data models)

Runtime:
┌──────────────┐     HTTP     ┌──────────────┐
│CodeValdFortex│ ◄───────────►│CodeValdCortex│
│ (Flutter App)│  REST API    │  (Go Backend)│
│ Web/Mobile/  │              │  Port: 8080  │
│  Desktop     │              │              │
└──────────────┘              └──────────────┘
                                     │
                                     ▼
                              ┌──────────────┐
                              │   ArangoDB   │
                              └──────────────┘
```

---

## Migration Phases

### Phase 1: Foundation & Work Items PoC (Weeks 1-5)
**Goal**: Prove Flutter + Go API architecture works  
**Scope**: Work Items domain (list, create, edit, delete)
**Platform**: Web (primary), iOS/Android (stretch)

### Phase 2: Agent Cards (Weeks 6-8)
**Goal**: Migrate agent management UI  
**Scope**: Agent list, detail cards, actions, real-time status
**Platform**: Web + Mobile

### Phase 3: Agency Dashboard (Weeks 9-12)
**Goal**: Migrate agency overview  
**Scope**: Statistics, metrics, quick actions, charts
**Platform**: Web + Mobile + Tablet optimizations

### Phase 4+: Advanced Domains
- Workflow Designer (visual canvas with gestures)
- AI Policy Wizard
- Authentication & User Management
- Offline-first capabilities

---

## Technology Stack

| Category | Technology | Purpose |
|----------|-----------|---------|
| **Framework** | Flutter 3.24+ | Cross-platform UI framework |
| **Language** | Dart 3.5+ | Type-safe language |
| **State** | Riverpod 2.x / Bloc 8.x | State management |
| **HTTP** | Dio 5.x | API requests & interceptors |
| **Routing** | go_router 14.x | Declarative routing |
| **Storage** | shared_preferences, hive | Local storage |
| **DI** | get_it, riverpod | Dependency injection |
| **Backend** | Go 1.21+ | REST API |
| **API Framework** | Gin 1.9+ | HTTP routing |

---

## Task Index

### Phase 1: Foundation & Work Items PoC

**Infrastructure Setup:**
- [MVP-FL-001: Flutter Project Setup](./MVP-FL-001_project_setup.md) - Initialize Flutter app
- [MVP-FL-002: Backend API Infrastructure](./MVP-FL-002_backend_api.md) - Create internal/api package structure

**Work Items Domain:**
- [MVP-FL-003: Work Items REST API](./MVP-FL-003_work_items_api.md) - Implement Work Items API endpoints
- [MVP-FL-004: Work Items State Management](./MVP-FL-004_work_items_state.md) - Riverpod/Bloc providers
- [MVP-FL-005: Work Items Widgets](./MVP-FL-005_work_items_widgets.md) - Flutter widgets (list, card, form)

**Testing & Deployment:**
- [MVP-FL-006: Testing Suite](./MVP-FL-006_testing.md) - Widget, integration, golden tests
- [MVP-FL-007: Web & Mobile Deployment](./MVP-FL-007_deployment.md) - Web build, app stores

### Phase 2: Agent Cards (Future)
- MVP-FL-008: Agent REST API
- MVP-FL-009: Agent Widgets
- MVP-FL-010: Real-time Status (WebSockets/Stream)

### Phase 3: Agency Dashboard (Future)
- MVP-FL-011: Dashboard API
- MVP-FL-012: Dashboard Widgets
- MVP-FL-013: Charts with fl_chart

---

## Success Metrics

### Technical Metrics
- API response time <100ms (95th percentile)
- App size: Web <2MB (gzipped), Mobile <15MB (APK/IPA)
- 60 FPS rendering on all platforms
- Test coverage >80%
- Zero critical security vulnerabilities

### User Experience Metrics
- App launch time <3 seconds (cold start)
- UI responsiveness: 60 FPS animations
- Works on Web, iOS, Android from single codebase
- Native platform feel (Material/Cupertino)

### Business Metrics
- Feature parity with Templ version
- Zero data loss during migration
- <1% error rate in production
- Positive user feedback
- Team velocity maintained or improved

---

## Risk Mitigation

**High Risks:**
1. **Performance Degradation** → Code splitting, performance budgets, monitoring
2. **Data Consistency** → Thorough testing, transaction handling, rollback procedures
3. **Auth/Session Handling** → CORS testing, graceful error handling

**Medium Risks:**
1. **Developer Learning Curve** → Training, pair programming, documentation
2. **Deployment Complexity** → Automation, Docker, CI/CD pipeline

---

## Development Workflow

### Running Both Systems
```bash
# Terminal 1 - Go Backend
cd /workspaces/CodeValdCortex
make run  # http://localhost:8080

# Terminal 2 - Flutter Frontend (Web)
cd /workspaces/CodeValdFortex
flutter run -d chrome

# Or for mobile (iOS/Android emulator)
flutter run -d ios
flutter run -d android
```

### Branch Management
```bash
# Create feature branch in BOTH repos
cd /workspaces/CodeValdCortex
git checkout dev
git checkout -b feature/MVP-FL-XXX_description

cd /workspaces/CodeValdFortex
git checkout dev
git checkout -b feature/MVP-FL-XXX_description
```

---

## References

- **Main Plan**: `/documents/2-SoftwareDesignAndArchitecture/flutter-migration-plan.md`
- **Backend Architecture**: `/documents/2-SoftwareDesignAndArchitecture/backend-architecture.md`
- **Current Frontend**: `/documents/2-SoftwareDesignAndArchitecture/frontend-architecture-updated.md`
- **Flutter Docs**: https://docs.flutter.dev
- **Dart Docs**: https://dart.dev/guides

---

**Last Updated**: January 27, 2026  
**Next Review**: End of Phase 1 (Week 5)
