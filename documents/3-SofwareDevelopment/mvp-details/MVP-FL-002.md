# MVP-FL-002: Design System Setup

## Overview
**Priority**: P0 (Critical)  
**Effort**: Medium  
**Skills Required**: Flutter, Material Design, Dart, UI/UX  
**Dependencies**: ~~MVP-FL-001~~ ✅  
**Status**: Not Started

Establish a comprehensive Material Design system for CodeVald Fortex with custom theming, reusable widget library, design tokens, and responsive breakpoints that will serve as the foundation for all UI components throughout the application.

## Objectives

1. Configure Material Design theme with brand-specific colors and typography
2. Implement light and dark mode themes with seamless switching
3. Create base widget library (StatCard, MetricCard, ChartCard, DataListCard)
4. Establish design tokens for consistent spacing, colors, and typography
5. Define responsive breakpoints for mobile, tablet, desktop, and wide displays
6. Set up theme management with Riverpod for app-wide theme state

## Requirements

### Functional Requirements

1. **Theme Configuration**
   - Custom Material Design theme with brand colors
   - Light and dark mode variants
   - System theme detection and manual override
   - Persistent theme preference (shared_preferences)
   - Smooth theme transitions without jarring UI changes

2. **Widget Library**
   - StatCard: Display key metrics with icons, values, and trend indicators
   - MetricCard: Enhanced metric display with charts and comparisons
   - ChartCard: Container for data visualizations with titles and legends
   - DataListCard: Structured list display with filtering and sorting

3. **Design Tokens**
   - Color palette (primary, secondary, accent, semantic colors)
   - Typography scale (headline, title, body, caption variants)
   - Spacing system (padding, margins using 8pt grid)
   - Border radius standards
   - Shadow/elevation levels

4. **Responsive Design**
   - Mobile breakpoint: < 600px
   - Tablet breakpoint: 600px - 900px
   - Desktop breakpoint: 900px - 1200px
   - Wide breakpoint: > 1200px
   - Responsive grid layouts
   - Adaptive widget sizing

### Technical Requirements

1. **Theme Architecture**
   - ThemeData configuration in `lib/config/app_theme.dart`
   - Separate light and dark ThemeData definitions
   - Custom ColorScheme with brand colors
   - Typography theme using TextTheme
   - Component themes (AppBar, Card, Button, etc.)

2. **Widget Components** (Reference: `design-patterns.md`)
   - Base widget files in `lib/widgets/common/`
   - Reusable, stateless widgets where possible
   - Customizable via constructor parameters
   - Responsive sizing using MediaQuery
   - Accessibility support (semantics, labels)

3. **State Management**
   - Theme provider using Riverpod
   - Theme mode state (light/dark/system)
   - Persistent storage for theme preference

4. **Performance**
   - Efficient theme switching without rebuilding entire app
   - Lazy loading of theme-specific assets
   - Optimized widget rendering

## Technical Specifications

### Architecture

Following the patterns in `/documents/2-SoftwareDesignAndArchitecture/flutter-designs/design-patterns.md`:

**File Structure:**
```
lib/
├── config/
│   └── app_theme.dart           # Theme configuration (enhanced)
├── providers/
│   └── theme_provider.dart      # Theme state management
├── widgets/
│   └── common/
│       ├── stat_card.dart       # Metric display card
│       ├── metric_card.dart     # Enhanced metric with trends
│       ├── chart_card.dart      # Visualization container
│       └── data_list_card.dart  # Structured list display
└── utils/
    └── responsive_utils.dart    # Breakpoint helpers
```

### Implementation Details

#### 1. Enhanced Theme Configuration

**File**: `lib/config/app_theme.dart`

