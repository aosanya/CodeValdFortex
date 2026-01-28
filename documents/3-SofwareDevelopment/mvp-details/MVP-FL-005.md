# MVP-FL-005: API Client Layer

## Overview
**Priority**: P0  
**Effort**: Medium  
**Skills**: Dio, Dart, REST APIs  
**Dependencies**: MVP-FL-004 (State Management Architecture) ✅

Create a robust and reusable API client layer using Dio for HTTP communication with the CodeValdCortex backend. This layer provides centralized request/response handling, error management, authentication token injection, and logging capabilities.

## Requirements

### Functional Requirements
1. **Dio Client Configuration**
   - Configure Dio instance with base URL from environment
   - Set connection timeout (30s), receive timeout (30s), send timeout (30s)
   - Support multiple environments (development, staging, production)
   - Configure request/response headers (JSON content-type, accept headers)

2. **Interceptor System**
   - **Authentication Interceptor**: Inject JWT tokens into requests
   - **Logging Interceptor**: Log requests/responses in debug mode (with MVP-FL-005 prefix)
   - **Error Interceptor**: Transform HTTP errors into application-specific exceptions
   - **Retry Interceptor**: Automatic retry logic for failed requests (optional)

3. **Error Handling**
   - Standardized `ApiException` class hierarchy
   - Network error handling (no connection, timeout)
   - HTTP error mapping (400, 401, 403, 404, 500 errors)
   - User-friendly error messages
   - Debug error information preservation

4. **Token Management**
   - Secure token storage using `flutter_secure_storage`
   - Automatic token injection in Authorization header
   - Token refresh logic (detect 401, refresh token, retry original request)
   - Token expiry handling

5. **API Service Factory**
   - Factory pattern for creating domain-specific API services
   - Shared Dio instance across services
   - Type-safe request/response handling

### Non-Functional Requirements
1. **Security**: Secure token storage, HTTPS enforcement
2. **Performance**: Connection pooling, request caching (future)
3. **Maintainability**: Clean separation of concerns, easy to extend
4. **Developer Experience**: Clear error messages, comprehensive logging
5. **Testability**: Mockable services for unit testing

## Technical Specifications

### Architecture

#### Component Structure
```
lib/core/api/
├── api_config.dart                 # API configuration (base URLs, timeouts)
├── dio_client.dart                 # Dio instance factory and configuration
├── api_error.dart                  # ApiError model class
├── api_exception.dart              # Exception hierarchy
├── api_service_factory.dart        # Factory for creating API services
├── api.dart                        # Barrel export file
└── interceptors/
    ├── auth_interceptor.dart       # JWT token injection
    ├── logging_interceptor.dart    # Request/response logging
    └── error_interceptor.dart      # Error transformation
```

#### Request Flow
```
┌─────────────────────────────────────────────────────────────┐
│                    Flutter Widget (View)                    │
└──────────────────────┬──────────────────────────────────────┘
                       │ Calls method
                       │
┌──────────────────────▼──────────────────────────────────────┐
│                       ViewModel                             │
│              (Business logic layer)                         │
└──────────────────────┬──────────────────────────────────────┘
                       │ Calls repository
                       │
┌──────────────────────▼──────────────────────────────────────┐
│                     Repository                              │
│            (Data access abstraction)                        │
└──────────────────────┬──────────────────────────────────────┘
                       │ Uses API service
                       │
┌──────────────────────▼──────────────────────────────────────┐
│                    API Service                              │
│       (Domain-specific HTTP methods)                        │
│    - getWorkItems(), createWorkItem()                       │
└──────────────────────┬──────────────────────────────────────┘
                       │ Uses Dio client
                       │
┌──────────────────────▼──────────────────────────────────────┐
│                     Dio Client                              │
│         (Configured Dio instance)                           │
└──────────────────────┬──────────────────────────────────────┘
                       │ Passes through interceptors
                       │
┌──────────────────────▼──────────────────────────────────────┐
│                    Interceptors                             │
│  1. Auth (add token) → 2. Logging → 3. Error handling       │
└──────────────────────┬──────────────────────────────────────┘
                       │ HTTP request
                       │
┌──────────────────────▼──────────────────────────────────────┐
│              CodeValdCortex Backend API                     │
│                 (Go + REST APIs)                            │
└─────────────────────────────────────────────────────────────┘
```

### Implementation Details

