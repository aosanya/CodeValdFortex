---
agent: agent
---

# Complete and Merge Current MVP Task

Follow the **mandatory completion process** for MVP tasks:

## Completion Process (MANDATORY)

1. **Update domain documentation file** with implementation details
   - **Locate your task** in `documents/3-SofwareDevelopment/mvp-details/`:
     - **Small domains** (2-4 tasks, <500 lines): Single file like `work-items-integration.md`
     - **Large domains** (5+ tasks, >500 lines): Folder with `README.md` + task files
   - **🔄 REFACTOR IF NEEDED**: If you encounter individual `MVP-XXX.md` files instead of domain documentation:
     - **Consolidate before completing**: Group related tasks into domain file/folder
     - This prevents documentation fragmentation and improves discoverability
     - Follow the folder structure guidelines below if domain is large
   - **Find task annotation**: Look for `<!-- MVP-XXX -->` markers
   - **Update task section** with:
     - Implementation decisions made
     - Code examples and patterns used
     - Any deviations from original plan (with rationale)
     - Links to created files and modules
     - Known limitations or future improvements
   - **Maintain narrative flow**: Updates should read naturally within the document
   - **Example update**:
     ```markdown
     <!-- MVP-WI-001 -->
     ## Gitea Webhook Integration (MVP-WI-001)
     
     The webhook integration was implemented using a pluggable architecture...
     
     **Implementation**: Created abstraction layer in `internal/infrastructure/webhooks/work/`
     with provider-agnostic interfaces. Gitea provider at `webhooks/gitea/` implements
     these interfaces, enabling easy addition of GitHub, GitLab, etc.
     
     **Key Files**:
     - `work/interfaces.go` - Core provider interfaces
     - `work/models.go` - Common data models
     - `gitea/models.go` - Gitea-specific transformations
     
     **Status**: ✅ Completed 2025-11-19
     
     **Coding Session**: [MVP-WI-001_gitea_webhook_integration](../coding_sessions/MVP-WI-001_gitea_webhook_integration.md)
     
     <!-- /MVP-WI-001 -->
     ```
   - **Add coding session reference table** at end of task section:
     ```markdown
     ### Implementation History
     
     | Date | Session | Summary |
     |------|---------|---------|
     | 2025-11-19 | [MVP-WI-001_gitea_webhook_integration](../coding_sessions/MVP-WI-001_gitea_webhook_integration.md) | Implemented pluggable webhook architecture with work abstraction layer and Gitea provider |
     ```
   - **Keep documentation consumable**: Easy to read, straightforward, well-organized
   - **Respect file size limits**:
     - **MAX 500 lines per file**: If domain file exceeds, refactor into folder structure
     - **Folder structure** for large domains:
       ```
       {domain-name}/
       ├── README.md              # Overview, architecture, navigation (MAX 300 lines)
       ├── task-1.md              # Individual task details (MAX 200 lines)
       ├── architecture/          # Detailed diagrams, flows
       └── examples/              # Code samples, configurations
       ```
     - If creating folder, move verbose content to subfolders, keep README.md concise
   - **Domain coherence**: Ensure your updates fit the narrative flow of the entire domain
   - **Cross-references**: Link to related tasks in the same domain if dependencies resolved
   - **Next steps**: If task unlocks follow-up work, mention it in narrative

2. **Create detailed coding session document** in `coding_sessions/` format: `{TaskID}_{description}.md`
   - Document all implementation details, decisions, and validation results
   - Include technical highlights, files created/modified, and dependencies unblocked

3. **Update architecture documentation if necessary**
   - If task introduced new architectural patterns, update `documents/2-SoftwareDesignAndArchitecture/`
   - Update relevant sections:
     - `general-architecture.md` for overall architecture changes
     - `frontend-architecture.md` for UI/template patterns
     - `backend-architecture.md` for data layer changes
   - Add new architecture decision records if significant design choices were made
   - Document new services, handlers, or repositories added