```dart
import 'package:flutter/material.dart';

class AppTheme {
  // Brand Colors
  static const Color primaryColor = Color(0xFF1976D2); // Blue
  static const Color secondaryColor = Color(0xFF00ACC1); // Cyan
  static const Color accentColor = Color(0xFFFF9800); // Orange
  
  // Semantic Colors
  static const Color successColor = Color(0xFF4CAF50); // Green
  static const Color warningColor = Color(0xFFFFC107); // Amber
  static const Color errorColor = Color(0xFFF44336); // Red
  static const Color infoColor = Color(0xFF2196F3); // Blue
  
  // Light Theme
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryColor,
        brightness: Brightness.light,
        primary: primaryColor,
        secondary: secondaryColor,
        error: errorColor,
      ),
      
      // Typography
      textTheme: _textTheme,
      
      // AppBar Theme
      appBarTheme: const AppBarTheme(
        centerTitle: false,
        elevation: 0,
        scrolledUnderElevation: 2,
      ),
      
      // Card Theme
      cardTheme: CardTheme(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      
      // Input Decoration Theme
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        filled: true,
      ),
      
      // Button Themes
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
    );
  }
  
  // Dark Theme
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryColor,
        brightness: Brightness.dark,
        primary: primaryColor,
        secondary: secondaryColor,
        error: errorColor,
      ),
      
      textTheme: _textTheme,
      
      appBarTheme: const AppBarTheme(
        centerTitle: false,
        elevation: 0,
        scrolledUnderElevation: 2,
      ),
      
      cardTheme: CardTheme(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        filled: true,
      ),
      
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
    );
  }
  
  // Typography Scale
  static const TextTheme _textTheme = TextTheme(
    displayLarge: TextStyle(fontSize: 57, fontWeight: FontWeight.w400, letterSpacing: -0.25),
    displayMedium: TextStyle(fontSize: 45, fontWeight: FontWeight.w400),
    displaySmall: TextStyle(fontSize: 36, fontWeight: FontWeight.w400),
    headlineLarge: TextStyle(fontSize: 32, fontWeight: FontWeight.w400),
    headlineMedium: TextStyle(fontSize: 28, fontWeight: FontWeight.w400),
    headlineSmall: TextStyle(fontSize: 24, fontWeight: FontWeight.w400),
    titleLarge: TextStyle(fontSize: 22, fontWeight: FontWeight.w500),
    titleMedium: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, letterSpacing: 0.15),
    titleSmall: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, letterSpacing: 0.1),
    bodyLarge: TextStyle(fontSize: 16, fontWeight: FontWeight.w400, letterSpacing: 0.5),
    bodyMedium: TextStyle(fontSize: 14, fontWeight: FontWeight.w400, letterSpacing: 0.25),
    bodySmall: TextStyle(fontSize: 12, fontWeight: FontWeight.w400, letterSpacing: 0.4),
    labelLarge: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, letterSpacing: 0.1),
    labelMedium: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, letterSpacing: 0.5),
    labelSmall: TextStyle(fontSize: 11, fontWeight: FontWeight.w500, letterSpacing: 0.5),
  );
  
  // Spacing System (8pt grid)
  static const double space4 = 4.0;
  static const double space8 = 8.0;
  static const double space12 = 12.0;
  static const double space16 = 16.0;
  static const double space24 = 24.0;
  static const double space32 = 32.0;
  static const double space48 = 48.0;
  
  // Border Radius
  static const double radiusSmall = 4.0;
  static const double radiusMedium = 8.0;
  static const double radiusLarge = 12.0;
  static const double radiusXLarge = 16.0;
}
```

#### 2. Theme State Management

**File**: `lib/providers/theme_provider.dart`

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Theme mode state provider
final themeModeProvider = StateNotifierProvider<ThemeModeNotifier, ThemeMode>((ref) {
  return ThemeModeNotifier();
});

class ThemeModeNotifier extends StateNotifier<ThemeMode> {
  static const String _key = 'theme_mode';
  
  ThemeModeNotifier() : super(ThemeMode.system) {
    _loadThemeMode();
  }
  
  Future<void> _loadThemeMode() async {
    final prefs = await SharedPreferences.getInstance();
    final savedMode = prefs.getString(_key);
    
    if (savedMode != null) {
      state = ThemeMode.values.firstWhere(
        (mode) => mode.toString() == savedMode,
        orElse: () => ThemeMode.system,
      );
    }
  }
  
  Future<void> setThemeMode(ThemeMode mode) async {
    state = mode;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, mode.toString());
  }
  
  void toggleTheme() {
    if (state == ThemeMode.light) {
      setThemeMode(ThemeMode.dark);
    } else {
      setThemeMode(ThemeMode.light);
    }
  }
}
```

#### 3. Widget Library Components

**File**: `lib/widgets/common/stat_card.dart`

```dart
import 'package:flutter/material.dart';

class StatCard extends StatelessWidget {
  final String title;
  final String value;
  final String? change;
  final bool isPositive;
  final IconData icon;
  final Color color;
  
