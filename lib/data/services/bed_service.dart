import '../repositories/bed_repository.dart';
import '../models/bed_api_model.dart';
import '../models/bed_stats_api_model.dart';
import '../../core/network/api_response.dart';
import '../../core/network/api_exceptions.dart';

/// Bed Service
/// 
/// Business logic layer for bed operations.
/// Provides high-level methods with error handling and business rules.
class BedService {
  final BedRepository _repository;

  BedService({BedRepository? repository})
      : _repository = repository ?? BedRepository();

  /// Get all beds with filtering and pagination
  Future<PaginatedResponse<BedApiModel>> getAllBeds({
    String? wardId,
    String? facilityId,
    String? status,
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final response = await _repository.getAllBeds(
        wardId: wardId,
        facilityId: facilityId,
        status: status,
        page: page,
        limit: limit,
      );

      if (!response.success || response.data == null) {
        throw ApiException(
          message: response.error?.message ?? 'Failed to fetch beds',
          code: response.error?.code,
        );
      }

      return response.data!;
    } catch (e) {
      if (e is ApiException) rethrow;
      throw UnknownException(
        message: 'Failed to get beds',
        details: e.toString(),
      );
    }
  }

  /// Get bed by ID
  Future<BedApiModel> getBedById(String bedId) async {
    try {
      final response = await _repository.getBedById(bedId);

      if (!response.success || response.data == null) {
        throw ApiException(
          message: response.error?.message ?? 'Failed to fetch bed',
          code: response.error?.code,
        );
      }

      return response.data!;
    } catch (e) {
      if (e is ApiException) rethrow;
      throw UnknownException(
        message: 'Failed to get bed',
        details: e.toString(),
      );
    }
  }

  /// Create new bed
  Future<BedApiModel> createBed(CreateBedRequest request) async {
    try {
      final response = await _repository.createBed(request);

      if (!response.success || response.data == null) {
        throw ApiException(
          message: response.error?.message ?? 'Failed to create bed',
          code: response.error?.code,
        );
      }

      return response.data!;
    } catch (e) {
      if (e is ApiException) rethrow;
      throw UnknownException(
        message: 'Failed to create bed',
        details: e.toString(),
      );
    }
  }

  /// Update bed
  Future<BedApiModel> updateBed(String bedId, UpdateBedRequest request) async {
    try {
      final response = await _repository.updateBed(bedId, request);

      if (!response.success || response.data == null) {
        throw ApiException(
          message: response.error?.message ?? 'Failed to update bed',
          code: response.error?.code,
        );
      }

      return response.data!;
    } catch (e) {
      if (e is ApiException) rethrow;
      throw UnknownException(
        message: 'Failed to update bed',
        details: e.toString(),
      );
    }
  }

  /// Delete bed
  Future<void> deleteBed(String bedId) async {
    try {
      final response = await _repository.deleteBed(bedId);

      if (!response.success) {
        throw ApiException(
          message: response.error?.message ?? 'Failed to delete bed',
          code: response.error?.code,
        );
      }
    } catch (e) {
      if (e is ApiException) rethrow;
      throw UnknownException(
        message: 'Failed to delete bed',
        details: e.toString(),
      );
    }
  }

  /// Update bed status with validation
  Future<BedApiModel> updateBedStatus(String bedId, String status) async {
    // Validate status
    final validStatuses = ['Available', 'Occupied', 'Reserved', 'Cleaning', 'Blocked'];
    if (!validStatuses.contains(status)) {
      throw ValidationException(
        message: 'Invalid bed status',
        fieldErrors: {
          'status': ['Status must be one of: ${validStatuses.join(', ')}']
        },
      );
    }

    try {
      final response = await _repository.updateBedStatus(bedId, status);

      if (!response.success || response.data == null) {
        throw ApiException(
          message: response.error?.message ?? 'Failed to update bed status',
          code: response.error?.code,
        );
      }

      return response.data!;
    } catch (e) {
      if (e is ApiException) rethrow;
      throw UnknownException(
        message: 'Failed to update bed status',
        details: e.toString(),
      );
    }
  }

  /// Get bed statistics
  Future<BedStatsApiModel> getBedStats({
    String? facilityId,
    String? wardId,
  }) async {
    try {
      final response = await _repository.getBedStats(
        facilityId: facilityId,
        wardId: wardId,
      );

      if (!response.success || response.data == null) {
        throw ApiException(
          message: response.error?.message ?? 'Failed to fetch bed statistics',
          code: response.error?.code,
        );
      }

      return response.data!;
    } catch (e) {
      if (e is ApiException) rethrow;
      throw UnknownException(
        message: 'Failed to get bed statistics',
        details: e.toString(),
      );
    }
  }

  /// Get available beds
  Future<PaginatedResponse<BedApiModel>> getAvailableBeds({
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
  Future<PaginatedResponse<BedApiModel>> getOccupiedBeds({
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
