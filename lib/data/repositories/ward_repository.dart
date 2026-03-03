import '../../core/network/api_client.dart';
import '../../core/network/api_response.dart';
import '../../core/config/api_config.dart';
import '../models/ward_api_model.dart';

/// Ward Repository
/// 
/// Handles all ward-related data operations.
class WardRepository {
  final ApiClient _apiClient;
  final ApiConfig _config;

  WardRepository({
    ApiClient? apiClient,
    ApiConfig? config,
  })  : _apiClient = apiClient ?? ApiClient(),
        _config = config ?? ApiConfig();

  /// Get all wards with optional filtering and pagination
  /// 
  /// Supported query parameters:
  /// - page: Page number (default: 1)
  /// - limit: Items per page (default: 20)
  /// - facilityId: Filter by facility ID
  Future<ApiResponse<PaginatedResponse<WardApiModel>>> getAllWards({
    String? facilityId,
    int page = 1,
    int limit = 20,
  }) async {
    final queryParams = <String, String>{
      'page': page.toString(),
      'limit': limit.toString(),
    };

    if (facilityId != null) queryParams['facilityId'] = facilityId;

    return await _apiClient.get<PaginatedResponse<WardApiModel>>(
      _config.wardsEndpoint,
      queryParameters: queryParams,
      fromJson: (data) {
        // Handle both paginated and plain list responses
        if (data is List) {
          // Plain list response - wrap it in pagination format
          return PaginatedResponse<WardApiModel>(
            items: (data as List).map((item) => WardApiModel.fromJson(item as Map<String, dynamic>)).toList(),
            page: page,
            limit: limit,
            total: data.length,
            totalPages: 1,
          );
        } else if (data is Map<String, dynamic>) {
          // Standard paginated response
          return PaginatedResponse.fromJson(
            data,
            (item) => WardApiModel.fromJson(item),
          );
        } else {
          throw Exception('Unexpected data type: ${data.runtimeType}');
        }
      },
    );
  }

  /// Get ward by ID
  Future<ApiResponse<WardApiModel>> getWardById(String wardId) async {
    return await _apiClient.get<WardApiModel>(
      '${_config.wardsEndpoint}/$wardId',
      fromJson: (data) => WardApiModel.fromJson(data as Map<String, dynamic>),
    );
  }

  /// Create new ward
  Future<ApiResponse<WardApiModel>> createWard(CreateWardRequest request) async {
    return await _apiClient.post<WardApiModel>(
      _config.wardsEndpoint,
      body: request.toJson(),
      fromJson: (data) => WardApiModel.fromJson(data as Map<String, dynamic>),
    );
  }

  /// Update ward
  Future<ApiResponse<WardApiModel>> updateWard(
    String wardId,
    UpdateWardRequest request,
  ) async {
    return await _apiClient.put<WardApiModel>(
      '${_config.wardsEndpoint}/$wardId',
      body: request.toJson(),
      fromJson: (data) => WardApiModel.fromJson(data as Map<String, dynamic>),
    );
  }

  /// Partial update ward (PATCH)
  Future<ApiResponse<WardApiModel>> patchWard(
    String wardId,
    UpdateWardRequest request,
  ) async {
    return await _apiClient.patch<WardApiModel>(
      '${_config.wardsEndpoint}/$wardId',
      body: request.toJson(),
      fromJson: (data) => WardApiModel.fromJson(data as Map<String, dynamic>),
    );
  }

  /// Delete ward
  Future<ApiResponse<void>> deleteWard(String wardId) async {
    return await _apiClient.delete<void>(
      '${_config.wardsEndpoint}/$wardId',
    );
  }

  /// Get wards by facility
  Future<ApiResponse<PaginatedResponse<WardApiModel>>> getWardsByFacility(
    String facilityId, {
    int page = 1,
    int limit = 50,
  }) async {
    return await getAllWards(
      facilityId: facilityId,
      page: page,
      limit: limit,
    );
  }
}