4. **Add completed task to `mvp_done.md`** with completion date
   - **KEEP IT CONCISE**: Add only one line to the summary table
   - Include: Task ID, Title, Completion Date, Coding Session Link, Brief Summary (1 sentence)
   - **DO NOT** add detailed technical highlights, validation results, or verbose descriptions
   - All technical details belong in the coding session document, not in mvp_done.md
   - Example entry:
     ```markdown
     | MVP-XX-YYY | Task Name | 2026-01-28 | [Session](coding_sessions/MVP-XX-YYY_task_name.md) | Brief one-sentence summary of what was implemented |
     ```

5. **Remove completed task from active `mvp.md` file**
   - Strike through the completed MVP-XXX in dependency lists (~~MVP-XXX~~)

6. **Update dependent task references**
   - Update all tasks that depended on this one to show ~~MVP-XXX~~

7. **ALWAYS remove all debug logs before merge (MANDATORY)**
   
   **Frontend JavaScript/TypeScript Logs (PRIMARY)**:
   - Search for and remove all `console.log()`, `console.debug()`, `console.warn()` statements
   - Remove MVP-XXX prefixed debug logs: `console.log('[MVP-XXX]'`, etc.
   - Remove emoji-prefixed debug logs: `console.log('🔍 DEBUG'`, `console.log('📊 Data:'`, etc.
   - **Handle multiline console statements**:
     ```javascript
     // ❌ Remove entire multiline statement:
     console.log('[MVP-XXX] Data:', 
         data, 
         'status:', status,
         'timestamp:', timestamp);
     ```
   - **Remove orphaned blocks**:
     ```javascript
     // ❌ BEFORE: Only used for logging
     if (response.debug) {
         console.log('[MVP-XXX] Debug info:', response.debug);
     }
     
     // ✅ AFTER: Remove entire conditional
     // [delete the entire if block]
     ```
   - **Remove debugging React useEffect hooks**:
     ```typescript
     // ❌ BEFORE: useEffect only for logging
     useEffect(() => {
       console.log('[MVP-XXX] Component mounted:', props);
     }, [props]);
     
     // ✅ AFTER: Remove entire useEffect
     // [delete the entire useEffect block]
     ```
   - Search patterns to check:
     - `grep -r "console.log" src/`
     - `grep -r "console.debug" src/`
     - `grep -r "console.warn" src/`
     - `grep -r "console.log.*\[MVP-" src/`
     - `grep -r "🔍\|📊\|💾\|🔹\|✅\|⚠️" src/` (emoji indicators often mean debug logs)
   - Keep only `console.error()` for actual error handling
   - **After cleanup, verify**:
     ```bash
     # Check for orphaned imports
     grep -r "import.*useState.*useEffect" src/ | grep -v "// eslint"
     
     # Ensure no debug-only variables remain
     npm run lint
     npm run type-check  # or tsc --noEmit
     ```
   
   **Backend Go Logs (if modifying CodeValdCortex)**:
   - Search for and remove all debug `fmt.Printf()`, `fmt.Println()` statements
   - Remove MVP-XXX prefixed debug logs: `log.Printf("[MVP-XXX]`, `fmt.Printf("MVP-XXX-DEBUG:`, etc.
   - Remove emoji-prefixed debug logs: `🔍 DEBUG [`, `📊 BEFORE UPDATE`, `💾 Saved workflow`, `🔹 Workflow[`, etc.
   - Remove detailed trace logs with object dumps and state inspection
   - **Automated removal tool** (for log.Printf with [MVP-XXX] pattern):
     ```bash
     # Edit scripts/remove-mvp-logs-v2.py to update the files list, then run:
     python3 scripts/remove-mvp-logs-v2.py
     # This properly handles multiline log.Printf statements by tracking parentheses
     ```
   - Search patterns to verify removal:
     - `grep -r "fmt.Printf" internal/ cmd/` (should only show essential production logs)
     - `grep -r "log.Printf.*\[MVP-" internal/` (should return no results)
     - `grep -r "🔍\|📊\|💾\|🔹\|✅\|⚠️" internal/ cmd/` (emoji indicators often mean debug logs)
     - `grep -r "DEBUG \[" internal/ cmd/`
   
   **CRITICAL: Handle Multiline Logs Properly**:
   - **Multiline log statements** span multiple lines and MUST be removed completely:
     ```go
     // ❌ Remove entire multiline statement (all 4 lines):
     log.Printf("[MVP-XXX] Complex data: %+v, status: %s, count: %d",
         complexObject,
         statusValue,
         itemCount)
     ```
   - **Look for continuation patterns**: Logs with trailing commas, unclosed parentheses
   - **Use automated tools** that track parentheses matching (like `remove-mvp-logs-v2.py`)
   - **Manual check**: Ensure no orphaned lines remain after log removal
   
   **CRITICAL: Remove Orphaned Constructs**:
   - **After removing logs, check for orphaned code blocks**:
     ```go
     // ❌ BEFORE: Loop only for debug logging
     for i, item := range items {
         log.Printf("[MVP-XXX] Item %d: %+v", i, item)
     }
     
     // ✅ AFTER: Remove entire loop (orphaned construct)
     // [delete the entire for loop block]
     ```
   - **Check for orphaned variables**:
     ```go
     // ❌ BEFORE: Variable only used in debug log
     debugInfo := fmt.Sprintf("Status: %s", status)
     log.Printf("[MVP-XXX] %s", debugInfo)
     
     // ✅ AFTER: Remove both variable and log
     // [delete both lines]
     ```
   - **Check for orphaned conditionals**:
     ```go
     // ❌ BEFORE: If block only for logging
     if len(results) > 0 {
         log.Printf("[MVP-XXX] Found %d results", len(results))
     }
     
     // ✅ AFTER: Remove entire conditional
     // [delete the entire if block]
     ```
   - **Check for orphaned imports**:
     ```go
     // If "log" package only used for debug logs, remove import
     import (
         "fmt"  // ❌ Remove if only used for debug Printf
         "log"  // ❌ Remove if only used for debug logs
     )
     ```
   
   **Post-Cleanup Validation**:
   - **Run `npm run lint`** - Will catch unused variables, imports, console statements
   - **Run `npm run format`** - Clean up formatting with Prettier
   - **Run `npm run type-check`** or `tsc --noEmit` - Verify TypeScript types
   - **Verify build**: `npm run build` must succeed
   - **Manual file review**: Scan files that had logs removed for:
     - Orphaned variable declarations
     - Empty useEffect hooks
     - Unused function parameters that were only logged
     - Comments referring to removed debug statements
   
   **Backend Go Logs (CodeValdCortex only)**:
   - Search for and remove all `console.log()`, `console.warn()` statements in JavaScript files
   - **Handle multiline console statements**:
     ```javascript
     // ❌ Remove entire multiline statement:
     console.log('[MVP-XXX] Data:', 
         data, 
         'status:', status,
         'timestamp:', timestamp);
     ```
   - **Remove orphaned blocks**:
     ```javascript
     // ❌ BEFORE: Only used for logging
     if (response.debug) {
         console.log('[MVP-XXX] Debug info:', response.debug);
     }
     
     // ✅ AFTER: Remove entire conditional
     // [delete the entire if block]
     ```
   - Search patterns to check:
     - `grep -r "console.log" static/js/`
     - `grep -r "console.warn" static/js/`
     - `grep -r "console.log.*\[MVP-" internal/web/` (check templ files)
   - Keep only `console.error()` for actual error handling
   
   **General Rules**:
   - Remove TODO comments that reference debug logging
   - Remove comments like `// Debug:`, `// TODO: remove after testing`, etc.
   - Keep only essential production logging (errors, critical warnings)
   - **After cleanup, verify**:
     ```bash
     # Check for common orphaned patterns
     npm run lint                          # Unused vars, imports, console.log
     npm run type-check                    # TypeScript errors
     npm run build                         # Still builds successfully
     grep -r "console\.log" src/          # Should only be in error handlers
     ```
   - **Test the application after removing logs to ensure nothing breaks**
   - This is MANDATORY - no debug logs should remain in merged code

