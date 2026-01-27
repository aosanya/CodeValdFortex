# CodeVald Fortex - Flutter Application

Cross-platform Flutter application for agency management, work items, and agent orchestration.

## 🚀 Quick Start

### Prerequisites

- Flutter SDK 3.38.8 or higher
- Dart 3.10.7 or higher
- Make (optional, for using Makefile commands)

### Installation

```bash
# Install dependencies
make install
# or
flutter pub get

# Run the app
make run-web
# or
flutter run -d chrome
```

## 📁 Project Structure

```
src/
├── lib/
│   ├── config/           # App configuration (theme, constants, env)
│   ├── core/             # Core utilities and base classes
│   ├── models/           # Data models
│   ├── repositories/     # Data repositories (API, local storage)
│   ├── services/         # Business services
│   ├── viewmodels/       # MVVM ViewModels (Riverpod providers)
│   ├── views/            # UI screens and pages
│   ├── widgets/          # Reusable UI components
│   └── main.dart         # Application entry point
├── test/                 # Unit and widget tests
├── assets/
│   ├── images/           # Image assets
│   └── icons/            # Icon assets
├── .env.development      # Development environment config
├── .env.production       # Production environment config
├── pubspec.yaml          # Package dependencies
└── Makefile             # Build and development commands
```

## 🏗️ Architecture

### MVVM Pattern with Riverpod

- **Models**: Data classes representing business entities
- **Views**: UI components (Screens, Widgets)
- **ViewModels**: State management and business logic using Riverpod
- **Repositories**: Data access layer (API, local storage)
- **Services**: Business services and utilities

### Responsive Design

- **Mobile**: < 600px
- **Tablet**: 600px - 900px
- **Desktop**: 900px - 1200px
- **Wide**: > 1200px

## 🛠️ Development

### Using Makefile

```bash
# Setup project
make setup

# Development workflow
make dev                  # Clean, install, analyze, test

# Code quality
make format              # Format code
make analyze             # Run static analysis
make lint                # Format check + analyze

# Testing
make test                # Run all tests
make test-coverage       # Run tests with coverage

# Build
make build-web           # Build for web
make build-apk           # Build Android APK
make build-ios           # Build for iOS

# Run
make run-web             # Run on Chrome
make run-dev             # Run in debug mode
```

### Using Flutter CLI

```bash
# Run app
flutter run -d chrome

# Hot reload (press 'r' in terminal)
# Hot restart (press 'R' in terminal)

# Analyze code
flutter analyze

# Format code
flutter format lib test

# Run tests
flutter test
```

## 🎨 Theme & Styling

The app uses Material Design 3 with custom theme configuration:

- **Primary Color**: `#2196F3` (Blue)
- **Secondary Color**: `#03DAC6` (Teal)
- **Light/Dark Mode**: Automatic based on system preferences

See `lib/config/app_theme.dart` for theme customization.

## 🔧 Configuration

### Environment Variables

Create `.env.development` or `.env.production`:

```env
API_BASE_URL=http://localhost:8080/api/v1
WS_BASE_URL=ws://localhost:8080/ws
ENVIRONMENT=development
DEBUG_MODE=true
LOG_LEVEL=debug
```

### Constants

App-wide constants are defined in `lib/config/app_constants.dart`:

- API timeouts
- Pagination settings
- Responsive breakpoints
- Cache durations

## 📦 Dependencies

### Core
- **flutter_riverpod**: State management
- **go_router**: Navigation and routing
- **dio**: HTTP client

### UI Components
- **fl_chart**: Charts and data visualization
- **flutter_svg**: SVG support
- **badges**: Badge widgets
- **data_table_2**: Enhanced data tables
- **responsive_framework**: Responsive design

### Storage
- **shared_preferences**: Local key-value storage
- **flutter_secure_storage**: Secure storage for tokens

### Utilities
- **flutter_dotenv**: Environment configuration
- **intl**: Internationalization
- **logger**: Logging
- **equatable**: Value equality

## 🧪 Testing

```bash
# Run all tests
make test

# Run with coverage
make test-coverage

# Run specific test file
flutter test test/widget_test.dart
```

## 🚢 Deployment

### Web

```bash
# Build for production
make build-web

# Output: build/web/
```

### Mobile (Android)

```bash
# Build APK
make build-apk

# Build App Bundle
make build-appbundle
```

### Desktop

```bash
# macOS
make build-macos

# Linux
make build-linux

# Windows
make build-windows
```

## 📝 Code Standards

- **Linting**: Follow `analysis_options.yaml` rules
- **Formatting**: Use `dart format` before commits
- **Naming**: Use `snake_case` for files, `camelCase` for variables
- **Imports**: Organize as: Dart SDK → Flutter → External → Internal
- **Logging**: Prefix logs with task ID (e.g., `MVP-FL-001-INFO:`)

### Pre-commit Checklist

```bash
make pre-commit  # Runs format, analyze, and test
```

## 🔗 Integration with Backend

- **Backend API**: CodeValdCortex (Go + ArangoDB)
- **Base URL**: Configured via environment variables
- **Authentication**: JWT tokens with refresh mechanism
- **WebSockets**: Real-time updates for agents and properties

## 📚 Documentation

- **Architecture**: `/documents/2-SoftwareDesignAndArchitecture/flutter-designs/`
- **Task Details**: `/documents/3-SofwareDevelopment/mvp-details/`
- **API Docs**: See CodeValdCortex repository

## 🤝 Contributing

1. Create feature branch: `git checkout -b feature/MVP-FL-XXX_description`
2. Make changes following code standards
3. Run pre-commit checks: `make pre-commit`
4. Commit with descriptive message
5. Push and create pull request to `dev` branch

## 📄 License

See LICENSE file in repository root.

## 🐛 Issues

Report issues in the CodeValdFortex repository issue tracker.

---

**Version**: 1.0.0  
**Flutter**: 3.38.8  
**Dart**: 3.10.7
