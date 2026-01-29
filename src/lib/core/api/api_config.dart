import '../../config/app_config.dart';

/// API configuration for CodeVald Fortex application
///
/// Provides centralized configuration for API base URLs, timeouts,
/// and default headers based on environment settings.
/// 
/// Uses AppConfig which loads values from .env files.
class ApiConfig {
  // Private constructor to prevent instantiation
  ApiConfig._();

  /// Get base URL from AppConfig (loaded from .env file)
  static String get baseUrl => AppConfig.apiBaseUrl;

  /// Get environment name from AppConfig
  static String get environment => AppConfig.environment;

  /// Check if running in development mode
  static bool get isDevelopment => AppConfig.isDevelopment;

  /// Check if running in production mode
  static bool get isProduction => AppConfig.isProduction;

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
