import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Environment configuration manager
class AppConfig {
  static late String apiBaseUrl;
  static late String wsBaseUrl;
  static late String environment;
  static late bool debugMode;
  static late String logLevel;

  /// Initialize app configuration from environment file
  static Future<void> initialize({String env = 'development'}) async {
    // Load environment file
    await dotenv.load(fileName: '.env.$env');

    // Set configuration values
    apiBaseUrl = dotenv.get(
      'API_BASE_URL',
      fallback: 'http://localhost:8080/api/v1',
    );
    wsBaseUrl = dotenv.get('WS_BASE_URL', fallback: 'ws://localhost:8080/ws');
    environment = dotenv.get('ENVIRONMENT', fallback: 'development');
    debugMode =
        dotenv.get('DEBUG_MODE', fallback: 'false').toLowerCase() == 'true';
    logLevel = dotenv.get('LOG_LEVEL', fallback: 'info');
  }

  /// Check if running in production
  static bool get isProduction => environment == 'production';

  /// Check if running in development
  static bool get isDevelopment => environment == 'development';
}
