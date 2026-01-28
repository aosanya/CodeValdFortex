import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:codevald_fortex/viewmodels/dashboard/dashboard_view_model.dart';
import 'package:codevald_fortex/viewmodels/dashboard/dashboard_state.dart';
import 'package:codevald_fortex/viewmodels/dashboard/stats_view_model.dart';
import 'package:codevald_fortex/viewmodels/dashboard/stats_state.dart';

/// Provider for DashboardViewModel
///
/// Creates and manages the lifecycle of DashboardViewModel.
/// Use this provider to access dashboard data and operations in widgets.
///
/// Example usage:
/// ```dart
/// final dashboardViewModel = ref.watch(dashboardViewModelProvider);
/// final dashboardState = ref.watch(dashboardStateProvider);
/// ```
final dashboardViewModelProvider = ChangeNotifierProvider<DashboardViewModel>((
  ref,
) {
  return DashboardViewModel();
});

/// Provider for DashboardState
///
/// Provides access to the current dashboard state.
/// This provider automatically rebuilds widgets when the state changes.
final dashboardStateProvider = Provider<DashboardState>((ref) {
  return ref.watch(dashboardViewModelProvider).state;
});

/// Provider for StatsViewModel
///
/// Creates and manages the lifecycle of StatsViewModel.
/// Use this provider to access statistics data and operations in widgets.
///
/// Example usage:
/// ```dart
/// final statsViewModel = ref.watch(statsViewModelProvider);
/// final statsState = ref.watch(statsStateProvider);
/// ```
final statsViewModelProvider = ChangeNotifierProvider<StatsViewModel>((ref) {
  return StatsViewModel();
});

/// Provider for StatsState
///
/// Provides access to the current statistics state.
/// This provider automatically rebuilds widgets when the state changes.
final statsStateProvider = Provider<StatsState>((ref) {
  return ref.watch(statsViewModelProvider).state;
});

/// Computed provider for checking if dashboard is loading
final isDashboardLoadingProvider = Provider<bool>((ref) {
  final state = ref.watch(dashboardStateProvider);
  return state.isLoading;
});

/// Computed provider for checking if stats are loading
final isStatsLoadingProvider = Provider<bool>((ref) {
  final state = ref.watch(statsStateProvider);
  return state.isLoading;
});

/// Computed provider for checking if any dashboard component has an error
final hasDashboardErrorProvider = Provider<bool>((ref) {
  final dashboardState = ref.watch(dashboardStateProvider);
  final statsState = ref.watch(statsStateProvider);
  return dashboardState.hasError || statsState.hasError;
});
