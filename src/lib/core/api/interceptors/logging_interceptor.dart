import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart';

/// Logging interceptor for debugging API requests and responses
///
/// Logs request details, response data, and errors in debug mode only.
/// Uses MVP-FL-005 prefix for easy identification in logs.
class LoggingInterceptor extends Interceptor {
  final Logger _logger;

  LoggingInterceptor({Logger? logger})
    : _logger =
          logger ??
          Logger(
            printer: PrettyPrinter(
              methodCount: 0,
              errorMethodCount: 5,
              lineLength: 80,
              colors: true,
              printEmojis: true,
              dateTimeFormat: DateTimeFormat.onlyTimeAndSinceStart,
            ),
          );

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    if (kDebugMode) {
      _logger.i('MVP-FL-005-REQUEST: ${options.method} ${options.path}');
      _logger.d('Base URL: ${options.baseUrl}');
      _logger.d('Headers: ${_sanitizeHeaders(options.headers)}');

      if (options.queryParameters.isNotEmpty) {
        _logger.d('Query Parameters: ${options.queryParameters}');
      }

      if (options.data != null) {
        _logger.d('Body: ${_formatData(options.data)}');
      }
    }

    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    if (kDebugMode) {
      _logger.i(
        'MVP-FL-005-RESPONSE: ${response.statusCode} ${response.requestOptions.method} ${response.requestOptions.path}',
      );
      _logger.d('Response Data: ${_formatData(response.data)}');
    }

    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (kDebugMode) {
      _logger.e(
        'MVP-FL-005-ERROR: ${err.requestOptions.method} ${err.requestOptions.path}',
      );
      _logger.e('Error Type: ${err.type}');
      _logger.e('Error Message: ${err.message}');

      if (err.response != null) {
        _logger.e('Status Code: ${err.response?.statusCode}');
        _logger.e('Response Data: ${err.response?.data}');
      }

      _logger.e('Stack Trace:', error: err.error, stackTrace: err.stackTrace);
    }

    handler.next(err);
  }

  /// Sanitize headers to hide sensitive information
  Map<String, dynamic> _sanitizeHeaders(Map<String, dynamic> headers) {
    final sanitized = Map<String, dynamic>.from(headers);

    // Hide authorization tokens
    if (sanitized.containsKey('Authorization')) {
      sanitized['Authorization'] = '***HIDDEN***';
    }

    // Hide API keys
    if (sanitized.containsKey('X-API-Key')) {
      sanitized['X-API-Key'] = '***HIDDEN***';
    }

    return sanitized;
  }

  /// Format data for logging (truncate if too long)
  String _formatData(dynamic data) {
    if (data == null) return 'null';

    final dataString = data.toString();
    const maxLength = 1000;

    if (dataString.length > maxLength) {
      return '${dataString.substring(0, maxLength)}... (truncated)';
    }

    return dataString;
  }
}
