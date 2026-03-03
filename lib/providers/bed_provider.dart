import 'package:flutter/material.dart';
import 'package:bed_app/Models/bed_model.dart';
import 'package:bed_app/data/services/bed_service.dart';
import 'package:bed_app/data/services/ward_service.dart';
import 'package:bed_app/data/services/facility_service.dart';
import 'package:bed_app/data/models/bed_api_model.dart';
import 'package:bed_app/data/models/ward_api_model.dart';
import 'package:bed_app/data/models/facility_api_model.dart';

class BedProvider extends ChangeNotifier {
  final BedService _bedService = BedService();
  final WardService _wardService = WardService();
  final FacilityService _facilityService = FacilityService();

  List<BedModel> _beds = [];
  List<WardApiModel> _wards = [];
  List<FacilityApiModel> _facilities = [];
  String _selectedFacility = '';
  String _selectedWard = '';
  List<Map<String, dynamic>> _recentAllocations = [];
  
  bool _isLoading = false;
  String? _error;

  BedProvider() {
    loadData();
  }

  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadData() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await Future.wait([
        _loadBeds(),
        _loadWards(),
        _loadFacilities(),
      ]);
    } catch (e) {
      _error = 'Failed to load data: ${e.toString()}';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _loadBeds() async {
    try {
      final response = await _bedService.getAllBeds();
      _beds = response.items.map((apiBed) => _convertApiBedToModel(apiBed)).toList();
    } catch (e) {
      throw Exception('Failed to load beds: ${e.toString()}');
    }
  }

  Future<void> _loadWards() async {
    try {
      final response = await _wardService.getAllWards();
      _wards = response.items;
      if (_wards.isNotEmpty && _selectedWard.isEmpty) {
        _selectedWard = _wards.first.id;
      }
    } catch (e) {
      throw Exception('Failed to load wards: ${e.toString()}');
    }
  }

  Future<void> _loadFacilities() async {
    try {
      final response = await _facilityService.getAllFacilities();
      _facilities = response.items;
      if (_facilities.isNotEmpty && _selectedFacility.isEmpty) {
        _selectedFacility = _facilities.first.id;
      }
    } catch (e) {
      throw Exception('Failed to load facilities: ${e.toString()}');
    }
  }

  BedModel _convertApiBedToModel(BedApiModel apiBed) {
    return BedModel(
      id: apiBed.id,
      number: apiBed.bedNumber,
      ward: apiBed.wardId,
      status: apiBed.status,
      facility: apiBed.facilityName,
      facilityId: apiBed.facilityId,
      floor: apiBed.floor,
      assignedPatient: apiBed.currentPatientName,
      notes: apiBed.notes,
      lastUpdated: apiBed.updatedAt,
      pricePerNight: apiBed.pricePerNight ?? 0.0,
      amenities: apiBed.amenities,
    );
  }

  List<BedModel> get beds => _beds;
  List<WardApiModel> get wards => _wards;
  List<FacilityApiModel> get facilities => _facilities;
  String get selectedFacility => _selectedFacility;
  String get selectedWard => _selectedWard;
  List<Map<String, dynamic>> get recentAllocations => _recentAllocations;

  List<BedModel> get filteredBeds {
    return _beds
        .where((bed) =>
            (_selectedFacility.isEmpty || bed.facilityId == _selectedFacility) &&
            (_selectedWard.isEmpty || bed.ward == _selectedWard))
        .toList();
  }

  Future<Map<String, int>> getBedStats(String? facilityId) async {
    try {
      final stats = await _bedService.getBedStats();
      return {
        'total': stats.totalBeds,
        'available': stats.availableBeds,
        'occupied': stats.occupiedBeds,
        'reserved': stats.reservedBeds,
        'cleaning': stats.cleaningBeds,
        'blocked': stats.blockedBeds,
      };
    } catch (e) {
      // Fallback to local calculation if API fails
      final facilityBeds = facilityId != null
          ? _beds.where((bed) => bed.facilityId == facilityId).toList()
          : _beds;
      return {
        'total': facilityBeds.length,
        'available': facilityBeds.where((b) => b.status == 'Available').length,
        'occupied': facilityBeds.where((b) => b.status == 'Occupied').length,
        'reserved': facilityBeds.where((b) => b.status == 'Reserved').length,
        'cleaning': facilityBeds.where((b) => b.status == 'Cleaning').length,
        'blocked': facilityBeds.where((b) => b.status == 'Blocked').length,
      };
    }
  }

  void selectFacility(String facilityId) {
    _selectedFacility = facilityId;
    notifyListeners();
  }

  void selectWard(String ward) {
    _selectedWard = ward;
    notifyListeners();
  }

  Future<void> updateBedStatus(String bedId, String newStatus) async {
    try {
      // Call API to update bed status
      await _bedService.updateBedStatus(
        bedId,
        newStatus,
      );

      // Refresh beds from API
      await _loadBeds();
      notifyListeners();
    } catch (e) {
      _error = 'Failed to update bed status: ${e.toString()}';
      notifyListeners();
      rethrow;
    }
  }

  Future<void> allocateBed(String bedId, String patientName, String ward) async {
    try {
      // Update bed with patient information
      await _bedService.updateBed(
        bedId,
        UpdateBedRequest(
          status: 'Occupied',
          currentPatientName: patientName,
          notes: 'Allocated to $patientName',
        ),
      );

      // Add to recent allocations
      _recentAllocations.insert(0, {
        'bedId': bedId,
        'patient': patientName,
        'time': DateTime.now(),
        'ward': ward,
      });
      if (_recentAllocations.length > 10) {
        _recentAllocations.removeLast();
      }

      // Refresh beds from API
      await _loadBeds();
      notifyListeners();
    } catch (e) {
      _error = 'Failed to allocate bed: ${e.toString()}';
      notifyListeners();
      rethrow;
    }
  }

  Future<void> releaseBed(String bedId) async {
    try {
      await _bedService.updateBed(
        bedId,
        UpdateBedRequest(
          status: 'Cleaning',
          currentPatientName: null,
          notes: 'Bed released - cleaning in progress',
        ),
      );

      // Refresh beds from API
      await _loadBeds();
      notifyListeners();
    } catch (e) {
      _error = 'Failed to release bed: ${e.toString()}';
      notifyListeners();
      rethrow;
    }
  }

  Future<void> transferBed(String fromBedId, String toBedId, String patientName) async {
    try {
      // Release the old bed
      await _bedService.updateBed(
        fromBedId,
        UpdateBedRequest(
          status: 'Cleaning',
          currentPatientName: null,
          notes: 'Patient transferred',
        ),
      );

      // Allocate the new bed
      await _bedService.updateBed(
        toBedId,
        UpdateBedRequest(
          status: 'Occupied',
          currentPatientName: patientName,
          notes: 'Patient transferred from bed $fromBedId',
        ),
      );

      // Refresh beds from API
      await _loadBeds();
      notifyListeners();
    } catch (e) {
      _error = 'Failed to transfer bed: ${e.toString()}';
      notifyListeners();
      rethrow;
    }
  }

  Future<void> startCleaning(String bedId) async {
    await updateBedStatus(bedId, 'Cleaning');
  }

  Future<void> completeCleaning(String bedId) async {
    await updateBedStatus(bedId, 'Available');
  }

  Future<void> loadMockData() async {
    await loadData();
  }

  Future<Map<String, dynamic>> getAnalytics() async {
    try {
      final stats = await _bedService.getBedStats();
      final totalBeds = stats.totalBeds;
      final occupied = stats.occupiedBeds;
      final occupancyRate = totalBeds > 0 ? (occupied / totalBeds * 100).round() : 0;

      return {
        'totalBeds': totalBeds,
        'available': stats.availableBeds,
        'occupied': occupied,
        'reserved': stats.reservedBeds,
        'cleaning': stats.cleaningBeds,
        'blocked': stats.blockedBeds,
        'occupancyRate': occupancyRate,
      };
    } catch (e) {
      // Fallback to local calculation if API fails
      final facilityBeds = _selectedFacility.isNotEmpty
          ? _beds.where((bed) => bed.facilityId == _selectedFacility).toList()
          : _beds;
      final totalBeds = facilityBeds.length;
      final available = facilityBeds.where((b) => b.status == 'Available').length;
      final occupied = facilityBeds.where((b) => b.status == 'Occupied').length;
      final reserved = facilityBeds.where((b) => b.status == 'Reserved').length;
      final cleaning = facilityBeds.where((b) => b.status == 'Cleaning').length;
      final blocked = facilityBeds.where((b) => b.status == 'Blocked').length;
      final occupancyRate = totalBeds > 0 ? (occupied / totalBeds * 100).round() : 0;

      return {
        'totalBeds': totalBeds,
        'available': available,
        'occupied': occupied,
        'reserved': reserved,
        'cleaning': cleaning,
        'blocked': blocked,
        'occupancyRate': occupancyRate,
      };
    }
  }

  BedModel? getBedById(String id) {
    try {
      return _beds.firstWhere((bed) => bed.id == id);
    } catch (e) {
      return null;
    }
  }

  List<BedModel> getBedsByFacility(String facilityId) {
    return _beds.where((bed) => bed.facilityId == facilityId).toList();
  }

  void setFacility(String facility) {
    _selectedFacility = facility;
    notifyListeners();
  }

  void addRecentAllocation(String bedNumber, String patientName, String ward) {
    _recentAllocations.insert(0, {
      'bedNumber': bedNumber,
      'patientName': patientName,
      'timestamp': DateTime.now(),
      'ward': ward,
    });
    
    if (_recentAllocations.length > 5) {
      _recentAllocations.removeLast();
    }
    
    notifyListeners();
  }
}