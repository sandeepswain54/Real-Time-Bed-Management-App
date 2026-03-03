import '../../core/network/api_client.dart';
import '../../core/network/api_response.dart';
import '../../core/config/api_config.dart';
import '../models/bed_api_model.dart';
import '../models/bed_stats_api_model.dart';

/// Bed Repository
/// 
/// Handles all bed-related data operations.
/// Provides abstraction over network layer for future caching implementation.
class BedRepository {
  final ApiClient _apiClient;
  final ApiConfig _config;

  BedRepository({
    ApiClient? apiClient,
    ApiConfig? config,
  })  : _apiClient = apiClient ?? ApiClient(),
        _config = config ?? ApiConfig();

  /// Get all beds with optional filtering and pagination
  /// 
  /// Supported query parameters:
  /// - page: Page number (default: 1)
  /// - limit: Items per page (default: 20)
  /// - wardId: Filter by ward ID
  /// - facilityId: Filter by facility ID
  /// - status: Filter by status
  Future<ApiResponse<PaginatedResponse<BedApiModel>>> getAllBeds({
    String? wardId,
    String? facilityId,
    String? status,
    int page = 1,
    int limit = 20,
  }) async {
    final queryParams = <String, String>{
      'page': page.toString(),
      'limit': limit.toString(),
    };

    if (wardId != null) queryParams['wardId'] = wardId;
    if (facilityId != null) queryParams['facilityId'] = facilityId;
    if (status != null) queryParams['status'] = status;

    return await _apiClient.get<PaginatedResponse<BedApiModel>>(
      _config.bedsEndpoint,
      queryParameters: queryParams,
      fromJson: (data) {
        // Handle both paginated and plain list responses
        if (data is List) {
          // Plain list response - wrap it in pagination format
          return PaginatedResponse<BedApiModel>(
            items: (data as List).map((item) => BedApiModel.fromJson(item as Map<String, dynamic>)).toList(),
            page: page,
            limit: limit,
            total: data.length,
            totalPages: 1,
          );
        } else if (data is Map<String, dynamic>) {
          // Standard paginated response
          return PaginatedResponse.fromJson(
            data,
            (item) => BedApiModel.fromJson(item),
          );
        } else {
          throw Exception('Unexpected data type: ${data.runtimeType}');
        }
      },
    );
  }

  /// Get bed by ID
  Future<ApiResponse<BedApiModel>> getBedById(String bedId) async {
    return await _apiClient.get<BedApiModel>(
      '${_config.bedsEndpoint}/$bedId',
      fromJson: (data) => BedApiModel.fromJson(data as Map<String, dynamic>),
    );
  }

  /// Create new bed
  Future<ApiResponse<BedApiModel>> createBed(CreateBedRequest request) async {
    return await _apiClient.post<BedApiModel>(
      _config.bedsEndpoint,
      body: request.toJson(),
      fromJson: (data) => BedApiModel.fromJson(data as Map<String, dynamic>),
    );
  }

  /// Update bed
  Future<ApiResponse<BedApiModel>> updateBed(
    String bedId,
    UpdateBedRequest request,
  ) async {
    return await _apiClient.put<BedApiModel>(
      '${_config.bedsEndpoint}/$bedId',
      body: request.toJson(),
      fromJson: (data) => BedApiModel.fromJson(data as Map<String, dynamic>),
    );
  }

  /// Partial update bed (PATCH)
  Future<ApiResponse<BedApiModel>> patchBed(
    String bedId,
    UpdateBedRequest request,
  ) async {
    return await _apiClient.patch<BedApiModel>(
      '${_config.bedsEndpoint}/$bedId',
      body: request.toJson(),
      fromJson: (data) => BedApiModel.fromJson(data as Map<String, dynamic>),
    );
  }

  /// Delete bed
  Future<ApiResponse<void>> deleteBed(String bedId) async {
    return await _apiClient.delete<void>(
      '${_config.bedsEndpoint}/$bedId',
    );
  }

  /// Update bed status only
  Future<ApiResponse<BedApiModel>> updateBedStatus(
    String bedId,
    String status,
  ) async {
    return await patchBed(
      bedId,
      UpdateBedRequest(status: status),
    );
  }

  /// Get bed statistics
  Future<ApiResponse<BedStatsApiModel>> getBedStats({
    String? facilityId,
    String? wardId,
  }) async {
    final queryParams = <String, String>{};
    if (facilityId != null) queryParams['facilityId'] = facilityId;
    if (wardId != null) queryParams['wardId'] = wardId;

    return await _apiClient.get<BedStatsApiModel>(
      _config.bedStatsEndpoint,
      queryParameters: queryParams.isNotEmpty ? queryParams : null,
      fromJson: (data) => BedStatsApiModel.fromJson(data as Map<String, dynamic>),
    );
  }

  /// Get available beds count
  Future<ApiResponse<PaginatedResponse<BedApiModel>>> getAvailableBeds({
    String? wardId,
    String? facilityId,
    int page = 1,
    int limit = 20,
  }) async {
    return await getAllBeds(
      status: 'Available',
      wardId: wardId,
      facilityId: facilityId,
      page: page,
      limit: limit,
    );
  }

  /// Get occupied beds
  Future<ApiResponse<PaginatedResponse<BedApiModel>>> getOccupiedBeds({
    String? wardId,
    String? facilityId,
    int page = 1,
    int limit = 20,
  }) async {
    return await getAllBeds(
      status: 'Occupied',
      wardId: wardId,
      facilityId: facilityId,
      page: page,
      limit: limit,
    );
  }
}
