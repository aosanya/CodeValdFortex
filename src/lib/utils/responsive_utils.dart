import 'package:flutter/material.dart';

/// Utility class for responsive design breakpoints and helpers
class ResponsiveUtils {
  // Breakpoint constants
  static const double mobileBreakpoint = 600;
  static const double tabletBreakpoint = 900;
  static const double desktopBreakpoint = 1200;

  /// Check if screen is mobile size (< 600px)
  static bool isMobile(BuildContext context) {
    return MediaQuery.of(context).size.width < mobileBreakpoint;
  }

  /// Check if screen is tablet size (600px - 900px)
  static bool isTablet(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return width >= mobileBreakpoint && width < tabletBreakpoint;
  }

  /// Check if screen is desktop size (900px - 1200px)
  static bool isDesktop(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return width >= tabletBreakpoint && width < desktopBreakpoint;
  }

  /// Check if screen is wide size (>= 1200px)
  static bool isWide(BuildContext context) {
    return MediaQuery.of(context).size.width >= desktopBreakpoint;
  }

  /// Get the appropriate grid cross axis count based on screen size
  static int gridCrossAxisCount(
    BuildContext context, {
    int mobile = 1,
    int tablet = 2,
    int desktop = 3,
    int wide = 4,
  }) {
    if (isWide(context)) return wide;
    if (isDesktop(context)) return desktop;
    if (isTablet(context)) return tablet;
    return mobile;
  }

  /// Get responsive padding based on screen size
  static double getResponsivePadding(BuildContext context) {
    if (isMobile(context)) return 8.0;
    if (isTablet(context)) return 16.0;
    return 24.0;
  }

  /// Get responsive font size multiplier
  static double getFontSizeMultiplier(BuildContext context) {
    if (isMobile(context)) return 0.9;
    if (isTablet(context)) return 1.0;
    return 1.1;
  }

  /// Get the screen size category as a string
  static String getScreenCategory(BuildContext context) {
    if (isMobile(context)) return 'mobile';
    if (isTablet(context)) return 'tablet';
    if (isDesktop(context)) return 'desktop';
    return 'wide';
  }

  /// Get responsive value based on screen size
  static T getResponsiveValue<T>(
    BuildContext context, {
    required T mobile,
    T? tablet,
    T? desktop,
    T? wide,
  }) {
    if (isWide(context) && wide != null) return wide;
    if (isDesktop(context) && desktop != null) return desktop;
    if (isTablet(context) && tablet != null) return tablet;
    return mobile;
  }
}

/// Extension on BuildContext for easier responsive access
extension ResponsiveContext on BuildContext {
  bool get isMobile => ResponsiveUtils.isMobile(this);
  bool get isTablet => ResponsiveUtils.isTablet(this);
  bool get isDesktop => ResponsiveUtils.isDesktop(this);
  bool get isWide => ResponsiveUtils.isWide(this);

  int gridColumns({
    int mobile = 1,
    int tablet = 2,
    int desktop = 3,
    int wide = 4,
  }) {
    return ResponsiveUtils.gridCrossAxisCount(
      this,
      mobile: mobile,
      tablet: tablet,
      desktop: desktop,
      wide: wide,
    );
  }

  double get responsivePadding => ResponsiveUtils.getResponsivePadding(this);
  double get fontSizeMultiplier => ResponsiveUtils.getFontSizeMultiplier(this);
  String get screenCategory => ResponsiveUtils.getScreenCategory(this);
}