#### 1. API Configuration (`api_config.dart`)
```dart
class ApiConfig {
  static const String _devBaseUrl = 'http://localhost:8080/api/v1';
  static const String _prodBaseUrl = 'https://api.codevald.com/api/v1';
  
  static String get baseUrl {
    return const String.fromEnvironment('API_BASE_URL',
      defaultValue: _devBaseUrl);
  }
  
  static const Duration connectTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);
  static const Duration sendTimeout = Duration(seconds: 30);
  
  static const Map<String, String> defaultHeaders = {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };
}
```

#### 2. Dio Client Factory (`dio_client.dart`)
```dart
class DioClient {
  static Dio? _instance;
  
  static Dio get instance {
    if (_instance == null) {
      _instance = Dio(
        BaseOptions(
          baseUrl: ApiConfig.baseUrl,
          connectTimeout: ApiConfig.connectTimeout,
          receiveTimeout: ApiConfig.receiveTimeout,
          sendTimeout: ApiConfig.sendTimeout,
          headers: ApiConfig.defaultHeaders,
        ),
      );
      
      // Add interceptors
      _instance!.interceptors.addAll([
        AuthInterceptor(),
        LoggingInterceptor(),
        ErrorInterceptor(),
      ]);
    }
    return _instance!;
  }
  
  // For testing - allow resetting the instance
  static void reset() {
    _instance = null;
  }
}
```

#### 3. API Exception Hierarchy (`api_exception.dart`)
```dart
abstract class ApiException implements Exception {
  final String message;
  final int? statusCode;
  final dynamic originalError;
  
  ApiException(this.message, {this.statusCode, this.originalError});
}

class NetworkException extends ApiException {
  NetworkException(String message, {dynamic originalError})
      : super(message, originalError: originalError);
}

class UnauthorizedException extends ApiException {
  UnauthorizedException(String message)
      : super(message, statusCode: 401);
}

class NotFoundException extends ApiException {
  NotFoundException(String message)
      : super(message, statusCode: 404);
}

class ServerException extends ApiException {
  ServerException(String message, {int? statusCode})
      : super(message, statusCode: statusCode);
}

class ValidationException extends ApiException {
  final Map<String, List<String>> errors;
  
  ValidationException(String message, this.errors)
      : super(message, statusCode: 400);
}
```

#### 4. Authentication Interceptor (`auth_interceptor.dart`)
```dart
class AuthInterceptor extends Interceptor {
  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  
  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final token = await _storage.read(key: 'auth_token');
    
    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    
    handler.next(options);
  }
  
  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    // Handle 401 - token expired, refresh and retry
    if (err.response?.statusCode == 401) {
      try {
        await _refreshToken();
        final options = err.requestOptions;
        final response = await DioClient.instance.fetch(options);
        handler.resolve(response);
        return;
      } catch (e) {
        // Refresh failed, logout user
        handler.reject(err);
        return;
      }
    }
    
    handler.next(err);
  }
  
  Future<void> _refreshToken() async {
    // TODO: Implement token refresh logic (MVP-FL-009)
    throw UnimplementedError('Token refresh not yet implemented');
  }
}
```

#### 5. Logging Interceptor (`logging_interceptor.dart`)
```dart
class LoggingInterceptor extends Interceptor {
  final Logger _logger = Logger(printer: PrettyPrinter());
  
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    if (kDebugMode) {
      _logger.i('MVP-FL-005-REQUEST: ${options.method} ${options.path}');
      _logger.d('Headers: ${options.headers}');
      if (options.data != null) {
        _logger.d('Body: ${options.data}');
      }
    }
    handler.next(options);
  }
  
  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    if (kDebugMode) {
      _logger.i('MVP-FL-005-RESPONSE: ${response.statusCode} ${response.requestOptions.path}');
      _logger.d('Data: ${response.data}');
    }
    handler.next(response);
  }
  
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (kDebugMode) {
      _logger.e('MVP-FL-005-ERROR: ${err.requestOptions.method} ${err.requestOptions.path}');
      _logger.e('Message: ${err.message}');
      _logger.e('Response: ${err.response?.data}');
    }
    handler.next(err);
  }
}
```

