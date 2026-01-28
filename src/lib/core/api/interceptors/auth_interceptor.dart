import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Callback for token refresh
typedef TokenRefreshCallback = Future<bool> Function();

/// Authentication interceptor for JWT token injection
///
/// Automatically adds JWT tokens to request headers and handles
/// token refresh logic when receiving 401 responses.
class AuthInterceptor extends Interceptor {
  final FlutterSecureStorage _storage;
  TokenRefreshCallback? onTokenRefresh;

  /// Auth token storage key
  static const String authTokenKey = 'auth_token';

  /// Refresh token storage key
  static const String refreshTokenKey = 'refresh_token';

  AuthInterceptor({FlutterSecureStorage? storage, this.onTokenRefresh})
    : _storage = storage ?? const FlutterSecureStorage();

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    try {
      // Read token from secure storage
      final token = await _storage.read(key: authTokenKey);

      if (token != null && token.isNotEmpty) {
        // Add Authorization header with Bearer token
        options.headers['Authorization'] = 'Bearer $token';
      }

      handler.next(options);
    } catch (e) {
      // If token retrieval fails, continue without token
      handler.next(options);
    }
  }

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    // Handle 401 Unauthorized - token expired or invalid
    if (err.response?.statusCode == 401) {
      try {
        // Attempt to refresh the token
        final refreshed = await _refreshToken();

        if (refreshed) {
          // Retry the original request with new token
          final options = err.requestOptions;
          final token = await _storage.read(key: authTokenKey);

          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }

          // Create new Dio instance to avoid interceptor loop
          final dio = Dio();
          final response = await dio.fetch(options);
          handler.resolve(response);
          return;
        }
      } catch (e) {
        // Token refresh failed, clear tokens and propagate error
        await _clearTokens();
        handler.next(err);
        return;
      }
    }

    handler.next(err);
  }

  /// Refresh authentication token
  Future<bool> _refreshToken() async {
    if (onTokenRefresh != null) {
      return await onTokenRefresh!();
    }
    return false;
  }

  /// Clear all stored tokens
  Future<void> _clearTokens() async {
    await _storage.delete(key: authTokenKey);
    await _storage.delete(key: refreshTokenKey);
  }

  /// Manually set authentication token (for testing or manual login)
  Future<void> setAuthToken(String token) async {
    await _storage.write(key: authTokenKey, value: token);
  }

  /// Manually set refresh token
  Future<void> setRefreshToken(String token) async {
    await _storage.write(key: refreshTokenKey, value: token);
  }

  /// Get current auth token
  Future<String?> getAuthToken() async {
    return await _storage.read(key: authTokenKey);
  }

  /// Check if user is authenticated (has valid token)
  Future<bool> isAuthenticated() async {
    final token = await _storage.read(key: authTokenKey);
    return token != null && token.isNotEmpty;
  }
}
