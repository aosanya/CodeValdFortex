/// Base class for all API-related exceptions
///
/// Provides a consistent interface for handling various types of
/// API errors throughout the application.
abstract class ApiException implements Exception {
  /// User-friendly error message
  final String message;

  /// HTTP status code (if applicable)
  final int? statusCode;

  /// Original error for debugging
  final dynamic originalError;

  /// Stack trace (if available)
  final StackTrace? stackTrace;

  const ApiException(
    this.message, {
    this.statusCode,
    this.originalError,
    this.stackTrace,
  });

  @override
  String toString() {
    if (statusCode != null) {
      return 'ApiException [$statusCode]: $message';
    }
    return 'ApiException: $message';
  }
}

/// Network-related errors (timeout, no connection, etc.)
class NetworkException extends ApiException {
  const NetworkException(
    super.message, {
    super.originalError,
    super.stackTrace,
  });

  @override
  String toString() => 'NetworkException: $message';
}

/// Unauthorized access (401)
class UnauthorizedException extends ApiException {
  const UnauthorizedException(
    super.message, {
    super.originalError,
    super.stackTrace,
  }) : super(statusCode: 401);

  @override
  String toString() => 'UnauthorizedException: $message';
}

/// Forbidden access (403)
class ForbiddenException extends ApiException {
  const ForbiddenException(
    super.message, {
    super.originalError,
    super.stackTrace,
  }) : super(statusCode: 403);

  @override
  String toString() => 'ForbiddenException: $message';
}

/// Resource not found (404)
class NotFoundException extends ApiException {
  const NotFoundException(
    super.message, {
    super.originalError,
    super.stackTrace,
  }) : super(statusCode: 404);

  @override
  String toString() => 'NotFoundException: $message';
}

/// Server errors (500, 502, 503, etc.)
class ServerException extends ApiException {
  const ServerException(
    super.message, {
    super.statusCode = 500,
    super.originalError,
    super.stackTrace,
  });

  @override
  String toString() => 'ServerException [$statusCode]: $message';
}

/// Validation errors (400) with field-specific messages
class ValidationException extends ApiException {
  /// Map of field names to error messages
  final Map<String, List<String>> errors;

  const ValidationException(
    super.message,
    this.errors, {
    super.originalError,
    super.stackTrace,
  }) : super(statusCode: 400);

  /// Get error messages for a specific field
  List<String> getFieldErrors(String field) {
    return errors[field] ?? [];
  }

  /// Check if a specific field has errors
  bool hasFieldError(String field) {
    return errors.containsKey(field) && errors[field]!.isNotEmpty;
  }

  /// Get all error messages as a flat list
  List<String> getAllErrors() {
    return errors.values.expand((e) => e).toList();
  }

  @override
  String toString() {
    final errorCount = errors.length;
    return 'ValidationException: $message ($errorCount field(s) with errors)';
  }
}

/// Request cancelled by user or system
class RequestCancelledException extends ApiException {
  const RequestCancelledException(
    super.message, {
    super.originalError,
    super.stackTrace,
  });

  @override
  String toString() => 'RequestCancelledException: $message';
}

/// Unknown or unexpected errors
class UnknownApiException extends ApiException {
  const UnknownApiException(
    super.message, {
    super.statusCode,
    super.originalError,
    super.stackTrace,
  });

  @override
  String toString() => 'UnknownApiException: $message';
}
