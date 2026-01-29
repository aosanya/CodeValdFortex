import 'dart:async';

/// Events that can be triggered by authentication failures
enum AuthEvent {
  /// Token is missing when making API calls
  tokenMissing,

  /// Token refresh failed after 401 response
  tokenRefreshFailed,

  /// Token expired and needs refresh
  tokenExpired,
}

/// Singleton notifier for authentication events
///
/// Used to communicate auth failures from interceptors to the UI layer
class AuthEventNotifier {
  static final AuthEventNotifier _instance = AuthEventNotifier._internal();

  factory AuthEventNotifier() => _instance;

  AuthEventNotifier._internal();

  final _controller = StreamController<AuthEvent>.broadcast();
  bool _isHandlingEvent = false;
  DateTime? _lastEventTime;

  /// Stream of authentication events
  Stream<AuthEvent> get events => _controller.stream;

  /// Emit an authentication event with debouncing to prevent loops
  void emit(AuthEvent event) {
    // Prevent emitting events too frequently (debounce 5 seconds)
    final now = DateTime.now();
    if (_lastEventTime != null &&
        now.difference(_lastEventTime!) < const Duration(seconds: 5)) {
      return;
    }

    if (!_controller.isClosed && !_isHandlingEvent) {
      _lastEventTime = now;
      _controller.add(event);
    }
  }

  /// Mark that an event is being handled
  void setHandling(bool handling) {
    _isHandlingEvent = handling;
  }

  /// Reset the event handler state
  void reset() {
    _isHandlingEvent = false;
    _lastEventTime = null;
  }

  /// Dispose the notifier
  void dispose() {
    _controller.close();
  }
}

/// Global instance for easy access
final authEventNotifier = AuthEventNotifier();
