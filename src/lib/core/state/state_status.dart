/// State status enumeration for tracking asynchronous operations
///
/// Use this enum to represent the current status of data loading,
/// error handling, and success states in ViewModels.
enum StateStatus {
  /// Initial state before any operation
  initial,

  /// Operation is currently in progress
  loading,

  /// Operation completed successfully
  success,

  /// Operation failed with an error
  error,

  /// Data is being refreshed (for pull-to-refresh scenarios)
  refreshing,
}

/// Extension methods for StateStatus to simplify conditional checks
extension StateStatusX on StateStatus {
  /// Returns true if the state is initial
  bool get isInitial => this == StateStatus.initial;

  /// Returns true if the state is loading
  bool get isLoading => this == StateStatus.loading;

  /// Returns true if the state is successful
  bool get isSuccess => this == StateStatus.success;

  /// Returns true if the state is an error
  bool get isError => this == StateStatus.error;

  /// Returns true if the state is refreshing
  bool get isRefreshing => this == StateStatus.refreshing;

  /// Returns true if the state is loading or refreshing
  bool get isBusy => isLoading || isRefreshing;
}
