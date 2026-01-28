# MVP-FL-009: Authentication State Management

## Overview
**Priority**: P0  
**Effort**: Medium  
**Skills**: Riverpod, JWT, Dart, flutter_secure_storage  
**Dependencies**: MVP-FL-005 (API Client & Error Handling) ✅

Implement comprehensive authentication state management using Riverpod, including login/logout functionality, secure token storage, automatic token refresh, and user profile management. This forms the foundation for all authentication-related features in the application.

## Requirements

### Functional Requirements

1. **Authentication State**
   - Global authentication state management with Riverpod StateNotifier
   - Track authentication status (authenticated/unauthenticated/loading)
   - Store current user profile
   - Persist authentication across app restarts
   - Handle authentication errors

2. **User Login**
   - Email/password login
   - Store JWT access token and refresh token securely
   - Update authentication state on successful login
   - Navigate to home screen after login
   - Handle login errors

3. **Token Management**
   - Secure token storage using flutter_secure_storage
   - Automatic token refresh when expired (401 response)
   - Clear tokens on logout
   - Token expiry handling

4. **User Logout**
   - Clear stored tokens
   - Reset authentication state
   - Navigate to login screen
   - Call logout API endpoint

5. **User Profile**
   - Store user profile data (id, email, name, avatar, role)
   - Update profile when refreshed
   - Clear profile on logout

## Technical Design

### Data Models

#### AuthUser
```dart
class AuthUser {
  final String id;
  final String email;
  final String name;
  final String? avatar;
  final String? role;
  final DateTime? createdAt;
  final DateTime? updatedAt;
}
```

#### AuthState
```dart
enum AuthStatus { authenticated, unauthenticated, loading }

class AuthState {
  final AuthStatus status;
  final AuthUser? user;
  final String? errorMessage;
  final bool isLoading;
}
```

#### AuthResponse
```dart
class AuthResponse {
  final String token;
  final String refreshToken;
  final AuthUser user;
  final DateTime? expiresAt;
}
```

#### EmailLoginCredentials
```dart
class EmailLoginCredentials {
  final String email;
  final String password;
}
```

### Architecture Layers

1. **Service Layer** - `lib/services/auth_service.dart`
   - API calls to authentication endpoints
   - Handle HTTP requests/responses
   - Error transformation

2. **Repository Layer** - `lib/repositories/auth_repository.dart`
   - Token storage/retrieval (flutter_secure_storage)
   - User data persistence
   - Bridge between service and state management

3. **State Management Layer** - `lib/providers/auth_provider.dart`
   - Riverpod StateNotifier for global auth state
   - Business logic orchestration
   - State updates and notifications

### File Structure

```
lib/
  models/auth/
    auth_user.dart
    auth_state.dart
    auth_response.dart
    email_login_credentials.dart
    login_method.dart
  services/
    auth_service.dart
  repositories/
    auth_repository.dart
  providers/
    auth_provider.dart
```

## Implementation

### AuthService (API Layer)

```dart
class AuthService {
  final Dio _dio = DioClient.dio;

  Future<AuthResponse> loginWithEmail(EmailLoginCredentials credentials);
  Future<AuthResponse> refreshToken(String refreshToken);
  Future<void> logout();
  Future<AuthUser> getCurrentUser();
}
```

### AuthRepository (Data Layer)

```dart
class AuthRepository {
  final AuthService _authService;
  final FlutterSecureStorage _storage;

  Future<AuthUser> loginWithEmail(EmailLoginCredentials credentials);
  Future<AuthUser> refreshToken();
  Future<void> logout();
  Future<bool> isAuthenticated();
  Future<String?> getAuthToken();
  Future<String?> getRefreshToken();
  Future<AuthUser?> getStoredUser();
}
```

### AuthProvider (State Management)

