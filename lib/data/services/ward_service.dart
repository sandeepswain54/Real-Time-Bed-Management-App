import '../repositories/ward_repository.dart';
import '../models/ward_api_model.dart';
import '../../core/network/api_response.dart';
import '../../core/network/api_exceptions.dart';

/// Ward Service
/// 
/// Business logic layer for ward operations.
class WardService {
  final WardRepository _repository;

  WardService({WardRepository? repository})
      : _repository = repository ?? WardRepository();

  /// Get all wards with filtering and pagination
  Future<PaginatedResponse<WardApiModel>> getAllWards({
    String? facilityId,
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final response = await _repository.getAllWards(
        facilityId: facilityId,
        page: page,
        limit: limit,
      );

      if (!response.success || response.data == null) {
        throw ApiException(
          message: response.error?.message ?? 'Failed to fetch wards',
          code: response.error?.code,
        );
      }

      return response.data!;
    } catch (e) {
      if (e is ApiException) rethrow;
      throw UnknownException(
        message: 'Failed to get wards',
        details: e.toString(),
      );
    }
  }

  /// Get ward by ID
  Future<WardApiModel> getWardById(String wardId) async {
    try {
      final response = await _repository.getWardById(wardId);

      if (!response.success || response.data == null) {
        throw ApiException(
          message: response.error?.message ?? 'Failed to fetch ward',
          code: response.error?.code,
        );
      }

      return response.data!;
    } catch (e) {
      if (e is ApiException) rethrow;
      throw UnknownException(
        message: 'Failed to get ward',
        details: e.toString(),
      );
    }
  }

  /// Create new ward
  Future<WardApiModel> createWard(CreateWardRequest request) async {
    try {
      // Validate capacity
      if (request.capacity <= 0) {
        throw ValidationException(
          message: 'Invalid ward capacity',
          fieldErrors: {
            'capacity': ['Capacity must be greater than 0']
          },
        );
      }

      final response = await _repository.createWard(request);

      if (!response.success || response.data == null) {
        throw ApiException(
          message: response.error?.message ?? 'Failed to create ward',
          code: response.error?.code,
        );
      }

      return response.data!;
    } catch (e) {
      if (e is ApiException) rethrow;
      throw UnknownException(
        message: 'Failed to create ward',
        details: e.toString(),
      );
    }
  }

  /// Update ward
  Future<WardApiModel> updateWard(String wardId, UpdateWardRequest request) async {
    try {
      final response = await _repository.updateWard(wardId, request);

      if (!response.success || response.data == null) {
        throw ApiException(
          message: response.error?.message ?? 'Failed to update ward',
          code: response.error?.code,
        );
      }

      return response.data!;
    } catch (e) {
      if (e is ApiException) rethrow;
      throw UnknownException(
        message: 'Failed to update ward',
        details: e.toString(),
      );
    }
  }

  /// Delete ward
  Future<void> deleteWard(String wardId) async {
    try {
      final response = await _repository.deleteWard(wardId);

      if (!response.success) {
        throw ApiException(
          message: response.error?.message ?? 'Failed to delete ward',
          code: response.error?.code,
        );
      }
    } catch (e) {
      if (e is ApiException) rethrow;
      throw UnknownException(
        message: 'Failed to delete ward',
        details: e.toString(),
      );
    }
  }

  /// Get wards by facility
  Future<List<WardApiModel>> getWardsByFacility(String facilityId) async {
    try {
      final allWards = <WardApiModel>[];
      int currentPage = 1;
      bool hasMore = true;

      while (hasMore) {
        final response = await _repository.getWardsByFacility(
          facilityId,
          page: currentPage,
          limit: 50,
        );

        if (response.data != null) {
          allWards.addAll(response.data!.items);
          hasMore = response.data!.hasNext;
          currentPage++;
        } else {
          hasMore = false;
        }
      }

      return allWards;
    } catch (e) {
      if (e is ApiException) rethrow;
      throw UnknownException(
        message: 'Failed to get wards by facility',
        details: e.toString(),
      );
    }
  }

  /// Get ward occupancy rate
  Future<double> getWardOccupancyRate(String wardId) async {
    try {
      final ward = await getWardById(wardId);
      return ward.occupancyRate;
    } catch (e) {
      if (e is ApiException) rethrow;
      throw UnknownException(
        message: 'Failed to get ward occupancy rate',
        details: e.toString(),
      );
    }
  }
}
