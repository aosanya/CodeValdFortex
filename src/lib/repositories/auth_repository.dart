import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../models/auth/auth_user.dart';
import '../models/auth/email_login_credentials.dart';
import '../services/auth_service.dart';

/// Repository for authentication data management
class AuthRepository {
  final AuthService _authService;
  final FlutterSecureStorage _storage;

  // Storage keys
  static const String _authTokenKey = 'auth_token';
  static const String _refreshTokenKey = 'refresh_token';
  static const String _userKey = 'user';
  static const String _tokenExpiryKey = 'token_expiry';

  AuthRepository({
    required AuthService authService,
    FlutterSecureStorage? storage,
  }) : _authService = authService,
       _storage = storage ?? const FlutterSecureStorage();

  /// Login with email and password
  Future<AuthUser> loginWithEmail(EmailLoginCredentials credentials) async {
    final response = await _authService.loginWithEmail(credentials);

    // Store tokens and user
    await _storage.write(key: _authTokenKey, value: response.token);
    await _storage.write(key: _refreshTokenKey, value: response.refreshToken);
    await _storage.write(
      key: _userKey,
      value: jsonEncode(response.user.toJson()),
    );
    if (response.expiresAt != null) {
      await _storage.write(
        key: _tokenExpiryKey,
        value: response.expiresAt!.toIso8601String(),
      );
    }

    return response.user;
  }

  /// Refresh authentication token
  Future<AuthUser> refreshToken() async {
    final refreshToken = await _storage.read(key: _refreshTokenKey);
    if (refreshToken == null) {
      throw Exception('No refresh token available');
    }

    final response = await _authService.refreshToken(refreshToken);

    // Update stored tokens
    await _storage.write(key: _authTokenKey, value: response.token);
    await _storage.write(key: _refreshTokenKey, value: response.refreshToken);
    await _storage.write(
      key: _userKey,
      value: jsonEncode(response.user.toJson()),
    );
    if (response.expiresAt != null) {
      await _storage.write(
        key: _tokenExpiryKey,
        value: response.expiresAt!.toIso8601String(),
      );
    }

    return response.user;
  }

  /// Logout current user
  Future<void> logout() async {
    try {
      await _authService.logout();
    } catch (e) {
      // Continue with local cleanup even if API call fails
    }

    // Clear all stored auth data
    await _storage.delete(key: _authTokenKey);
    await _storage.delete(key: _refreshTokenKey);
    await _storage.delete(key: _userKey);
    await _storage.delete(key: _tokenExpiryKey);
  }

  /// Check if user is authenticated
  Future<bool> isAuthenticated() async {
    final token = await _storage.read(key: _authTokenKey);
    return token != null && token.isNotEmpty;
  }

  /// Get stored authentication token
  Future<String?> getAuthToken() async {
    return await _storage.read(key: _authTokenKey);
  }

  /// Get stored refresh token
  Future<String?> getRefreshToken() async {
    return await _storage.read(key: _refreshTokenKey);
  }

  /// Get stored user
  Future<AuthUser?> getStoredUser() async {
    final userJson = await _storage.read(key: _userKey);
    if (userJson == null) return null;

    try {
      final userData = jsonDecode(userJson) as Map<String, dynamic>;
      return AuthUser.fromJson(userData);
    } catch (e) {
      return null;
    }
  }
}
