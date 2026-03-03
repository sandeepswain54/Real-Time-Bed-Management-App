/// Ward Model for API responses
class WardApiModel {
  final String id;
  final String name;
  final String facilityId;
  final String facilityName;
  final String floor;
  final int capacity;
  final int occupiedBeds;
  final int availableBeds;
  final String? description;
  final DateTime createdAt;
  final DateTime updatedAt;

  WardApiModel({
    required this.id,
    required this.name,
    required this.facilityId,
    required this.facilityName,
    required this.floor,
    required this.capacity,
    required this.occupiedBeds,
    required this.availableBeds,
    this.description,
    required this.createdAt,
    required this.updatedAt,
  });

  factory WardApiModel.fromJson(Map<String, dynamic> json) {
    return WardApiModel(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? 'Unknown',
      facilityId: json['facilityId'] as String? ?? '',
      facilityName: json['facilityName'] as String? ?? 'Unknown',
      floor: json['floor'] as String? ?? 'N/A',
      capacity: json['capacity'] as int? ?? 0,
      occupiedBeds: json['occupiedBeds'] as int? ?? 0,
      availableBeds: json['availableBeds'] as int? ?? 0,
      description: json['description'] as String?,
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
      'name': name,
      'facilityId': facilityId,
      'facilityName': facilityName,
      'floor': floor,
      'capacity': capacity,
      'occupiedBeds': occupiedBeds,
      'availableBeds': availableBeds,
      'description': description,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  double get occupancyRate => capacity > 0 ? (occupiedBeds / capacity) * 100 : 0;

  WardApiModel copyWith({
    String? id,
    String? name,
    String? facilityId,
    String? facilityName,
    String? floor,
    int? capacity,
    int? occupiedBeds,
    int? availableBeds,
    String? description,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return WardApiModel(
      id: id ?? this.id,
      name: name ?? this.name,
      facilityId: facilityId ?? this.facilityId,
      facilityName: facilityName ?? this.facilityName,
      floor: floor ?? this.floor,
      capacity: capacity ?? this.capacity,
      occupiedBeds: occupiedBeds ?? this.occupiedBeds,
      availableBeds: availableBeds ?? this.availableBeds,
      description: description ?? this.description,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

/// Create Ward Request model
class CreateWardRequest {
  final String name;
  final String facilityId;
  final String floor;
  final int capacity;
  final String? description;

  CreateWardRequest({
    required this.name,
    required this.facilityId,
    required this.floor,
    required this.capacity,
    this.description,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'facilityId': facilityId,
      'floor': floor,
      'capacity': capacity,
      'description': description,
    };
  }
}

/// Update Ward Request model
class UpdateWardRequest {
  final String? name;
  final String? floor;
  final int? capacity;
  final String? description;

  UpdateWardRequest({
    this.name,
    this.floor,
    this.capacity,
    this.description,
  });

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
    
    if (name != null) json['name'] = name;
    if (floor != null) json['floor'] = floor;
    if (capacity != null) json['capacity'] = capacity;
    if (description != null) json['description'] = description;
    
    return json;
  }
}
