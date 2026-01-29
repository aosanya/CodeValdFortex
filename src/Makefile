# CodeVald Fortex - Flutter Application Makefile

# Flutter SDK path (modify if needed)
FLUTTER := flutter

# Project directories
SRC_DIR := lib
TEST_DIR := test
BUILD_DIR := build

# Default target
.DEFAULT_GOAL := help

##@ General

.PHONY: help
help: ## Display this help message
	@awk 'BEGIN {FS = ":.*##"; printf "\nUsage:\n  make \033[36m<target>\033[0m\n"} /^[a-zA-Z_0-9-]+:.*?##/ { printf "  \033[36m%-20s\033[0m %s\n", $$1, $$2 } /^##@/ { printf "\n\033[1m%s\033[0m\n", substr($$0, 5) } ' $(MAKEFILE_LIST)

##@ Development

.PHONY: install
install: ## Install Flutter dependencies
	$(FLUTTER) pub get

.PHONY: upgrade
upgrade: ## Upgrade Flutter dependencies
	$(FLUTTER) pub upgrade

.PHONY: outdated
outdated: ## Check for outdated dependencies
	$(FLUTTER) pub outdated

.PHONY: clean
clean: ## Clean build artifacts
	$(FLUTTER) clean
	rm -rf $(BUILD_DIR)

.PHONY: format
format: ## Format Dart code
	$(FLUTTER) format $(SRC_DIR) $(TEST_DIR)

.PHONY: format-check
format-check: ## Check Dart code formatting
	$(FLUTTER) format --set-exit-if-changed $(SRC_DIR) $(TEST_DIR)

##@ Code Quality

.PHONY: analyze
analyze: ## Run static code analysis
	$(FLUTTER) analyze --no-fatal-infos

.PHONY: analyze-strict
analyze-strict: ## Run strict static code analysis
	$(FLUTTER) analyze

.PHONY: lint
lint: format-check analyze ## Run linting (format check + analyze)

##@ Testing

.PHONY: test
test: ## Run all tests
	$(FLUTTER) test

.PHONY: test-coverage
test-coverage: ## Run tests with coverage
	$(FLUTTER) test --coverage
	@echo "Coverage report generated in coverage/lcov.info"

.PHONY: test-watch
test-watch: ## Run tests in watch mode
	$(FLUTTER) test --watch

##@ Build

.PHONY: build-web
build-web: ## Build web application (release)
	$(FLUTTER) build web --release

.PHONY: build-web-debug
build-web-debug: ## Build web application (debug)
	$(FLUTTER) build web --debug

.PHONY: build-apk
build-apk: ## Build Android APK
	$(FLUTTER) build apk --release

.PHONY: build-appbundle
build-appbundle: ## Build Android App Bundle
	$(FLUTTER) build appbundle --release

.PHONY: build-ios
build-ios: ## Build iOS application
	$(FLUTTER) build ios --release

.PHONY: build-macos
build-macos: ## Build macOS application
	$(FLUTTER) build macos --release

.PHONY: build-linux
build-linux: ## Build Linux application
	$(FLUTTER) build linux --release

.PHONY: build-windows
build-windows: ## Build Windows application
	$(FLUTTER) build windows --release

.PHONY: build-all
build-all: build-web build-apk build-ios build-macos build-linux build-windows ## Build for all platforms

##@ Run

.PHONY: run
run: ## Run the app (default device)
	$(FLUTTER) run

.PHONY: run-web
run-web: ## Run the app on web (opens in host browser)
	@-fuser -k 8090/tcp 2>/dev/null || true
	@-pkill -9 -f "dart.*web-server" 2>/dev/null || true
	@sleep 1
	$(FLUTTER) run -d web-server --web-port=8090 --web-hostname=0.0.0.0

.PHONY: run-chrome
run-chrome: ## Run the app on Chrome (if available)
	$(FLUTTER) run -d chrome

.PHONY: run-dev
run-dev: ## Run the app in development mode
	$(FLUTTER) run --debug

.PHONY: run-release
run-release: ## Run the app in release mode
	$(FLUTTER) run --release

##@ Development Workflow

.PHONY: setup
setup: install ## Initial project setup
	@echo "✓ Dependencies installed"
	@echo "✓ Project ready for development"

.PHONY: dev
dev: clean install analyze test ## Complete dev workflow (clean, install, analyze, test)
	@echo "✓ Development workflow complete"

.PHONY: pre-commit
pre-commit: format analyze test ## Pre-commit checks (format, analyze, test)
	@echo "✓ Pre-commit checks passed"

.PHONY: ci
ci: install lint test-coverage ## CI pipeline (install, lint, test with coverage)
	@echo "✓ CI checks passed"

##@ Docker & Deployment

.PHONY: docker-build
docker-build: build-web ## Build Docker image for web
	docker build -t codevald-fortex:latest .

.PHONY: docker-run
docker-run: ## Run Docker container
	docker run -p 8080:80 codevald-fortex:latest

##@ Utilities

.PHONY: doctor
doctor: ## Run Flutter doctor
	$(FLUTTER) doctor -v

.PHONY: devices
devices: ## List available devices
	$(FLUTTER) devices

.PHONY: clean-all
clean-all: clean ## Deep clean (including pub cache)
	$(FLUTTER) pub cache clean
	rm -rf .dart_tool
	rm -rf .flutter-plugins
	rm -rf .flutter-plugins-dependencies

.PHONY: gen
gen: ## Generate code (for build_runner)
	$(FLUTTER) pub run build_runner build --delete-conflicting-outputs

.PHONY: watch
watch: ## Watch and generate code
	$(FLUTTER) pub run build_runner watch --delete-conflicting-outputs
