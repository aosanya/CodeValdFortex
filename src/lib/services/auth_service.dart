import 'package:dio/dio.dart';
import '../core/api/dio_client.dart';
import '../models/auth/auth_response.dart';
import '../models/auth/auth_user.dart';
import '../models/auth/email_login_credentials.dart';

/// Service for authentication API calls
class AuthService {
  final Dio _dio = DioClient.dio;

  /// Login with email and password
  Future<AuthResponse> loginWithEmail(EmailLoginCredentials credentials) async {
    try {
      final response = await _dio.post(
        '/auth/login',
        data: credentials.toJson(),
      );

      return AuthResponse.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Refresh authentication token
  Future<AuthResponse> refreshToken(String refreshToken) async {
    try {
      final response = await _dio.post(
        '/auth/refresh',
        data: {'refresh_token': refreshToken},
      );

      return AuthResponse.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Logout current user
  Future<void> logout() async {
    try {
      await _dio.post('/auth/logout');
    } on DioException catch (e) {
      // Ignore logout errors, we'll clear local state anyway
      throw _handleError(e);
    }
  }

  /// Get current user info
  Future<AuthUser> getCurrentUser() async {
    try {
      final response = await _dio.get('/auth/me');
      return AuthUser.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Handle Dio errors
  String _handleError(DioException e) {
    if (e.response != null) {
      final data = e.response!.data;
      if (data is Map<String, dynamic> && data.containsKey('message')) {
        return data['message'] as String;
      }
      return 'Server error: ${e.response!.statusCode}';
    } else if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.receiveTimeout) {
      return 'Connection timeout. Please try again.';
    } else if (e.type == DioExceptionType.connectionError) {
      return 'No internet connection.';
    }
    return 'An error occurred. Please try again.';
  }
}
