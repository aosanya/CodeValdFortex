import 'package:codevald_fortex/core/state/base_state.dart';
import 'package:codevald_fortex/core/state/state_status.dart';
import 'package:codevald_fortex/models/dashboard_models.dart';

/// State class for Statistics data
class StatsState extends BaseState<StatsData> {
  StatsState({
    super.status,
    super.data,
    super.errorMessage,
    super.error,
    super.lastUpdated,
  });

  /// Factory constructor for initial state
  factory StatsState.initial() {
    return StatsState(status: StateStatus.initial);
  }

  /// Factory constructor for loading state
  factory StatsState.loading({StatsData? data}) {
    return StatsState(status: StateStatus.loading, data: data);
  }

  /// Factory constructor for success state
  factory StatsState.success(StatsData data) {
    return StatsState(status: StateStatus.success, data: data);
  }

  /// Factory constructor for error state
  factory StatsState.error(String message, {dynamic error, StatsData? data}) {
    return StatsState(
      status: StateStatus.error,
      errorMessage: message,
      error: error,
      data: data,
    );
  }

  /// Factory constructor for refreshing state
  factory StatsState.refreshing({StatsData? data}) {
    return StatsState(status: StateStatus.refreshing, data: data);
  }

  @override
  StatsState copyWith({
    StateStatus? status,
    StatsData? data,
    String? errorMessage,
    dynamic error,
    DateTime? lastUpdated,
  }) {
    return StatsState(
      status: status ?? this.status,
      data: data ?? this.data,
      errorMessage: errorMessage ?? this.errorMessage,
      error: error ?? this.error,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }
}