8. **Prepare next task (if applicable)**
   - Identify the next priority task from `mvp.md`
   - Check if `documents/3-SofwareDevelopment/mvp-details/MVP-XXX.md` exists for next task
   - **If details file doesn't exist for next task:**
     - Search `documents/2-SoftwareDesignAndArchitecture/` for relevant context
     - Review similar tasks in `documents/3-SofwareDevelopment/coding_sessions/`
     - Create new `MVP-XXX.md` in `mvp-details/` folder using the template:
       ```markdown
       # MVP-XXX: [Task Title]
       
       ## Overview
       **Priority**: [P0/P1/P2]  
       **Effort**: [Low/Medium/High]  
       **Skills Required**: [List skills]  
       **Dependencies**: [MVP-XXX, MVP-YYY]  
       **Status**: Not Started
       
       ## Description
       [Detailed description from mvp.md or architecture docs]
       
       ## Objectives
       - [Key objective 1]
       - [Key objective 2]
       
       ## Requirements
       [Functional and technical requirements]
       
       ## Acceptance Criteria
       - [ ] [Criterion 1]
       - [ ] [Criterion 2]
       
       ## Technical Specifications
       [Implementation details, architecture decisions]
       ```

9. **Fix all linting issues before merge**
   - Run `npm run lint` and fix ALL errors and warnings (must show 0 issues)
   - Run `npm run format` to ensure consistent code formatting with Prettier
   - Run `npm run type-check` or `tsc --noEmit` to verify TypeScript types
   - Use IDE quick fixes or manual resolution for all diagnostics
   - Common issues to address:
     - Unused imports or variables
     - Missing type annotations
     - Any type usage (avoid unless absolutely necessary)
     - React hooks dependencies (useEffect, useMemo, useCallback)
     - Missing error handling in async functions
     - ESLint rule violations

