---
agent: agent
---

# Start New Task

Follow the **mandatory task startup process** for project tasks:

## Task Startup Process (MANDATORY)

1. **Select next task from `documents/3-SofwareDevelopment/mvp.md`**
   - Choose based on priority (P0 → P1 → P2)
   - Verify all dependencies are completed (marked with ✅ Completed)
   - Check task is "📋 Not Started" status

2. **Check for mvp.md inconsistencies (MANDATORY)**
   - **Verify dependency notation convention**:
     - Active dependencies: `MVP-XXX` (plain text)
     - Completed dependencies: `~~MVP-XXX~~ ✅` (strikethrough + checkmark)
     - Check if any completed tasks referenced without strikethrough
   - **Verify priority alignment**:
     - All tasks in P0 sections must have Priority = P0
     - All tasks in P1 sections must have Priority = P1
     - All tasks in P2 sections must have Priority = P2
   - **Verify task counts**:
     - Count tasks in each priority section
     - Compare with summary table at bottom of mvp.md
     - Update if mismatched
   - **Verify deprecated tasks**:
     - Check for tasks with ⚠️ Deprecated status outside "Deprecated" section
     - Check for active tasks that should be deprecated
   - **Verify cross-references with Cortex**:
     - Check cleanup task dependencies (Fortex MVP-FL-XXX in production)
     - Ensure referenced Cortex tasks exist and have correct status
   - **Fix any inconsistencies found before starting implementation**
   - Document any changes made in commit message

