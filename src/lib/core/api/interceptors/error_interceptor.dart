import 'package:dio/dio.dart';
import '../api_exception.dart';

/// Error interceptor for transforming Dio errors into ApiExceptions
///
/// Provides standardized error handling across the application by
/// converting HTTP errors and network errors into custom exceptions.
class ErrorInterceptor extends Interceptor {
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    final apiException = _transformError(err);

    // Create new DioException with our custom exception as the error
    final transformedError = DioException(
      requestOptions: err.requestOptions,
      error: apiException,
      type: err.type,
      response: err.response,
    );

    handler.reject(transformedError);
  }

  /// Transform DioException into ApiException
  ApiException _transformError(DioException err) {
    switch (err.type) {
      case DioExceptionType.connectionTimeout:
        return NetworkException(
          'Connection timeout. Please check your internet connection.',
          originalError: err,
          stackTrace: err.stackTrace,
        );

      case DioExceptionType.sendTimeout:
        return NetworkException(
          'Request send timeout. Please try again.',
          originalError: err,
          stackTrace: err.stackTrace,
        );

      case DioExceptionType.receiveTimeout:
        return NetworkException(
          'Response receive timeout. The server is taking too long to respond.',
          originalError: err,
          stackTrace: err.stackTrace,
        );

      case DioExceptionType.badResponse:
        return _handleResponseError(err);

      case DioExceptionType.cancel:
        return RequestCancelledException(
          'Request was cancelled.',
          originalError: err,
          stackTrace: err.stackTrace,
        );

      case DioExceptionType.connectionError:
        return NetworkException(
          'Network connection error. Please check your internet connection.',
          originalError: err,
          stackTrace: err.stackTrace,
        );

      case DioExceptionType.badCertificate:
        return NetworkException(
          'SSL certificate validation failed.',
          originalError: err,
          stackTrace: err.stackTrace,
        );

      case DioExceptionType.unknown:
        return UnknownApiException(
          'An unexpected error occurred. Please try again.',
          originalError: err,
          stackTrace: err.stackTrace,
        );
    }
  }

  /// Handle HTTP response errors based on status code
  ApiException _handleResponseError(DioException err) {
    final statusCode = err.response?.statusCode;
    final data = err.response?.data;

    // Extract message from response if available
    String? message;
    if (data is Map<String, dynamic>) {
      message =
          data['message'] as String? ??
          data['error'] as String? ??
          data['detail'] as String?;
    }

    switch (statusCode) {
      case 400:
        // Bad Request - validation errors
        if (data is Map<String, dynamic> && data.containsKey('errors')) {
          final errors = data['errors'] as Map<String, dynamic>? ?? {};
          final fieldErrors = <String, List<String>>{};

          errors.forEach((key, value) {
            if (value is List) {
              fieldErrors[key] = value.map((e) => e.toString()).toList();
            } else if (value is String) {
              fieldErrors[key] = [value];
            }
          });

          return ValidationException(
            message ?? 'Validation failed. Please check your input.',
            fieldErrors,
            originalError: err,
            stackTrace: err.stackTrace,
          );
        }

        return ValidationException(
          message ?? 'Invalid request. Please check your input.',
          {},
          originalError: err,
          stackTrace: err.stackTrace,
        );

      case 401:
        return UnauthorizedException(
          message ?? 'Unauthorized. Please log in again.',
          originalError: err,
          stackTrace: err.stackTrace,
        );

      case 403:
        return ForbiddenException(
          message ?? 'Access forbidden. You do not have permission.',
          originalError: err,
          stackTrace: err.stackTrace,
        );

      case 404:
        return NotFoundException(
          message ?? 'Resource not found.',
          originalError: err,
          stackTrace: err.stackTrace,
        );

      case 409:
        return ValidationException(
          message ?? 'Conflict. The resource already exists.',
          {},
          originalError: err,
          stackTrace: err.stackTrace,
        );

      case 422:
        // Unprocessable Entity - validation errors
        if (data is Map<String, dynamic> && data.containsKey('errors')) {
          final errors = data['errors'] as Map<String, dynamic>? ?? {};
          final fieldErrors = <String, List<String>>{};

          errors.forEach((key, value) {
            if (value is List) {
              fieldErrors[key] = value.map((e) => e.toString()).toList();
            } else if (value is String) {
              fieldErrors[key] = [value];
            }
          });

          return ValidationException(
            message ?? 'Validation failed.',
            fieldErrors,
            originalError: err,
            stackTrace: err.stackTrace,
          );
        }

        return ValidationException(
          message ?? 'Unprocessable entity.',
          {},
          originalError: err,
          stackTrace: err.stackTrace,
        );

      case 429:
        return ServerException(
          message ?? 'Too many requests. Please try again later.',
          statusCode: statusCode,
          originalError: err,
          stackTrace: err.stackTrace,
        );

      case 500:
        return ServerException(
          message ?? 'Internal server error. Please try again later.',
          statusCode: statusCode,
          originalError: err,
          stackTrace: err.stackTrace,
        );

      case 502:
        return ServerException(
          message ?? 'Bad gateway. Please try again later.',
          statusCode: statusCode,
          originalError: err,
          stackTrace: err.stackTrace,
        );

      case 503:
        return ServerException(
          message ?? 'Service unavailable. Please try again later.',
          statusCode: statusCode,
          originalError: err,
          stackTrace: err.stackTrace,
        );

      case 504:
        return ServerException(
          message ?? 'Gateway timeout. Please try again later.',
          statusCode: statusCode,
          originalError: err,
          stackTrace: err.stackTrace,
        );
    }

    // Default case - unexpected status code
    return ServerException(
      message ?? 'An error occurred. Please try again.',
      statusCode: statusCode,
      originalError: err,
      stackTrace: err.stackTrace,
    );
  }
}
