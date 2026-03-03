import '../repositories/facility_repository.dart';
import '../models/facility_api_model.dart';
import '../../core/network/api_response.dart';
import '../../core/network/api_exceptions.dart';

/// Facility Service
/// 
/// Business logic layer for facility operations.
class FacilityService {
  final FacilityRepository _repository;

  FacilityService({FacilityRepository? repository})
      : _repository = repository ?? FacilityRepository();

  /// Get all facilities with pagination
  Future<PaginatedResponse<FacilityApiModel>> getAllFacilities({
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final response = await _repository.getAllFacilities(
        page: page,
        limit: limit,
      );

      if (!response.success || response.data == null) {
        throw ApiException(
          message: response.error?.message ?? 'Failed to fetch facilities',
          code: response.error?.code,
        );
      }

      return response.data!;
    } catch (e) {
      if (e is ApiException) rethrow;
      throw UnknownException(
        message: 'Failed to get facilities',
        details: e.toString(),
      );
    }
  }

  /// Get facility by ID
  Future<FacilityApiModel> getFacilityById(String facilityId) async {
    try {
      final response = await _repository.getFacilityById(facilityId);

      if (!response.success || response.data == null) {
        throw ApiException(
          message: response.error?.message ?? 'Failed to fetch facility',
          code: response.error?.code,
        );
      }

      return response.data!;
    } catch (e) {
      if (e is ApiException) rethrow;
      throw UnknownException(
        message: 'Failed to get facility',
        details: e.toString(),
      );
    }
  }

  /// Create new facility
  Future<FacilityApiModel> createFacility(CreateFacilityRequest request) async {
    try {
      // Validate facility data
      if (request.name.trim().isEmpty) {
        throw ValidationException(
          message: 'Invalid facility data',
          fieldErrors: {
            'name': ['Facility name is required']
          },
        );
      }

      if (request.address.trim().isEmpty) {
        throw ValidationException(
          message: 'Invalid facility data',
          fieldErrors: {
            'address': ['Facility address is required']
          },
        );
      }

      final response = await _repository.createFacility(request);

      if (!response.success || response.data == null) {
        throw ApiException(
          message: response.error?.message ?? 'Failed to create facility',
          code: response.error?.code,
        );
      }

      return response.data!;
    } catch (e) {
      if (e is ApiException) rethrow;
      throw UnknownException(
        message: 'Failed to create facility',
        details: e.toString(),
      );
    }
  }

  /// Update facility
  Future<FacilityApiModel> updateFacility(
    String facilityId,
    UpdateFacilityRequest request,
  ) async {
    try {
      final response = await _repository.updateFacility(facilityId, request);

      if (!response.success || response.data == null) {
        throw ApiException(
          message: response.error?.message ?? 'Failed to update facility',
          code: response.error?.code,
        );
      }

      return response.data!;
    } catch (e) {
      if (e is ApiException) rethrow;
      throw UnknownException(
        message: 'Failed to update facility',
        details: e.toString(),
      );
    }
  }

  /// Delete facility
  Future<void> deleteFacility(String facilityId) async {
    try {
      final response = await _repository.deleteFacility(facilityId);

      if (!response.success) {
        throw ApiException(
          message: response.error?.message ?? 'Failed to delete facility',
          code: response.error?.code,
        );
      }
    } catch (e) {
      if (e is ApiException) rethrow;
      throw UnknownException(
        message: 'Failed to delete facility',
        details: e.toString(),
      );
    }
  }

  /// Get facility occupancy rate
  Future<double> getFacilityOccupancyRate(String facilityId) async {
    try {
      final facility = await getFacilityById(facilityId);
      return facility.occupancyRate;
    } catch (e) {
      if (e is ApiException) rethrow;
      throw UnknownException(
        message: 'Failed to get facility occupancy rate',
        details: e.toString(),
      );
    }
  }

  /// Get all facilities (no pagination)
  Future<List<FacilityApiModel>> getAllFacilitiesList() async {
    try {
      final allFacilities = <FacilityApiModel>[];
      int currentPage = 1;
      bool hasMore = true;

      while (hasMore) {
        final response = await getAllFacilities(
          page: currentPage,
          limit: 100,
        );

        allFacilities.addAll(response.items);
        hasMore = response.hasNext;
        currentPage++;
      }

      return allFacilities;
    } catch (e) {
      if (e is ApiException) rethrow;
      throw UnknownException(
        message: 'Failed to get all facilities',
        details: e.toString(),
      );
    }
  }
}
