# API Client Layer Architecture

## Overview

The API Client Layer provides a robust, centralized HTTP communication infrastructure for the CodeVald Fortex application. Built on top of Dio, it handles all communication with the CodeValdCortex backend API.

## Architecture Components

### 1. API Configuration (`api_config.dart`)

Centralizes all API-related configuration:

```dart
import 'package:codevald_fortex/core/api/api.dart';

// Access base URL
final baseUrl = ApiConfig.baseUrl;

// Check environment
if (ApiConfig.isDevelopment) {
  // Development-specific logic
}
```

**Features:**
- Environment-based base URL selection
- Configurable timeouts (connect, receive, send)
- Default headers with client metadata
- Environment detection helpers

**Configuration via --dart-define:**
```bash
flutter run --dart-define=API_BASE_URL=https://api.codevald.com/api/v1 \
            --dart-define=ENVIRONMENT=production
```

### 2. Dio Client Factory (`dio_client.dart`)

Singleton factory for Dio instances:

```dart
import 'package:codevald_fortex/core/api/api.dart';

// Get the singleton instance
final dio = DioClient.instance;

// Make API calls
final response = await dio.get('/agencies');
```

**Features:**
- Singleton pattern for shared configuration
- Pre-configured interceptors
- Custom instance creation for special cases
- Instance reset capability for testing

### 3. Exception Hierarchy (`api_exception.dart`)

Standardized error handling:

```dart
try {
  final response = await dio.get('/agencies');
} on DioException catch (e) {
  if (e.error is UnauthorizedException) {
    // Handle authentication error
    navigateToLogin();
  } else if (e.error is NetworkException) {
    // Handle network error
    showNetworkErrorSnackbar();
  } else if (e.error is ValidationException) {
    final validationError = e.error as ValidationException;
    // Show field-specific errors
    validationError.errors.forEach((field, messages) {
      showFieldError(field, messages.first);
    });
  }
}
```

**Exception Types:**
- `NetworkException` - Connection timeouts, no internet
- `UnauthorizedException` - 401 errors
- `ForbiddenException` - 403 errors
- `NotFoundException` - 404 errors
- `ServerException` - 5xx errors
- `ValidationException` - 400/422 with field errors
- `RequestCancelledException` - Cancelled requests
- `UnknownApiException` - Unexpected errors

### 4. Interceptors

#### Authentication Interceptor
Automatically injects JWT tokens:

```dart
// Token is automatically added to all requests
final response = await dio.get('/protected-endpoint');
```

Manual token management:
```dart
final authInterceptor = AuthInterceptor();

// Set token after login
await authInterceptor.setAuthToken('your-jwt-token');

// Check authentication status
final isAuth = await authInterceptor.isAuthenticated();

// Clear tokens on logout
await authInterceptor._clearTokens(); // Private - will be exposed in MVP-FL-009
```

#### Logging Interceptor
Debug-mode logging with MVP-FL-005 prefix:

```
MVP-FL-005-REQUEST: GET /agencies
Headers: {Authorization: ***HIDDEN***, ...}

MVP-FL-005-RESPONSE: 200 GET /agencies
Data: [{id: 1, name: Agency 1}, ...]
```

**Features:**
- Only logs in debug mode
- Sanitizes sensitive headers (Authorization, API keys)
- Truncates large payloads
- Pretty-printed with timestamps

#### Error Interceptor
Transforms HTTP errors into ApiExceptions:

```dart
// DioException with HTTP 404
// becomes
// DioException with error: NotFoundException

// DioException with timeout
// becomes
// DioException with error: NetworkException
```

## Usage Patterns

### Basic API Call

```dart
import 'package:codevald_fortex/core/api/api.dart';
import 'package:dio/dio.dart';

Future<List<Agency>> fetchAgencies() async {
  try {
    final response = await DioClient.instance.get('/agencies');
    return (response.data as List)
        .map((json) => Agency.fromJson(json))
        .toList();
  } on DioException catch (e) {
    if (e.error is NetworkException) {
      throw Exception('Network error: ${e.error.message}');
    } else if (e.error is ServerException) {
      throw Exception('Server error: ${e.error.message}');
    }
    rethrow;
  }
}
```

### With ViewModel Integration

```dart
class AgencyViewModel extends BaseViewModel<AgencyState> {
  final Dio _dio = DioClient.instance;

  Future<void> loadAgencies() async {
    await executeAsync<List<Agency>>(
      operation: () async {
        final response = await _dio.get('/agencies');
        return (response.data as List)
            .map((json) => Agency.fromJson(json))
            .toList();
      },
      onSuccess: (agencies) => AgencyState.success(agencies),
      onError: (error, stackTrace) {
        if (error is DioException && error.error is ApiException) {
          return AgencyState.error(error.error.message);
        }
        return AgencyState.error('Failed to load agencies');
      },
    );
  }
}
```

### POST Request with Validation

