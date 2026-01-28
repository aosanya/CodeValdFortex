import 'auth_user.dart';

/// Response from authentication API endpoints
class AuthResponse {
  final String token;
  final String refreshToken;
  final AuthUser user;
  final DateTime? expiresAt;

  const AuthResponse({
    required this.token,
    required this.refreshToken,
    required this.user,
    this.expiresAt,
  });

  /// Create from JSON
  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    return AuthResponse(
      token: json['token'] as String,
      refreshToken: json['refresh_token'] as String,
      user: AuthUser.fromJson(json['user'] as Map<String, dynamic>),
      expiresAt: json['expires_at'] != null
          ? DateTime.parse(json['expires_at'] as String)
          : null,
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'token': token,
      'refresh_token': refreshToken,
      'user': user.toJson(),
      'expires_at': expiresAt?.toIso8601String(),
    };
  }
}
