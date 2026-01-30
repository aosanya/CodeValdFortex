import 'package:dio/dio.dart';
import '../core/api/dio_client.dart';
import '../models/agency/agency_introduction.dart';
import '../models/agency/introduction_section.dart';

/// Repository for agency introduction data management
class IntroductionRepository {
  final Dio _dio = DioClient.dio;

  /// Get introduction for a specific agency
  Future<AgencyIntroduction> getIntroduction(String agencyId) async {
    try {
      final response = await _dio.get('/agencies/$agencyId/introduction');
      return AgencyIntroduction.fromJson(
          response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Create a new introduction for an agency
  Future<AgencyIntroduction> createIntroduction(
      AgencyIntroduction introduction) async {
    try {
      final response = await _dio.post(
        '/agencies/${introduction.agencyId}/introduction',
        data: introduction.toJson(),
      );
      return AgencyIntroduction.fromJson(
          response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Update an existing introduction
  Future<AgencyIntroduction> updateIntroduction(
      AgencyIntroduction introduction) async {
    try {
      final response = await _dio.put(
        '/agencies/${introduction.agencyId}/introduction',
        data: introduction.toJson(),
      );
      return AgencyIntroduction.fromJson(
          response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Delete an introduction
  Future<void> deleteIntroduction(String agencyId) async {
    try {
      await _dio.delete('/agencies/$agencyId/introduction');
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Add a new section to an introduction
  Future<IntroductionSection> addSection(
    String agencyId,
    IntroductionSection section,
  ) async {
    try {
      final response = await _dio.post(
        '/agencies/$agencyId/introduction/sections',
        data: section.toJson(),
      );
      return IntroductionSection.fromJson(
          response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Update a specific section
  Future<IntroductionSection> updateSection(
    String agencyId,
    String sectionId,
    IntroductionSection section,
  ) async {
    try {
      final response = await _dio.put(
        '/agencies/$agencyId/introduction/sections/$sectionId',
        data: section.toJson(),
      );
      return IntroductionSection.fromJson(
          response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Delete a section
  Future<void> deleteSection(String agencyId, String sectionId) async {
    try {
      await _dio.delete(
        '/agencies/$agencyId/introduction/sections/$sectionId',
      );
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Reorder sections
  Future<void> reorderSections(
    String agencyId,
    List<String> sectionIds,
  ) async {
    try {
      await _dio.put(
        '/agencies/$agencyId/introduction/sections/reorder',
        data: {'section_ids': sectionIds},
      );
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Get a specific section by ID
  Future<IntroductionSection> getSection(
    String agencyId,
    String sectionId,
  ) async {
    try {
      final response = await _dio.get(
        '/agencies/$agencyId/introduction/sections/$sectionId',
      );
      return IntroductionSection.fromJson(
          response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Apply a template to create an introduction
  Future<AgencyIntroduction> applyTemplate(
    String agencyId,
    String template,
  ) async {
    try {
      final response = await _dio.post(
        '/agencies/$agencyId/introduction/apply-template',
        data: {'template': template},
      );
      return AgencyIntroduction.fromJson(
          response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Get list of available templates
  Future<List<String>> getTemplates(String agencyId) async {
    try {
      final response = await _dio.get(
        '/agencies/$agencyId/introduction/templates',
      );
      final templates =
          response.data['templates'] as List<dynamic>? ?? <dynamic>[];
      return templates.map((t) => t.toString()).toList();
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Generate introduction using AI
  Future<Map<String, dynamic>> generateIntroduction({
    required String agencyId,
    required List<String> keywords,
    String? template,
    Map<String, dynamic>? agencyContext,
  }) async {
    try {
      final response = await _dio.post(
        '/introduction/ai/generate',
        data: {
          'agency_id': agencyId,
          'keywords': keywords,
          if (template != null) 'template': template,
          if (agencyContext != null) 'agency_context': agencyContext,
        },
      );
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Refine a section using AI
  Future<Map<String, dynamic>> refineSection({
    required String agencyId,
    required String sectionId,
    required IntroductionSection section,
    required String refinementText,
    Map<String, dynamic>? agencyContext,
  }) async {
    try {
      final response = await _dio.post(
        '/introduction/ai/refine-section',
        data: {
          'agency_id': agencyId,
          'section_id': sectionId,
          'section': section.toJson(),
          'refinement_text': refinementText,
          if (agencyContext != null) 'agency_context': agencyContext,
        },
      );
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Handle Dio errors and convert to user-friendly messages
  Exception _handleError(DioException e) {
    if (e.response != null) {
      final statusCode = e.response!.statusCode;
      final data = e.response!.data;

      String message = 'An error occurred';
      if (data is Map<String, dynamic> && data.containsKey('error')) {
        message = data['error'].toString();
      }

      switch (statusCode) {
        case 400:
          return Exception('Bad request: $message');
        case 401:
          return Exception('Unauthorized: Please log in again');
        case 403:
          return Exception('Forbidden: $message');
        case 404:
          return Exception('Not found: $message');
        case 500:
          return Exception('Server error: $message');
        default:
          return Exception('Error ($statusCode): $message');
      }
    } else if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.receiveTimeout) {
      return Exception('Connection timeout. Please check your internet.');
    } else if (e.type == DioExceptionType.connectionError) {
      return Exception('Connection error. Please check your internet.');
    } else {
      return Exception('Network error: ${e.message}');
    }
  }
}
