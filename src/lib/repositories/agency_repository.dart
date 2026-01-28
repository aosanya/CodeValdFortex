import 'package:dio/dio.dart';
import '../core/api/dio_client.dart';
import '../models/agency/agency_model.dart';
import '../models/agency/agency_status.dart';

/// Repository for agency data management
class AgencyRepository {
  final Dio _dio = DioClient.dio;

  /// Get list of agencies with optional filters
  Future<List<Agency>> getAgencies({
    String? search,
    AgencyStatus? status,
    String? sortBy,
    bool sortAscending = true,
    int? page,
    int? limit,
  }) async {
    try {
      final queryParameters = <String, dynamic>{};

      if (search != null && search.isNotEmpty) {
        queryParameters['search'] = search;
      }
      if (status != null) {
        queryParameters['status'] = status.name;
      }
      if (sortBy != null) {
        queryParameters['sort_by'] = sortBy;
        queryParameters['sort_order'] = sortAscending ? 'asc' : 'desc';
      }
      if (page != null) {
        queryParameters['page'] = page;
      }
      if (limit != null) {
        queryParameters['limit'] = limit;
      }

      final response = await _dio.get(
        '/api/v1/agencies',
        queryParameters: queryParameters,
      );

      final data = response.data as Map<String, dynamic>;
      final agencies = data['agencies'] as List<dynamic>;

      return agencies
          .map((json) => Agency.fromJson(json as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Get a single agency by ID
  Future<Agency> getAgencyById(String id) async {
    try {
      final response = await _dio.get('/api/v1/agencies/$id');

      return Agency.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Create a new agency
  Future<Agency> createAgency({
    required String name,
    required String description,
  }) async {
    try {
      final response = await _dio.post(
        '/api/v1/agencies',
        data: {'name': name, 'description': description},
      );

      return Agency.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Update an existing agency
  Future<Agency> updateAgency(String id, Map<String, dynamic> updates) async {
    try {
      final response = await _dio.put('/api/v1/agencies/$id', data: updates);

      return Agency.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Delete an agency
  Future<void> deleteAgency(String id) async {
    try {
      await _dio.delete('/api/v1/agencies/$id');
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Handle DioException and convert to appropriate error
  Exception _handleError(DioException error) {
    if (error.response != null) {
      final statusCode = error.response!.statusCode;
      final message =
          error.response!.data?['message'] as String? ??
          error.response!.statusMessage ??
          'Unknown error';

      switch (statusCode) {
        case 400:
          return Exception('Bad request: $message');
        case 401:
          return Exception('Unauthorized: $message');
        case 403:
          return Exception('Forbidden: $message');
        case 404:
          return Exception('Agency not found: $message');
        case 500:
          return Exception('Server error: $message');
        default:
          return Exception('Error ($statusCode): $message');
      }
    } else if (error.type == DioExceptionType.connectionTimeout ||
        error.type == DioExceptionType.receiveTimeout) {
      return Exception(
        'Connection timeout. Please check your internet connection.',
      );
    } else if (error.type == DioExceptionType.connectionError) {
      return Exception(
        'Connection error. Please check your internet connection.',
      );
    } else {
      return Exception('An unexpected error occurred: ${error.message}');
    }
  }
}
