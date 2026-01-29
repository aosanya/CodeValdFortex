import 'package:codevald_fortex/core/state/state.dart';
import 'package:codevald_fortex/models/dashboard_models.dart';
import 'dashboard_state.dart';

/// ViewModel for Dashboard screen
///
/// Manages dashboard data including statistics, charts, and other metrics.
/// Follows the MVVM pattern with state management via ChangeNotifier.
class DashboardViewModel extends BaseViewModel<DashboardState> {
  /// Constructor initializing with initial state
  DashboardViewModel() : super(DashboardState.initial());

  /// Fetches dashboard data from the API
  ///
  /// In a real implementation, this would call a repository/service
  /// to fetch data from the backend API.
  Future<void> fetchDashboardData() async {
    await executeAsync<DashboardData>(
      operation: () => _loadDashboardData(),
      onSuccess: (data) => DashboardState.success(data),
      onError: (error, stackTrace) => DashboardState.error(
        'Failed to load dashboard data',
        error: error,
        data: state.data,
      ),
    );
  }

  /// Refreshes dashboard data
  ///
  /// Similar to fetchDashboardData but indicates a refresh operation
  Future<void> refreshDashboardData() async {
    setState(DashboardState.refreshing(data: state.data));

    await executeAsync<DashboardData>(
      operation: () => _loadDashboardData(),
      onSuccess: (data) => DashboardState.success(data),
      onError: (error, stackTrace) => DashboardState.error(
        'Failed to refresh dashboard data',
        error: error,
        data: state.data,
      ),
      showLoading: false, // Don't show loading since we're showing refreshing
    );
  }

  /// Simulates loading dashboard data from API
  ///
  /// TODO: Replace this with actual API call via repository
  Future<DashboardData> _loadDashboardData() async {
    // Simulate network delay
    await Future.delayed(const Duration(seconds: 2));

    // For now, return mock data
    // In production, this would be:
    // return await _dashboardRepository.fetchDashboardData();
    return DashboardData.mock();
  }

  /// Updates stats data only
  void updateStats(StatsData stats) {
    if (state.data != null) {
      final updatedData = state.data!.copyWith(stats: stats);
      setState(DashboardState.success(updatedData));
    }
  }

  /// Updates chart data only
  void updateChartData(ChartData chartData) {
    if (state.data != null) {
      final updatedData = state.data!.copyWith(chartData: chartData);
      setState(DashboardState.success(updatedData));
    }
  }
}