```dart
class AuthNotifier extends StateNotifier<AuthState> {
  final AuthRepository _authRepository;

  Future<void> checkAuthStatus();
  Future<void> loginWithEmail(EmailLoginCredentials credentials);
  Future<void> refreshToken();
  Future<void> logout();
  void updateUser(AuthUser user);
}

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier(ref.read(authRepositoryProvider));
});

final isAuthenticatedProvider = Provider<bool>((ref) {
  return ref.watch(authProvider).isAuthenticated;
});

final currentUserProvider = Provider<AuthUser?>((ref) {
  return ref.watch(authProvider).user;
});
```

### Token Refresh Integration

**AuthInterceptor** (lib/core/api/interceptors/auth_interceptor.dart):
```dart
class AuthInterceptor extends Interceptor {
  TokenRefreshCallback? onTokenRefresh;

  @override
  Future<void> onError(DioException err, ErrorInterceptorHandler handler) async {
    if (err.response?.statusCode == 401) {
      if (onTokenRefresh != null) {
        final refreshed = await onTokenRefresh!();
        if (refreshed) {
          // Retry request with new token
        }
      }
    }
  }
}
```

**DioClient Configuration** (lib/core/api/dio_client.dart):
```dart
class DioClient {
  static void setTokenRefreshCallback(Future<bool> Function() callback) {
    _authInterceptor?.onTokenRefresh = callback;
  }
}
```

**Main App Initialization** (lib/main.dart):
```dart
void main() async {
  final container = ProviderContainer();
  
  DioClient.setTokenRefreshCallback(() async {
    try {
      await container.read(authProvider.notifier).refreshToken();
      return true;
    } catch (e) {
      return false;
    }
  });

  runApp(UncontrolledProviderScope(
    container: container,
    child: const CodeValdFortexApp(),
  ));
}
```

## API Endpoints

- `POST /api/v1/auth/login` - Email/password login
- `POST /api/v1/auth/refresh` - Refresh access token
- `POST /api/v1/auth/logout` - Logout user
- `GET /api/v1/auth/me` - Get current user profile

## Storage Keys

Using `flutter_secure_storage`:
- `auth_token` - JWT access token
- `refresh_token` - JWT refresh token
- `user` - JSON-encoded user profile
- `token_expiry` - Token expiration timestamp

## Acceptance Criteria

1. ✅ User can log in with email/password
2. ✅ Authentication state persists across app restarts
3. ✅ Tokens are stored securely
4. ✅ Token automatically refreshes on 401 response
5. ✅ User can log out and state is cleared
6. ✅ Current user profile is accessible throughout app
7. ✅ All auth state changes trigger UI updates via Riverpod
8. ✅ Error states are properly handled and communicated

## Testing Requirements

1. **Unit Tests**
   - AuthService API calls
   - AuthRepository token storage/retrieval
   - AuthNotifier state transitions
   - Email validation
   - Token refresh logic

2. **Widget Tests**
   - Auth state listeners respond correctly
   - Loading states display properly
   - Error messages show correctly

3. **Integration Tests**
   - Full login flow
   - Token refresh flow
   - Logout flow
   - App restart with stored token

## Security Considerations

- ✅ Tokens stored using flutter_secure_storage (encrypted on-device)
- ✅ No tokens in plain text or SharedPreferences
- ✅ Automatic token refresh to minimize exposure
- ✅ Tokens cleared on logout
- ⚠️ HTTPS required for production API
- ⚠️ Token expiry handled gracefully

## Implementation Notes

- Uses `flutter_secure_storage: ^9.2.2` for secure token storage
- Integrates with existing DioClient from MVP-FL-005
- Token refresh uses callback pattern to avoid circular dependencies
- ProviderContainer enables accessing providers outside widget tree
- AuthState uses immutable data structures for reliability

## Commit Information

**Branch**: `feature/MVP-FL-010_login_registration_screens`  
**Commit**: `f3a8a94`  
**Files**:
- 5 auth models created
- AuthService implemented
- AuthRepository with secure storage
- AuthProvider with Riverpod StateNotifier
- AuthInterceptor updated for token refresh
- DioClient configured with callback
- main.dart initialization updated

**Status**: ✅ Completed
