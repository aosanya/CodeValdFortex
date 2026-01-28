/// API configuration for CodeVald Fortex application
///
/// Provides centralized configuration for API base URLs, timeouts,
/// and default headers based on environment settings.
class ApiConfig {
  // Private constructor to prevent instantiation
  ApiConfig._();

  /// Development environment base URL
  static const String _devBaseUrl = 'http://localhost:8080/api/v1';

  /// Production environment base URL
  // ignore: unused_field
  static const String _prodBaseUrl = 'https://api.codevald.com/api/v1';

  /// Staging environment base URL
  // ignore: unused_field
  static const String _stagingBaseUrl =
      'https://staging-api.codevald.com/api/v1';

  /// Get base URL based on environment
  ///
  /// Can be overridden using --dart-define API_BASE_URL
  /// Defaults to development URL
  static String get baseUrl {
    return const String.fromEnvironment(
      'API_BASE_URL',
      defaultValue: _devBaseUrl,
    );
  }

  /// Get environment name
  static String get environment {
    return const String.fromEnvironment(
      'ENVIRONMENT',
      defaultValue: 'development',
    );
  }

  /// Check if running in development mode
  static bool get isDevelopment => environment == 'development';

  /// Check if running in production mode
  static bool get isProduction => environment == 'production';

  /// Check if running in staging mode
  static bool get isStaging => environment == 'staging';

  /// Connection timeout duration
  static const Duration connectTimeout = Duration(seconds: 30);

  /// Receive timeout duration
  static const Duration receiveTimeout = Duration(seconds: 30);

  /// Send timeout duration
  static const Duration sendTimeout = Duration(seconds: 30);

  /// Default request headers
  static const Map<String, String> defaultHeaders = {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
    'X-Client-Platform': 'flutter',
    'X-Client-Version': '1.0.0',
  };

  /// API version
  static const String apiVersion = 'v1';

  /// Maximum number of retry attempts
  static const int maxRetryAttempts = 3;

  /// Retry delay duration
  static const Duration retryDelay = Duration(seconds: 2);
}