10. **Merge to main after testing validation**
   - Ensure all debug logs removed (no console.log/debug/warn)
   - Ensure `npm run lint` shows 0 issues
   - Ensure `npm run format` has been run
   - Ensure `npm run type-check` passes with no TypeScript errors
   - All tests passing: `npm test` (if applicable)
   - Build succeeds: `npm run build`
   - Performance requirements met (if applicable)

## Git Workflow

```bash
# Before merge - validation and cleanup
npm run lint       # Fix ALL issues until output is clean
npm run format     # Format all code with Prettier
npm run type-check # Verify TypeScript types (or tsc --noEmit)
npm test           # Run tests (if applicable)
npm run build      # Ensure production build succeeds

# CRITICAL: Commit implementation code FIRST
git add src/ public/ package.json
git commit -m "Implement MVP-XXX: [Description]

- Key implementation detail 1
- Key implementation detail 2
- Remove all debug console.log statements
- Fix all lint issues
"

# Then commit documentation updates
git add documents/ .github/
git commit -m "Complete MVP-XXX: Update task tracking and documentation"

# Merge when complete and tested
git checkout dev
git merge feature/MVP-XXX_description --no-ff -m "Merge MVP-XXX: [Description]"
git branch -d feature/MVP-XXX_description
```

## Success Criteria
- ✅ Coding session document created in `documents/3-SofwareDevelopment/coding_sessions/`
- ✅ Architecture documentation updated in `documents/2-SoftwareDesignAndArchitecture/` (if needed, really try, approach changes during implementation.)
- ✅ Entry added to `mvp_done.md` with date and full details
- ✅ Task removed from active `mvp.md`
- ✅ Dependencies updated with strikethrough
- ✅ Next task details file created in `mvp-details/` (if missing)
- ✅ **ALWAYS: All debug logs removed (no console.log/debug/warn)**
- ✅ **Implementation code committed before documentation**
- ✅ All linting issues resolved (npm run lint shows 0 errors/warnings)
- ✅ Code formatted with Prettier (npm run format)
- ✅ TypeScript types valid (npm run type-check passes)
- ✅ Build succeeds (npm run build)
- ✅ All tests pass: `npm test` (if applicable)
- ✅ Performance requirements met (if applicable)
- ✅ Merged to main and feature branch deleted