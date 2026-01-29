import 'package:codevald_fortex/core/state/state.dart';
import 'package:codevald_fortex/models/dashboard_models.dart';
import 'stats_state.dart';

/// ViewModel for Statistics management
///
/// Manages statistics data for metrics cards and dashboard overview.
/// Provides methods to fetch and update individual or grouped stats.
class StatsViewModel extends BaseViewModel<StatsState> {
  /// Constructor initializing with initial state
  StatsViewModel() : super(StatsState.initial());

  /// Fetches all statistics data
  Future<void> fetchStats() async {
    await executeAsync<StatsData>(
      operation: () => _loadStats(),
      onSuccess: (data) => StatsState.success(data),
      onError: (error, stackTrace) => StatsState.error(
        'Failed to load statistics',
        error: error,
        data: state.data,
      ),
    );
  }

  /// Refreshes statistics data
  Future<void> refreshStats() async {
    setState(StatsState.refreshing(data: state.data));

    await executeAsync<StatsData>(
      operation: () => _loadStats(),
      onSuccess: (data) => StatsState.success(data),
      onError: (error, stackTrace) => StatsState.error(
        'Failed to refresh statistics',
        error: error,
        data: state.data,
      ),
      showLoading: false,
    );
  }

  /// Simulates loading stats from API
  ///
  /// TODO: Replace this with actual API call via repository
  Future<StatsData> _loadStats() async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 1500));

    // For now, return mock data
    // In production, this would be:
    // return await _statsRepository.fetchStats();
    return StatsData.mock();
  }

  /// Updates individual stat values
  ///
  /// This can be used for real-time updates via WebSocket or polling
  void updateTodayOrders(int orders, double trend) {
    if (state.data != null) {
      final updatedStats = state.data!.copyWith(
        todayOrders: orders,
        todayOrdersTrend: trend,
      );
      setState(StatsState.success(updatedStats));
    }
  }

  /// Updates today's earnings
  void updateTodayEarnings(double earnings, double trend) {
    if (state.data != null) {
      final updatedStats = state.data!.copyWith(
        todayEarnings: earnings,
        todayEarningsTrend: trend,
      );
      setState(StatsState.success(updatedStats));
    }
  }

  /// Updates profit gain
  void updateProfitGain(double profit, double trend) {
    if (state.data != null) {
      final updatedStats = state.data!.copyWith(
        profitGain: profit,
        profitGainTrend: trend,
      );
      setState(StatsState.success(updatedStats));
    }
  }

  /// Updates total earnings
  void updateTotalEarnings(double earnings, double trend) {
    if (state.data != null) {
      final updatedStats = state.data!.copyWith(
        totalEarnings: earnings,
        totalEarningsTrend: trend,
      );
      setState(StatsState.success(updatedStats));
    }
  }
}
