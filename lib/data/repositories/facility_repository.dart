import '../../core/network/api_client.dart';
import '../../core/network/api_response.dart';
import '../../core/config/api_config.dart';
import '../models/facility_api_model.dart';

/// Facility Repository
/// 
/// Handles all facility-related data operations.
class FacilityRepository {
  final ApiClient _apiClient;
  final ApiConfig _config;

  FacilityRepository({
    ApiClient? apiClient,
    ApiConfig? config,
  })  : _apiClient = apiClient ?? ApiClient(),
        _config = config ?? ApiConfig();

  /// Get all facilities with pagination
  /// 
  /// Supported query parameters:
  /// - page: Page number (default: 1)
  /// - limit: Items per page (default: 20)
  Future<ApiResponse<PaginatedResponse<FacilityApiModel>>> getAllFacilities({
    int page = 1,
    int limit = 20,
  }) async {
    final queryParams = <String, String>{
      'page': page.toString(),
      'limit': limit.toString(),
    };

    return await _apiClient.get<PaginatedResponse<FacilityApiModel>>(
      _config.facilitiesEndpoint,
      queryParameters: queryParams,
      fromJson: (data) {
        // Handle both paginated and plain list responses
        if (data is List) {
          // Plain list response - wrap it in pagination format
          return PaginatedResponse<FacilityApiModel>(
            items: (data as List).map((item) => FacilityApiModel.fromJson(item as Map<String, dynamic>)).toList(),
            page: page,
            limit: limit,
            total: data.length,
            totalPages: 1,
          );
        } else if (data is Map<String, dynamic>) {
          // Standard paginated response
          return PaginatedResponse.fromJson(
            data,
            (item) => FacilityApiModel.fromJson(item),
          );
        } else {
          throw Exception('Unexpected data type: ${data.runtimeType}');
        }
      },
    );
  }

  /// Get facility by ID
  Future<ApiResponse<FacilityApiModel>> getFacilityById(String facilityId) async {
    return await _apiClient.get<FacilityApiModel>(
      '${_config.facilitiesEndpoint}/$facilityId',
      fromJson: (data) => FacilityApiModel.fromJson(data as Map<String, dynamic>),
    );
  }

  /// Create new facility
  Future<ApiResponse<FacilityApiModel>> createFacility(
    CreateFacilityRequest request,
  ) async {
    return await _apiClient.post<FacilityApiModel>(
      _config.facilitiesEndpoint,
      body: request.toJson(),
      fromJson: (data) => FacilityApiModel.fromJson(data as Map<String, dynamic>),
    );
  }

  /// Update facility
  Future<ApiResponse<FacilityApiModel>> updateFacility(
    String facilityId,
    UpdateFacilityRequest request,
  ) async {
    return await _apiClient.put<FacilityApiModel>(
      '${_config.facilitiesEndpoint}/$facilityId',
      body: request.toJson(),
      fromJson: (data) => FacilityApiModel.fromJson(data as Map<String, dynamic>),
    );
  }

  /// Partial update facility (PATCH)
  Future<ApiResponse<FacilityApiModel>> patchFacility(
    String facilityId,
    UpdateFacilityRequest request,
  ) async {
    return await _apiClient.patch<FacilityApiModel>(
      '${_config.facilitiesEndpoint}/$facilityId',
      body: request.toJson(),
      fromJson: (data) => FacilityApiModel.fromJson(data as Map<String, dynamic>),
    );
  }

  /// Delete facility
  Future<ApiResponse<void>> deleteFacility(String facilityId) async {
    return await _apiClient.delete<void>(
      '${_config.facilitiesEndpoint}/$facilityId',
    );
  }
}
