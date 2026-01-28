import 'package:codevald_fortex/core/state/base_state.dart';
import 'package:codevald_fortex/core/state/state_status.dart';
import 'package:codevald_fortex/models/dashboard_models.dart';

/// State class for Dashboard data
class DashboardState extends BaseState<DashboardData> {
  DashboardState({
    super.status,
    super.data,
    super.errorMessage,
    super.error,
    super.lastUpdated,
  });

  /// Factory constructor for initial state
  factory DashboardState.initial() {
    return DashboardState(status: StateStatus.initial);
  }

  /// Factory constructor for loading state
  factory DashboardState.loading({DashboardData? data}) {
    return DashboardState(status: StateStatus.loading, data: data);
  }

  /// Factory constructor for success state
  factory DashboardState.success(DashboardData data) {
    return DashboardState(status: StateStatus.success, data: data);
  }

  /// Factory constructor for error state
  factory DashboardState.error(
    String message, {
    dynamic error,
    DashboardData? data,
  }) {
    return DashboardState(
      status: StateStatus.error,
      errorMessage: message,
      error: error,
      data: data,
    );
  }

  /// Factory constructor for refreshing state
  factory DashboardState.refreshing({DashboardData? data}) {
    return DashboardState(status: StateStatus.refreshing, data: data);
  }

  @override
  DashboardState copyWith({
    StateStatus? status,
    DashboardData? data,
    String? errorMessage,
    dynamic error,
    DateTime? lastUpdated,
  }) {
    return DashboardState(
      status: status ?? this.status,
      data: data ?? this.data,
      errorMessage: errorMessage ?? this.errorMessage,
      error: error ?? this.error,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }
}

/// Combined dashboard data model
class DashboardData {
  /// Statistics data
  final StatsData stats;

  /// Chart data
  final ChartData chartData;

  const DashboardData({required this.stats, required this.chartData});

  /// Creates empty dashboard data
  factory DashboardData.empty() {
    return DashboardData(
      stats: StatsData.empty(),
      chartData: ChartData.empty(),
    );
  }

  /// Creates mock dashboard data for testing/development
  factory DashboardData.mock() {
    return DashboardData(stats: StatsData.mock(), chartData: ChartData.mock());
  }

  /// Creates a copy with updated fields
  DashboardData copyWith({StatsData? stats, ChartData? chartData}) {
    return DashboardData(
      stats: stats ?? this.stats,
      chartData: chartData ?? this.chartData,
    );
  }
}
