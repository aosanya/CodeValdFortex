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

2. **Read detailed specification**
   - **Task details in mvp-details/**: Each task has a dedicated file like `mvp-details/MVP-FE-XXX.md`
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
- [ ] Read task specification file: `documents/3-SofwareDevelopment/mvp-details/MVP-FE-XXX.md`
- [ ] Feature branch created: `feature/MVP-FE-XXX_description`
  - [ ] CodeValdFortex: `feature/MVP-FE-XXX_description` created (PRIMARY - always)
  - [ ] CodeValdCortex: `feature/MVP-FE-XXX_description` created (ONLY if backend dependency exists)
- [ ] Reviewed code quality standards in rules.instructions.md
- [ ] Todo list created with implementation steps
- [ ] Understand acceptance criteria and validation requirements

## Domain Documentation Approach

**Structure**: Each task has a dedicated specification file in `documents/3-SofwareDevelopment/mvp-details/MVP-FE-XXX.md`

**Task File Template**:
```markdown
# MVP-FE-XXX: Task Title

## Overview
**Priority**: P0/P1/P2  
**Effort**: Low/Medium/High  
**Skills**: React, TypeScript, etc.  
**Dependencies**: MVP-FE-YYY (if any)

Brief description of what this task accomplishes...

## Requirements
1. Functional requirement 1
2. Functional requirement 2
...

## Technical Specifications
### Architecture
- Component structure
- State management approach
- API integrations

### Implementation Details
- Specific technical requirements
- Libraries/tools to use
- Performance considerations

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
2. Navigate to `documents/3-SofwareDevelopment/mvp-details/MVP-FE-XXX.md` for detailed specs
3. Review requirements, technical specifications, and acceptance criteria

## Development Standards

**Code Quality:**
- Run `npm run lint` before committing
- Run `npm run format` for consistent formatting with Prettier
- Use TypeScript strict mode (no `any` types without justification)
- Mark variables as `const` if never reassigned
- Remove all `console.log()` statements (use proper logging in production)

**Logging (if needed):**
- Prefix all logs with task ID: `MVP-XXX-INFO:`, `MVP-XXX-ERROR:`
- Remove debug logs before committing
- Use environment-based logging (only in development)

**Testing:**
- Write tests for business logic (Vitest)
- Run `npm test` before completion
- Test component rendering with React Testing Library

## Git Workflow

**Branch Strategy:**
- `main` - Stable production branch (merge from `dev` periodically)
- `dev` - Active development integration branch (merge feature branches here)
- `feature/MVP-FE-XXX` - Individual task branches (created from `dev`)

```bash
# Start new task - Create feature branch in Fortex (always)
# CodeValdFortex (PRIMARY - always create branch here)
cd /workspaces/CodeValdFortex
git checkout dev
git pull origin dev  # Ensure latest dev changes
git checkout -b feature/MVP-FE-XXX_description

# CodeValdCortex (OPTIONAL - only if backend dependency)
# Only create if task requires backend changes
# cd /workspaces/CodeValdCortex
# git checkout dev
# git pull origin dev
# git checkout -b feature/MVP-FE-XXX_description

# Regular development commits (in Fortex)
cd /workspaces/CodeValdFortex
npm run lint    # Ensure code quality
npm run format  # Format code
git add .
git commit -m "Descriptive message"

# When task complete - merge to dev (use "Complete Branch" prompt)
# Feature branches merge to dev, not main
git checkout dev
git merge feature/MVP-FE-XXX_description --no-ff
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
- **Frontend changes (React, TypeScript, UI components) → CodeValdFortex** (PRIMARY)
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
