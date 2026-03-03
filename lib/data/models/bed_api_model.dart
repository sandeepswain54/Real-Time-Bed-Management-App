/// Bed Model for API responses
/// 
/// Represents a hospital bed with all its properties.
class BedApiModel {
  final String id;
  final String bedNumber;
  final String status;
  final String wardId;
  final String wardName;
  final String facilityId;
  final String facilityName;
  final String floor;
  final String? currentPatientId;
  final String? currentPatientName;
  final DateTime? checkInTime;
  final DateTime? expectedCheckOut;
  final double? pricePerNight;
  final List<String> amenities;
  final String? notes;
  final DateTime createdAt;
  final DateTime updatedAt;

  BedApiModel({
    required this.id,
    required this.bedNumber,
    required this.status,
    required this.wardId,
    required this.wardName,
    required this.facilityId,
    required this.facilityName,
    required this.floor,
    this.currentPatientId,
    this.currentPatientName,
    this.checkInTime,
    this.expectedCheckOut,
    this.pricePerNight,
    this.amenities = const [],
    this.notes,
    required this.createdAt,
    required this.updatedAt,
  });

  factory BedApiModel.fromJson(Map<String, dynamic> json) {
    return BedApiModel(
      id: json['id'] as String? ?? '',
      bedNumber: json['bedNumber'] as String? ?? 'Unknown',
      status: json['status'] as String? ?? 'Available',
      wardId: json['wardId'] as String? ?? '',
      wardName: json['wardName'] as String? ?? 'Unknown',
      facilityId: json['facilityId'] as String? ?? '',
      facilityName: json['facilityName'] as String? ?? 'Unknown',
      floor: json['floor'] as String? ?? 'N/A',
      currentPatientId: json['currentPatientId'] as String?,
      currentPatientName: json['currentPatientName'] as String?,
      checkInTime: json['checkInTime'] != null 
          ? DateTime.parse(json['checkInTime'] as String)
          : null,
      expectedCheckOut: json['expectedCheckOut'] != null 
          ? DateTime.parse(json['expectedCheckOut'] as String)
          : null,
      pricePerNight: json['pricePerNight'] != null 
          ? (json['pricePerNight'] as num).toDouble()
          : null,
      amenities: json['amenities'] != null
          ? List<String>.from(json['amenities'] as List)
          : [],
      notes: json['notes'] as String?,
      createdAt: json['createdAt'] != null 
          ? DateTime.parse(json['createdAt'] as String)
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null 
          ? DateTime.parse(json['updatedAt'] as String)
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'bedNumber': bedNumber,
      'status': status,
      'wardId': wardId,
      'wardName': wardName,
      'facilityId': facilityId,
      'facilityName': facilityName,
      'floor': floor,
      'currentPatientId': currentPatientId,
      'currentPatientName': currentPatientName,
      'checkInTime': checkInTime?.toIso8601String(),
      'expectedCheckOut': expectedCheckOut?.toIso8601String(),
      'pricePerNight': pricePerNight,
      'amenities': amenities,
      'notes': notes,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  BedApiModel copyWith({
    String? id,
    String? bedNumber,
    String? status,
    String? wardId,
    String? wardName,
    String? facilityId,
    String? facilityName,
    String? floor,
    String? currentPatientId,
    String? currentPatientName,
    DateTime? checkInTime,
    DateTime? expectedCheckOut,
    double? pricePerNight,
    List<String>? amenities,
    String? notes,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return BedApiModel(
      id: id ?? this.id,
      bedNumber: bedNumber ?? this.bedNumber,
      status: status ?? this.status,
      wardId: wardId ?? this.wardId,
      wardName: wardName ?? this.wardName,
      facilityId: facilityId ?? this.facilityId,
      facilityName: facilityName ?? this.facilityName,
      floor: floor ?? this.floor,
      currentPatientId: currentPatientId ?? this.currentPatientId,
      currentPatientName: currentPatientName ?? this.currentPatientName,
      checkInTime: checkInTime ?? this.checkInTime,
      expectedCheckOut: expectedCheckOut ?? this.expectedCheckOut,
      pricePerNight: pricePerNight ?? this.pricePerNight,
      amenities: amenities ?? this.amenities,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

/// Create Bed Request model
class CreateBedRequest {
  final String bedNumber;
  final String wardId;
  final String floor;
  final String status;
  final double? pricePerNight;
  final List<String>? amenities;
  final String? notes;

  CreateBedRequest({
    required this.bedNumber,
    required this.wardId,
    required this.floor,
    this.status = 'Available',
    this.pricePerNight,
    this.amenities,
    this.notes,
  });

  Map<String, dynamic> toJson() {
    return {
      'bedNumber': bedNumber,
      'wardId': wardId,
      'floor': floor,
      'status': status,
      'pricePerNight': pricePerNight,
      'amenities': amenities,
      'notes': notes,
    };
  }
}

/// Update Bed Request model
class UpdateBedRequest {
  final String? bedNumber;
  final String? wardId;
  final String? floor;
  final String? status;
  final String? currentPatientId;
  final String? currentPatientName;
  final DateTime? checkInTime;
  final DateTime? expectedCheckOut;
  final double? pricePerNight;
  final List<String>? amenities;
  final String? notes;

  UpdateBedRequest({
    this.bedNumber,
    this.wardId,
    this.floor,
    this.status,
    this.currentPatientId,
    this.currentPatientName,
    this.checkInTime,
    this.expectedCheckOut,
    this.pricePerNight,
    this.amenities,
    this.notes,
  });

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
    
    if (bedNumber != null) json['bedNumber'] = bedNumber;
    if (wardId != null) json['wardId'] = wardId;
    if (floor != null) json['floor'] = floor;
    if (status != null) json['status'] = status;
    if (currentPatientId != null) json['currentPatientId'] = currentPatientId;
    if (currentPatientName != null) json['currentPatientName'] = currentPatientName;
    if (checkInTime != null) json['checkInTime'] = checkInTime!.toIso8601String();
    if (expectedCheckOut != null) json['expectedCheckOut'] = expectedCheckOut!.toIso8601String();
    if (pricePerNight != null) json['pricePerNight'] = pricePerNight;
    if (amenities != null) json['amenities'] = amenities;
    if (notes != null) json['notes'] = notes;
    
    return json;
  }
}
