import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../models/auth/auth_state.dart';
import '../models/auth/auth_user.dart';
import '../models/auth/email_login_credentials.dart';
import '../repositories/auth_repository.dart';
import '../services/auth_service.dart';

/// Provider for AuthService
final authServiceProvider = Provider<AuthService>((ref) {
  return AuthService();
});

/// Provider for AuthRepository
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository(
    authService: ref.read(authServiceProvider),
    storage: const FlutterSecureStorage(),
  );
});

/// Auth state notifier
class AuthNotifier extends StateNotifier<AuthState> {
  final AuthRepository _authRepository;

  AuthNotifier(this._authRepository) : super(AuthState.initial()) {
    // Check auth status on initialization
    checkAuthStatus();
  }

  /// Check if user is authenticated and load stored user
  Future<void> checkAuthStatus() async {
    try {
      final isAuth = await _authRepository.isAuthenticated();

      if (isAuth) {
        final user = await _authRepository.getStoredUser();
        if (user != null) {
          state = AuthState.authenticated(user);
        } else {
          state = AuthState.unauthenticated();
        }
      } else {
        state = AuthState.unauthenticated();
      }
    } catch (e) {
      state = AuthState.unauthenticated(
        errorMessage: 'Failed to check auth status',
      );
    }
  }

  /// Login with email and password
  Future<void> loginWithEmail(EmailLoginCredentials credentials) async {
    state = AuthState.loading();

    try {
      final user = await _authRepository.loginWithEmail(credentials);
      state = AuthState.authenticated(user);
    } catch (e) {
      state = AuthState.unauthenticated(errorMessage: e.toString());
    }
  }

  /// Refresh authentication token
  Future<void> refreshToken() async {
    try {
      final user = await _authRepository.refreshToken();
      state = AuthState.authenticated(user);
    } catch (e) {
      state = AuthState.unauthenticated(
        errorMessage: 'Session expired. Please login again.',
      );
    }
  }

  /// Logout current user
  Future<void> logout() async {
    try {
      await _authRepository.logout();
      state = AuthState.unauthenticated();
    } catch (e) {
      // Force unauthenticated state even if logout fails
      state = AuthState.unauthenticated();
    }
  }

  /// Update user data
  void updateUser(AuthUser user) {
    if (state.isAuthenticated) {
      state = AuthState.authenticated(user);
    }
  }
}

/// Provider for AuthNotifier
final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  final authRepository = ref.read(authRepositoryProvider);
  return AuthNotifier(authRepository);
});

/// Convenience provider for authentication status
final isAuthenticatedProvider = Provider<bool>((ref) {
  final authState = ref.watch(authProvider);
  return authState.isAuthenticated;
});

/// Convenience provider for current user
final currentUserProvider = Provider<AuthUser?>((ref) {
  final authState = ref.watch(authProvider);
  return authState.user;
});
