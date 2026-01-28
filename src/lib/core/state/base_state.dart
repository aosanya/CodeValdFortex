import 'package:equatable/equatable.dart';
import 'state_status.dart';

/// Base class for all state objects in the application
///
/// This class provides common functionality for state management including
/// status tracking, error handling, and immutability.
///
/// Type parameter [T] represents the data type managed by this state.
abstract class BaseState<T> extends Equatable {
  /// Current status of the state
  final StateStatus status;

  /// Optional data payload
  final T? data;

  /// Optional error message
  final String? errorMessage;

  /// Optional error details for debugging
  final dynamic error;

  /// Timestamp of when the state was last updated
  final DateTime lastUpdated;

  BaseState({
    this.status = StateStatus.initial,
    this.data,
    this.errorMessage,
    this.error,
    DateTime? lastUpdated,
  }) : lastUpdated = lastUpdated ?? DateTime.now();

  /// Convenience getters for common state checks
  bool get isInitial => status.isInitial;
  bool get isLoading => status.isLoading;
  bool get isSuccess => status.isSuccess;
  bool get isError => status.isError;
  bool get isRefreshing => status.isRefreshing;
  bool get isBusy => status.isBusy;

  /// Returns true if data is available
  bool get hasData => data != null;

  /// Returns true if there's an error
  bool get hasError => error != null || errorMessage != null;

  @override
  List<Object?> get props => [status, data, errorMessage, error, lastUpdated];

  /// Creates a copy of this state with updated fields
  BaseState<T> copyWith({
    StateStatus? status,
    T? data,
    String? errorMessage,
    dynamic error,
    DateTime? lastUpdated,
  });
}

/// Default implementation of BaseState for generic use cases
class GenericState<T> extends BaseState<T> {
  GenericState({
    super.status,
    super.data,
    super.errorMessage,
    super.error,
    super.lastUpdated,
  });

  @override
  GenericState<T> copyWith({
    StateStatus? status,
    T? data,
    String? errorMessage,
    dynamic error,
    DateTime? lastUpdated,
  }) {
    return GenericState<T>(
      status: status ?? this.status,
      data: data ?? this.data,
      errorMessage: errorMessage ?? this.errorMessage,
      error: error ?? this.error,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }

  /// Factory constructor for initial state
  factory GenericState.initial() {
    return GenericState(status: StateStatus.initial);
  }

  /// Factory constructor for loading state
  factory GenericState.loading({T? data}) {
    return GenericState(status: StateStatus.loading, data: data);
  }

  /// Factory constructor for success state
  factory GenericState.success(T data) {
    return GenericState(status: StateStatus.success, data: data);
  }

  /// Factory constructor for error state
  factory GenericState.error(String message, {dynamic error, T? data}) {
    return GenericState(
      status: StateStatus.error,
      errorMessage: message,
      error: error,
      data: data,
    );
  }

  /// Factory constructor for refreshing state
  factory GenericState.refreshing({T? data}) {
    return GenericState(status: StateStatus.refreshing, data: data);
  }
}