#### 6. Error Interceptor (`error_interceptor.dart`)
```dart
class ErrorInterceptor extends Interceptor {
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    ApiException apiException;
    
    switch (err.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        apiException = NetworkException(
          'Connection timeout. Please check your internet connection.',
          originalError: err,
        );
        break;
        
      case DioExceptionType.badResponse:
        apiException = _handleResponseError(err);
        break;
        
      case DioExceptionType.cancel:
        apiException = NetworkException('Request cancelled', originalError: err);
        break;
        
      default:
        apiException = NetworkException(
          'Network error occurred. Please try again.',
          originalError: err,
        );
    }
    
    handler.reject(
      DioException(
        requestOptions: err.requestOptions,
        error: apiException,
        type: err.type,
      ),
    );
  }
  
  ApiException _handleResponseError(DioException err) {
    final statusCode = err.response?.statusCode;
    final data = err.response?.data;
    
    switch (statusCode) {
      case 400:
        return ValidationException(
          data['message'] ?? 'Invalid request',
          data['errors'] ?? {},
        );
      case 401:
        return UnauthorizedException(
          data['message'] ?? 'Unauthorized access',
        );
      case 403:
        return UnauthorizedException(
          data['message'] ?? 'Access forbidden',
        );
      case 404:
        return NotFoundException(
          data['message'] ?? 'Resource not found',
        );
      case 500:
      case 502:
      case 503:
        return ServerException(
          data['message'] ?? 'Server error occurred',
          statusCode: statusCode,
        );
      default:
        return ServerException(
          'Unexpected error occurred',
          statusCode: statusCode,
        );
    }
  }
}
```

## Acceptance Criteria

- [ ] `ApiConfig` class created with environment-based configuration
- [ ] `DioClient` factory implemented with proper Dio configuration
- [ ] `ApiException` hierarchy created (Network, Unauthorized, NotFound, Server, Validation)
- [ ] `AuthInterceptor` implemented with token injection (token refresh stubbed)
- [ ] `LoggingInterceptor` implemented with debug-mode logging
- [ ] `ErrorInterceptor` implemented with HTTP error transformation
- [ ] `FlutterSecureStorage` integrated for secure token storage
- [ ] Barrel export file (`api.dart`) created
- [ ] Dependencies added to pubspec.yaml (dio, flutter_secure_storage, logger)
- [ ] Code follows Dart style guidelines (passes `flutter analyze`)
- [ ] Code formatted with `dart format`
- [ ] Documentation updated with API client usage patterns

## Testing Requirements

### Unit Tests (Future - MVP-FL-028)
- Test Dio client configuration
- Test interceptor behavior
- Test error transformation logic
- Mock API responses for testing

### Integration Tests (Future - MVP-FL-030)
- Test end-to-end API calls
- Test authentication flow
- Test error handling with real backend

## Implementation Notes

### Dependencies Required
```yaml
dependencies:
  dio: ^5.4.0
  flutter_secure_storage: ^9.0.0
  logger: ^2.0.2+1

dev_dependencies:
  mockito: ^5.4.4  # For testing
```

### Token Refresh Logic
- Placeholder implementation in `AuthInterceptor`
- Full implementation will be completed in MVP-FL-009 (Authentication State Management)
- For now, throws `UnimplementedError` when 401 is encountered

### Future Enhancements
- Request caching with cache interceptor
- Retry logic with exponential backoff
- Request queueing for offline mode
- Certificate pinning for enhanced security
- Request deduplication
- GraphQL support (if needed)

## References

- [Dio Documentation](https://pub.dev/packages/dio)
- [Flutter Secure Storage](https://pub.dev/packages/flutter_secure_storage)
- [State Management Documentation](/documents/2-SoftwareDesignAndArchitecture/state-management.md)
- [CodeValdCortex API Specification](/workspaces/CodeValdCortex/api/)

## Completion Status

✅ **Task Completed**: January 28, 2026

All acceptance criteria met. API Client Layer successfully implemented with:
- Complete Dio configuration with environment-based settings
- Full exception hierarchy for standardized error handling
- Authentication, logging, and error interceptors
- Secure token storage with flutter_secure_storage
- Comprehensive documentation with usage patterns
- Code quality validation (passes flutter analyze with 0 errors)

**Files Created:**
- `lib/core/api/api_config.dart` - API configuration
- `lib/core/api/dio_client.dart` - Dio client factory
- `lib/core/api/api_exception.dart` - Exception hierarchy
- `lib/core/api/interceptors/auth_interceptor.dart` - Authentication interceptor
- `lib/core/api/interceptors/error_interceptor.dart` - Error transformation
- `lib/core/api/interceptors/logging_interceptor.dart` - Request/response logging
- `lib/core/api/api.dart` - Barrel export file
- `documents/2-SoftwareDesignAndArchitecture/api-client.md` - Documentation

Ready for next task: **MVP-FL-006** (Work Items State Management)
