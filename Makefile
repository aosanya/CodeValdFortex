# CodeValdFortex Makefile
# React/TypeScript Frontend Application

# Build information
VERSION ?= $(shell git describe --tags --always --dirty)
BUILD_TIME ?= $(shell date -u +%Y-%m-%dT%H:%M:%SZ)
GIT_COMMIT ?= $(shell git rev-parse HEAD)

# Node/npm parameters
NPM = npm
NODE = node
BUILD_DIR = dist
NODE_MODULES = node_modules

# Docker parameters
DOCKER_REGISTRY ?= ghcr.io
DOCKER_IMAGE ?= $(DOCKER_REGISTRY)/aosanya/codevaldfortex
DOCKER_TAG ?= $(VERSION)

.PHONY: help
help: ## Show this help message
	@echo 'Usage: make [target]'
	@echo ''
	@echo 'Targets:'
	@awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z_-]+:.*?## / {printf "  %-15s %s\n", $$1, $$2}' $(MAKEFILE_LIST)

.PHONY: install
install: ## Install dependencies
	@echo "Installing dependencies..."
	$(NPM) install

.PHONY: build
build: ## Build the application for production
	@echo "Building CodeValdFortex..."
	$(NPM) run build

.PHONY: dev
dev: ## Run development server with hot reload
	@echo "Starting development server..."
	@echo "💡 Tip: Application will open at http://localhost:5173"
	$(NPM) run dev

.PHONY: preview
preview: build ## Preview production build locally
	@echo "Previewing production build..."
	$(NPM) run preview

.PHONY: test
test: ## Run tests
	@echo "Running tests..."
	$(NPM) test

.PHONY: test-coverage
test-coverage: ## Run tests with coverage report
	@echo "Running tests with coverage..."
	$(NPM) run test:coverage

.PHONY: test-ui
test-ui: ## Run tests in UI mode
	@echo "Running tests in UI mode..."
	$(NPM) run test:ui

.PHONY: clean
clean: ## Clean build artifacts and dependencies
	@echo "Cleaning..."
	rm -rf $(BUILD_DIR)
	rm -rf $(NODE_MODULES)
	rm -f .eslintcache

.PHONY: lint
lint: ## Run ESLint
	@echo "Running ESLint..."
	$(NPM) run lint

.PHONY: lint-fix
lint-fix: ## Run ESLint with auto-fix
	@echo "Running ESLint with auto-fix..."
	$(NPM) run lint -- --fix

.PHONY: format
format: ## Format code with Prettier
	@echo "Formatting code..."
	$(NPM) run format

.PHONY: format-check
format-check: ## Check code formatting
	@echo "Checking code formatting..."
	$(NPM) run format:check

.PHONY: type-check
type-check: ## Run TypeScript type checking
	@echo "Running TypeScript type checker..."
	$(NPM) run type-check

.PHONY: check
check: lint type-check test ## Run all checks (lint, type-check, test)
	@echo "✅ All checks passed!"

.PHONY: audit
audit: ## Audit code for debug logs (console.log, console.debug, etc.)
	@echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
	@echo "🔍 CODE AUDIT - Debug Log Detection"
	@echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
	@echo ""
	@echo "📊 1. CONSOLE.LOG STATEMENTS"
	@echo "────────────────────────────────────────"
	@if grep -rn "console\.log\|console\.debug\|console\.warn" src/ --include="*.ts" --include="*.tsx" --include="*.js" --include="*.jsx" 2>/dev/null | grep -v "console.error" | grep -v "// eslint-disable"; then \
		echo "⚠️  Found console.log/debug/warn statements (remove before merge)"; \
	else \
		echo "✅ No debug console statements found"; \
	fi
	@echo ""
	@echo "📊 2. MVP-PREFIXED DEBUG LOGS"
	@echo "────────────────────────────────────────"
	@if grep -rn "console.*\[MVP-\|console.*'MVP-\|console.*\"MVP-" src/ --include="*.ts" --include="*.tsx" --include="*.js" --include="*.jsx" 2>/dev/null; then \
		echo "⚠️  Found MVP-prefixed debug logs (remove before merge)"; \
	else \
		echo "✅ No MVP-prefixed console logs found"; \
	fi
	@echo ""
	@echo "📊 3. EMOJI-PREFIXED DEBUG LOGS"
	@echo "────────────────────────────────────────"
	@if grep -rn '🔍\|📊\|💾\|🔹\|✅\|⚠️\|🚀\|🎯\|🔥\|💡\|📝\|🧪' src/ --include="*.ts" --include="*.tsx" --include="*.js" --include="*.jsx" 2>/dev/null | grep "console" | grep -v "// UI:"; then \
		echo "⚠️  Found emoji-prefixed debug logs (remove before merge)"; \
	else \
		echo "✅ No emoji debug logs found"; \
	fi
	@echo ""
	@echo "📊 4. DEBUG COMMENT MARKERS"
	@echo "────────────────────────────────────────"
	@if grep -rn '// DEBUG:\|// TODO: remove\|// FIXME:\|// XXX:' src/ --include="*.ts" --include="*.tsx" --include="*.js" --include="*.jsx" 2>/dev/null | head -20; then \
		echo "⚠️  Found debug comment markers"; \
	else \
		echo "✅ No debug comment markers found"; \
	fi
	@echo ""
	@echo "📊 5. DEBUGGER STATEMENTS"
	@echo "────────────────────────────────────────"
	@if grep -rn "debugger;" src/ --include="*.ts" --include="*.tsx" --include="*.js" --include="*.jsx" 2>/dev/null; then \
		echo "⚠️  Found debugger statements (remove before merge)"; \
	else \
		echo "✅ No debugger statements found"; \
	fi
	@echo ""
	@echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
	@echo "✅ Audit complete!"
	@echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