```dart
Future<Agency> createAgency(AgencyCreateRequest request) async {
  try {
    final response = await DioClient.instance.post(
      '/agencies',
      data: request.toJson(),
    );
    return Agency.fromJson(response.data);
  } on DioException catch (e) {
    if (e.error is ValidationException) {
      final validationError = e.error as ValidationException;
      // Handle field-specific errors
      throw ValidationException(
        'Validation failed',
        validationError.errors,
      );
    }
    rethrow;
  }
}
```

### File Upload

```dart
Future<void> uploadFile(String filePath) async {
  final formData = FormData.fromMap({
    'file': await MultipartFile.fromFile(
      filePath,
      filename: 'upload.pdf',
    ),
  });

  await DioClient.instance.post(
    '/upload',
    data: formData,
    options: Options(
      contentType: 'multipart/form-data',
    ),
  );
}
```

### Custom Headers

```dart
final response = await DioClient.instance.get(
  '/special-endpoint',
  options: Options(
    headers: {
      'X-Custom-Header': 'value',
    },
  ),
);
```

## Repository Pattern Integration

Create domain-specific repositories:

```dart
class AgencyRepository {
  final Dio _dio = DioClient.instance;

  Future<List<Agency>> getAll() async {
    final response = await _dio.get('/agencies');
    return (response.data as List)
        .map((json) => Agency.fromJson(json))
        .toList();
  }

  Future<Agency> getById(String id) async {
    final response = await _dio.get('/agencies/$id');
    return Agency.fromJson(response.data);
  }

  Future<Agency> create(AgencyCreateRequest request) async {
    final response = await _dio.post('/agencies', data: request.toJson());
    return Agency.fromJson(response.data);
  }

  Future<Agency> update(String id, AgencyUpdateRequest request) async {
    final response = await _dio.put('/agencies/$id', data: request.toJson());
    return Agency.fromJson(response.data);
  }

  Future<void> delete(String id) async {
    await _dio.delete('/agencies/$id');
  }
}
```

## Error Handling Best Practices

### 1. ViewModel Level

```dart
Future<void> loadData() async {
  await executeAsync<Data>(
    operation: () => _fetchData(),
    onSuccess: (data) => MyState.success(data),
    onError: (error, stackTrace) {
      String message = 'An error occurred';
      
      if (error is DioException && error.error is ApiException) {
        message = error.error.message;
      }
      
      return MyState.error(message);
    },
  );
}
```

### 2. Repository Level

```dart
Future<List<Item>> getItems() async {
  try {
    final response = await _dio.get('/items');
    return _parseItems(response.data);
  } on DioException catch (e) {
    if (e.error is ApiException) {
      // Re-throw ApiException for ViewModel to handle
      throw e.error;
    }
    // Unknown error
    throw Exception('Failed to fetch items');
  }
}
```

### 3. UI Level

```dart
if (state.hasError) {
  return ErrorWidget(
    message: state.errorMessage,
    onRetry: () => viewModel.loadData(),
  );
}
```

## Testing

### Mock Dio for Unit Tests

```dart
import 'package:mockito/mockito.dart';
import 'package:dio/dio.dart';

class MockDio extends Mock implements Dio {}

void main() {
  late MockDio mockDio;

  setUp(() {
    mockDio = MockDio();
  });

  test('should fetch agencies', () async {
    // Arrange
    when(mockDio.get('/agencies')).thenAnswer(
      (_) async => Response(
        data: [{'id': '1', 'name': 'Test Agency'}],
        statusCode: 200,
        requestOptions: RequestOptions(path: '/agencies'),
      ),
    );

    final repository = AgencyRepository(dio: mockDio);

    // Act
    final agencies = await repository.getAll();

    // Assert
    expect(agencies.length, 1);
    expect(agencies.first.name, 'Test Agency');
  });
}
```

## Performance Considerations

1. **Connection Pooling**: Dio automatically pools connections
2. **Request Cancellation**: Use `CancelToken` for cancellable requests
3. **Caching**: Future enhancement with cache interceptor
4. **Compression**: Dio handles gzip/deflate automatically

## Security

1. **Token Storage**: Uses `flutter_secure_storage` for encrypted storage
2. **HTTPS Enforcement**: Production URLs use HTTPS
3. **Header Sanitization**: Sensitive headers hidden in logs
4. **Certificate Pinning**: Future enhancement for production

## Future Enhancements

- [ ] Request caching with cache interceptor (offline support)
- [ ] Retry logic with exponential backoff
- [ ] Request queueing for offline mode
- [ ] Certificate pinning for enhanced security
- [ ] Request deduplication
- [ ] GraphQL support (if needed)
- [ ] WebSocket integration for real-time features

## Related Documentation

- [State Management Architecture](/documents/2-SoftwareDesignAndArchitecture/state-management.md)
- [MVP-FL-005 Specification](/documents/3-SofwareDevelopment/mvp-details/MVP-FL-005.md)
- [Dio Documentation](https://pub.dev/packages/dio)

---

**Last Updated**: January 28, 2026  
**Task**: MVP-FL-005 (API Client Layer)