  const StatCard({
    Key? key,
    required this.title,
    required this.value,
    this.change,
    this.isPositive = true,
    required this.icon,
    required this.color,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, color: color, size: 24),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            if (change != null) ...[
              const SizedBox(height: 4),
              Row(
                children: [
                  Icon(
                    isPositive ? Icons.trending_up : Icons.trending_down,
                    color: isPositive ? Colors.green : Colors.red,
                    size: 16,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    change!,
                    style: TextStyle(
                      color: isPositive ? Colors.green : Colors.red,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}
```

**Additional Widget Files**:
- `metric_card.dart`: Enhanced version with sparkline charts
- `chart_card.dart`: Container for fl_chart visualizations
- `data_list_card.dart`: Structured list with headers and filtering

#### 4. Responsive Utilities

**File**: `lib/utils/responsive_utils.dart`

```dart
import 'package:flutter/material.dart';

class ResponsiveUtils {
  // Breakpoints
  static const double mobileBreakpoint = 600;
  static const double tabletBreakpoint = 900;
  static const double desktopBreakpoint = 1200;
  
  static bool isMobile(BuildContext context) {
    return MediaQuery.of(context).size.width < mobileBreakpoint;
  }
  
  static bool isTablet(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return width >= mobileBreakpoint && width < tabletBreakpoint;
  }
  
  static bool isDesktop(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return width >= tabletBreakpoint && width < desktopBreakpoint;
  }
  
  static bool isWide(BuildContext context) {
    return MediaQuery.of(context).size.width >= desktopBreakpoint;
  }
  
  static int gridCrossAxisCount(BuildContext context) {
    if (isWide(context)) return 4;
    if (isDesktop(context)) return 3;
    if (isTablet(context)) return 2;
    return 1;
  }
}
```

## Acceptance Criteria

- [ ] Light theme configured with custom brand colors
- [ ] Dark theme configured with appropriate color adjustments
- [ ] Theme switching works smoothly without UI glitches
- [ ] Theme preference persists across app restarts
- [ ] System theme detection works correctly
- [ ] StatCard widget renders correctly on all screen sizes
- [ ] MetricCard displays trends and comparisons properly
- [ ] ChartCard integrates with fl_chart package
- [ ] DataListCard supports filtering and sorting
- [ ] All widgets follow Material Design 3 guidelines
- [ ] Responsive breakpoints work across mobile, tablet, desktop, wide
- [ ] Typography scale is consistent throughout widgets
- [ ] Spacing follows 8pt grid system
- [ ] All widgets have proper accessibility labels
- [ ] Widget library documented with usage examples
- [ ] No console.log or debug print statements
- [ ] Code passes `flutter analyze` with no errors
- [ ] Code formatted with `dart format`

## Testing Requirements

### Unit Tests
- Theme provider state management
- Theme mode persistence
- Color scheme generation
- Typography scale validation

### Widget Tests
- StatCard rendering with different props
- MetricCard trend indicator display
- ChartCard layout and sizing
- DataListCard filtering logic
- Responsive behavior at different breakpoints
- Theme switching without rebuilds

### Integration Tests
- Theme mode changes reflected across app
- Persistent theme preference on app restart
- Widget library integration in dashboard

## Design References

**Primary References:**
- `/documents/2-SoftwareDesignAndArchitecture/flutter-designs/design-patterns.md` - Widget patterns
- `/documents/2-SoftwareDesignAndArchitecture/flutter-designs/dashboard-design.md` - Layout architecture

**Material Design 3:**
- https://m3.material.io
- https://m3.material.io/foundations/color-system
- https://m3.material.io/styles/typography

**Package Documentation:**
- flutter_riverpod: https://riverpod.dev
- shared_preferences: https://pub.dev/packages/shared_preferences
- fl_chart: https://pub.dev/packages/fl_chart

## Dependencies

**Packages Required:**
- ✅ flutter_riverpod (already in pubspec.yaml)
- ✅ shared_preferences (already in pubspec.yaml)
- ✅ fl_chart (already in pubspec.yaml)

## Implementation Notes

1. **Start with theme configuration**: Update `app_theme.dart` with comprehensive light/dark themes
2. **Add theme provider**: Implement Riverpod provider for theme state
3. **Create widget library**: Build StatCard first, then MetricCard, ChartCard, DataListCard
4. **Test responsiveness**: Verify widgets adapt to all breakpoints
5. **Update main.dart**: Integrate theme provider and apply themes
6. **Document usage**: Add comments and examples for each widget

## Success Metrics

- All base widgets created and functional
- Theme switching < 100ms
- Widget rendering performance > 60fps
- Zero accessibility warnings
- 100% widget test coverage for common widgets
- Design system documented and ready for use in subsequent tasks