.PHONY: deps-check
deps-check: ## Check for outdated dependencies
	@echo "Checking for outdated dependencies..."
	$(NPM) outdated || true

.PHONY: deps-update
deps-update: ## Update dependencies (interactive)
	@echo "Updating dependencies..."
	$(NPM) update

.PHONY: deps-audit
deps-audit: ## Audit dependencies for vulnerabilities
	@echo "Auditing dependencies..."
	$(NPM) audit

.PHONY: deps-audit-fix
deps-audit-fix: ## Fix dependency vulnerabilities
	@echo "Fixing dependency vulnerabilities..."
	$(NPM) audit fix

.PHONY: docker-build
docker-build: ## Build Docker image
	@echo "Building Docker image..."
	docker build \
		--build-arg VERSION=$(VERSION) \
		--build-arg BUILD_TIME=$(BUILD_TIME) \
		--build-arg GIT_COMMIT=$(GIT_COMMIT) \
		-t $(DOCKER_IMAGE):$(DOCKER_TAG) \
		-t $(DOCKER_IMAGE):latest \
		.

.PHONY: docker-run
docker-run: ## Run Docker container
	@echo "Running Docker container..."
	docker run --rm -p 3000:80 $(DOCKER_IMAGE):$(DOCKER_TAG)

.PHONY: docker-push
docker-push: ## Push Docker image to registry
	@echo "Pushing Docker image..."
	docker push $(DOCKER_IMAGE):$(DOCKER_TAG)
	docker push $(DOCKER_IMAGE):latest

.PHONY: analyze
analyze: ## Analyze bundle size
	@echo "Analyzing bundle size..."
	$(NPM) run build -- --mode analyze

.PHONY: serve
serve: build ## Build and serve production build
	@echo "Serving production build..."
	$(NPM) run preview

.PHONY: storybook
storybook: ## Run Storybook (if configured)
	@echo "Running Storybook..."
	@if grep -q '"storybook"' package.json; then \
		$(NPM) run storybook; \
	else \
		echo "⚠️  Storybook not configured in package.json"; \
	fi

.PHONY: dev-setup
dev-setup: install ## Setup development environment
	@echo "Development environment setup complete!"
	@echo "Run 'make dev' to start development server"

.PHONY: release
release: check build ## Prepare release
	@echo "Release prepared in $(BUILD_DIR)/ directory"

.PHONY: version
version: ## Show version information
	@echo "Version: $(VERSION)"
	@echo "Build Time: $(BUILD_TIME)"
	@echo "Git Commit: $(GIT_COMMIT)"
	@$(NODE) --version
	@$(NPM) --version

.PHONY: clean-install
clean-install: clean install ## Clean and reinstall dependencies
	@echo "Clean install complete!"

.PHONY: validate
validate: format-check lint type-check ## Validate code (format, lint, types) without running tests
	@echo "✅ Code validation passed!"

.PHONY: pre-commit
pre-commit: format lint type-check ## Run pre-commit checks (auto-fix format, lint, type-check)
	@echo "✅ Pre-commit checks complete!"

.PHONY: ci
ci: install validate test build ## Run full CI pipeline
	@echo "✅ CI pipeline complete!"
