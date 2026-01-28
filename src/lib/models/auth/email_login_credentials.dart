/// Email login credentials DTO
class EmailLoginCredentials {
  final String email;
  final String password;

  const EmailLoginCredentials({required this.email, required this.password});

  /// Convert to JSON for API submission
  Map<String, dynamic> toJson() {
    return {'email': email, 'password': password};
  }
}