3. **Read detailed specification**
   - **Task details in mvp-details/**: Each task has a dedicated file like `mvp-details/MVP-FL-XXX.md`
   - Tasks follow standardized template with overview, requirements, technical specifications, and acceptance criteria
   - Review all requirements, acceptance criteria, and technical specifications
   - Understand dependencies and integration points with other features

3. **Create feature branch**
   - **🚨 ALWAYS branch from `dev`, NOT `main`**
   - Use exact format: `feature/MVP-XXX_description`
   - Description should be lowercase with underscores
   - **🚨 PRIMARY FOCUS: CodeValdFortex**:
     ```bash
     # For CodeValdFortex (PRIMARY - always create)
     cd /workspaces/CodeValdFortex
     git checkout dev
     git pull origin dev  # Ensure latest dev changes
     git checkout -b feature/MVP-XXX_description
     
     # For CodeValdCortex (ONLY if task has backend dependency)
     # Check task spec - only create if backend changes required
     cd /workspaces/CodeValdCortex
     git checkout dev
     git pull origin dev  # Ensure latest dev changes
     git checkout -b feature/MVP-XXX_description
     ```
   - **Fortex-first approach**: Most tasks are frontend-only in CodeValdFortex
   - Only create Cortex branch if task explicitly requires backend changes (API, database, Go code)
   - **Branch hierarchy**: `main` (stable) ← `dev` (integration) ← `feature/MVP-XXX` (your work)

4. **Read project guidelines**
   - Review `.github/instructions/rules.instructions.md`
   - Follow code quality standards (ESLint, Prettier)
   - Follow linting rules (TypeScript strict mode, no console.log in production)
   - Remember logging standards (MVP-XXX prefix for development)

5. **Create todo list**
   - Break down task into actionable steps
   - Use manage_todo_list tool to track progress
   - Mark items in-progress and completed as you work

## Pre-Implementation Checklist

Before starting implementation:
- [ ] Task selected from documents/3-SofwareDevelopment/mvp.md based on priority and dependencies
- [ ] All dependency tasks are completed (✅ Completed)
- [ ] Read task specification file: `documents/3-SofwareDevelopment/mvp-details/MVP-FL-XXX.md`
- [ ] Feature branch created: `feature/MVP-FL-XXX_description`
  - [ ] CodeValdFortex: `feature/MVP-FL-XXX_description` created (PRIMARY - always)
  - [ ] CodeValdCortex: `feature/MVP-FL-XXX_description` created (ONLY if backend dependency exists)
- [ ] Reviewed code quality standards in rules.instructions.md
- [ ] Todo list created with implementation steps
- [ ] Understand acceptance criteria and validation requirements

## Domain Documentation Approach

**Structure**: Each task has a dedicated specification file in `documents/3-SofwareDevelopment/mvp-details/MVP-FL-XXX.md`

**Design Architecture Reference**: When creating new task details, consult the design specifications in `/documents/2-SoftwareDesignAndArchitecture/flutter-designs/`:
- `dashboard-design.md`: Dashboard architecture, MVVM pattern, widget component hierarchy, file structure
- `design-patterns.md`: Reusable widget patterns (StatCard, MetricCard, ChartCard, DataTable, Navigation)
- `sign-in-design.md`: Authentication UI specifications, form patterns, dual login methods
- Reference these specs for:
  - Widget component structure and naming conventions
  - MVVM architecture patterns (ViewModels, Repositories, Models)
  - Responsive design breakpoints (Mobile: <600px, Tablet: 600-900px, Desktop: 900-1200px, Wide: >1200px)
  - Theme configuration and Material Design guidelines
  - File organization and component splitting (500-line limit per file)
  - Required packages and dependencies (riverpod, fl_chart, go_router, etc.)

**Task File Template**:
```markdown
# MVP-FL-XXX: Task Title

## Overview
**Priority**: P0/P1/P2  
**Effort**: Low/Medium/High  
**Skills**: Flutter, Dart, etc.  
**Dependencies**: MVP-FL-YYY (if any)

Brief description of what this task accomplishes...

## Requirements
1. Functional requirement 1
2. Functional requirement 2
...

## Technical Specifications
### Architecture
- Component structure (refer to design specs for widget hierarchy)
- State management approach (MVVM with Riverpod/Provider per architecture)
- API integrations
- Reference relevant design documents:
  - Widget patterns from `2-SoftwareDesignAndArchitecture/flutter-designs/design-patterns.md`
  - Layout structure from `2-SoftwareDesignAndArchitecture/flutter-designs/dashboard-design.md`

### Implementation Details
- Specific technical requirements
- Libraries/tools to use (check design specs for package dependencies)
- Performance considerations
- File structure following 500-line component limit
- Responsive breakpoints: Mobile (<600px), Tablet (600-900px), Desktop (900-1200px), Wide (>1200px)

## Acceptance Criteria
- [ ] Criterion 1
- [ ] Criterion 2
...

## Testing Requirements
- Unit tests
- Integration tests
- E2E test scenarios
```

**Finding Tasks**:
1. Check `documents/3-SofwareDevelopment/mvp.md` for task overview
2. Navigate to `documents/3-SofwareDevelopment/mvp-details/MVP-FL-XXX.md` for detailed specs
3. Review requirements, technical specifications, and acceptance criteria

## Development Standards

**Code Quality:**
- Run `flutter analyze` before committing
- Run `dart format .` for consistent formatting
- Use Dart type safety (avoid `dynamic` without justification)
- Mark variables as `final` if never reassigned
- Remove all `print()` statements (use proper logging in production)

**Logging (if needed):**
- Prefix all logs with task ID: `MVP-XXX-INFO:`, `MVP-XXX-ERROR:`
- Remove debug logs before committing
- Use environment-based logging (only in development)

**Testing:**
- Write tests for business logic (Flutter Test)
- Run `flutter test` before completion
- Test widget rendering with Widget Tests

## Git Workflow

**Branch Strategy:**
- `main` - Stable production branch (merge from `dev` periodically)
- `dev` - Active development integration branch (merge feature branches here)
- `feature/MVP-FL-XXX` - Individual task branches (created from `dev`)

```bash
# Start new task - Create feature branch in Fortex (always)
# CodeValdFortex (PRIMARY - always create branch here)
cd /workspaces/CodeValdFortex
git checkout dev
git pull origin dev  # Ensure latest dev changes
git checkout -b feature/MVP-FL-XXX_description

# CodeValdCortex (OPTIONAL - only if backend dependency)
# Only create if task requires backend changes
# cd /workspaces/CodeValdCortex
# git checkout dev
# git pull origin dev
# git checkout -b feature/MVP-FL-XXX_description

# Regular development commits (in Fortex)
cd /workspaces/CodeValdFortex
flutter analyze  # Ensure code quality
dart format .    # Format code
git add .
git commit -m "Descriptive message"

# When task complete - merge to dev (use "Complete Branch" prompt)
# Feature branches merge to dev, not main
git checkout dev
git merge feature/MVP-FL-XXX_description --no-ff
git push origin dev

# Periodically: dev → main (for releases/milestones)
# This is done separately, not per task
git checkout main
git merge dev --no-ff
git push origin main
```

**Multi-Repo Notes:**
- **PRIMARY WORKSPACE: CodeValdFortex** - Most tasks are frontend-only
- **ALWAYS branch from `dev`**, never from `main`
- **Frontend changes (Flutter, Dart, UI widgets) → CodeValdFortex** (PRIMARY)
- **Backend changes (Go, APIs, database) → CodeValdCortex** (ONLY if needed)
- Only work in CodeValdCortex if task explicitly requires:
  - New API endpoints or modifications
  - Database schema changes
  - Go backend logic changes
  - Backend service updates
- If task spans both repos (rare), create matching feature branches and keep synchronized
- Merge completed features to `dev` branch
- `dev` → `main` merges happen at milestones (not per task)

## Success Criteria
- ✅ Next priority task identified with all dependencies met
- ✅ Specification document reviewed and understood
- ✅ Feature branch created with correct naming
- ✅ Todo list created for tracking implementation
- ✅ Ready to begin implementation following project standards
