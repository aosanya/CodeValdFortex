import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart';
import 'base_state.dart';

/// Base class for all ViewModels in the application
///
/// This class provides common functionality for ViewModels including:
/// - State management with ChangeNotifier
/// - Logging support
/// - Error handling patterns
/// - Loading state management
///
/// Type parameter [T] represents the state type managed by this ViewModel.
abstract class BaseViewModel<T extends BaseState> extends ChangeNotifier {
  /// Logger instance for this ViewModel
  final Logger _logger = Logger();

  /// Current state
  T _state;

  /// Constructor
  BaseViewModel(this._state);

  /// Gets the current state
  T get state => _state;

  /// Updates the state and notifies listeners
  ///
  /// This method should be called whenever the state changes.
  /// It will automatically notify all listeners and log the state change.
  @protected
  void setState(T newState) {
    final oldStatus = _state.status;
    _state = newState;
    notifyListeners();

    // Log state transitions for debugging
    if (kDebugMode) {
      _logger.d(
        'MVP-FL-004-DEBUG: $runtimeType state changed: $oldStatus -> ${newState.status}',
      );
    }
  }

  /// Executes an async operation with automatic state management
  ///
  /// This method:
  /// 1. Sets the state to loading
  /// 2. Executes the operation
  /// 3. Sets the state to success or error based on the result
  ///
  /// [operation] - The async operation to execute
  /// [onSuccess] - Callback to create success state from the result
  /// [onError] - Optional callback to create error state (uses default if not provided)
  /// [showLoading] - Whether to show loading state (default: true)
  @protected
  Future<void> executeAsync<R>({
    required Future<R> Function() operation,
    required T Function(R result) onSuccess,
    T Function(dynamic error, StackTrace stackTrace)? onError,
    bool showLoading = true,
  }) async {
    try {
      if (showLoading) {
        setState(_createLoadingState() as T);
      }

      final result = await operation();
      setState(onSuccess(result));
    } catch (error, stackTrace) {
      _logger.e(
        'MVP-FL-004-ERROR: Error in $runtimeType',
        error: error,
        stackTrace: stackTrace,
      );

      if (onError != null) {
        setState(onError(error, stackTrace));
      } else {
        setState(_createErrorState(error, stackTrace) as T);
      }
    }
  }

  /// Creates a loading state
  ///
  /// Override this method in subclasses to provide custom loading states
  @protected
  BaseState _createLoadingState() {
    return GenericState.loading(data: _state.data);
  }

  /// Creates an error state
  ///
  /// Override this method in subclasses to provide custom error states
  @protected
  BaseState _createErrorState(dynamic error, StackTrace stackTrace) {
    String message = 'An error occurred';
    if (error is Exception) {
      message = error.toString().replaceFirst('Exception: ', '');
    } else if (error is Error) {
      message = error.toString();
    }

    return GenericState.error(message, error: error, data: _state.data);
  }

  /// Resets the state to initial
  ///
  /// Override this method in subclasses to provide custom initial states
  @protected
  void resetState() {
    setState(_createInitialState() as T);
  }

  /// Creates an initial state
  ///
  /// Override this method in subclasses to provide custom initial states
  @protected
  BaseState _createInitialState() {
    return GenericState.initial();
  }

  @override
  void dispose() {
    _logger.d('MVP-FL-004-DEBUG: Disposing $runtimeType');
    super.dispose();
  }
}
