import 'package:dio/dio.dart';
import 'api_config.dart';
import 'interceptors/auth_interceptor.dart';
import 'interceptors/error_interceptor.dart';
import 'interceptors/logging_interceptor.dart';

/// Dio client factory for creating configured Dio instances
///
/// Provides a singleton Dio instance with all necessary interceptors
/// and configuration for API communication.
class DioClient {
  static Dio? _instance;
  static AuthInterceptor? _authInterceptor;

  // Private constructor to prevent external instantiation
  DioClient._();

  /// Get singleton Dio instance
  static Dio get instance {
    _instance ??= _createDioInstance();
    return _instance!;
  }

  /// Convenience getter for dio (same as instance)
  static Dio get dio => instance;

  /// Set token refresh callback
  static void setTokenRefreshCallback(Future<bool> Function() onTokenRefresh) {
    _authInterceptor?.onTokenRefresh = onTokenRefresh;
  }

  /// Create and configure Dio instance
  static Dio _createDioInstance() {
    final dio = Dio(
      BaseOptions(
        baseUrl: ApiConfig.baseUrl,
        connectTimeout: ApiConfig.connectTimeout,
        receiveTimeout: ApiConfig.receiveTimeout,
        sendTimeout: ApiConfig.sendTimeout,
        headers: ApiConfig.defaultHeaders,
        // Response type for JSON
        responseType: ResponseType.json,
        // Content type for requests
        contentType: Headers.jsonContentType,
      ),
    );

    // Create auth interceptor instance
    _authInterceptor = AuthInterceptor();

    // Add interceptors in order of execution
    dio.interceptors.addAll([
      // 1. Authentication - adds tokens to requests
      _authInterceptor!,

      // 2. Logging - logs requests and responses (debug mode only)
      LoggingInterceptor(),

      // 3. Error handling - transforms errors into ApiExceptions
      ErrorInterceptor(),
    ]);

    return dio;
  }

  /// Reset the Dio instance (useful for testing or re-configuration)
  static void reset() {
    _instance?.close();
    _instance = null;
  }

  /// Create a new Dio instance without interceptors (for special cases)
  static Dio createBasicInstance() {
    return Dio(
      BaseOptions(
        baseUrl: ApiConfig.baseUrl,
        connectTimeout: ApiConfig.connectTimeout,
        receiveTimeout: ApiConfig.receiveTimeout,
        sendTimeout: ApiConfig.sendTimeout,
        headers: ApiConfig.defaultHeaders,
      ),
    );
  }

  /// Create a Dio instance with custom configuration
  static Dio createCustomInstance({
    String? baseUrl,
    Duration? connectTimeout,
    Duration? receiveTimeout,
    Map<String, dynamic>? headers,
    List<Interceptor>? interceptors,
  }) {
    final dio = Dio(
      BaseOptions(
        baseUrl: baseUrl ?? ApiConfig.baseUrl,
        connectTimeout: connectTimeout ?? ApiConfig.connectTimeout,
        receiveTimeout: receiveTimeout ?? ApiConfig.receiveTimeout,
        sendTimeout: ApiConfig.sendTimeout,
        headers: headers ?? ApiConfig.defaultHeaders,
      ),
    );

    if (interceptors != null) {
      dio.interceptors.addAll(interceptors);
    }

    return dio;
  }
}
