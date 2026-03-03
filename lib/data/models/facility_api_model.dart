/// Facility Model for API responses
class FacilityApiModel {
  final String id;
  final String name;
  final String address;
  final String? city;
  final String? state;
  final String? zipCode;
  final String? phone;
  final String? email;
  final int totalBeds;
  final int occupiedBeds;
  final int availableBeds;
  final int totalWards;
  final DateTime createdAt;
  final DateTime updatedAt;

  FacilityApiModel({
    required this.id,
    required this.name,
    required this.address,
    this.city,
    this.state,
    this.zipCode,
    this.phone,
    this.email,
    required this.totalBeds,
    required this.occupiedBeds,
    required this.availableBeds,
    required this.totalWards,
    required this.createdAt,
    required this.updatedAt,
  });

  factory FacilityApiModel.fromJson(Map<String, dynamic> json) {
    return FacilityApiModel(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? 'Unknown',
      address: json['address'] as String? ?? '',
      city: json['city'] as String?,
      state: json['state'] as String?,
      zipCode: json['zipCode'] as String?,
      phone: json['phone'] as String?,
      email: json['email'] as String?,
      totalBeds: json['totalBeds'] as int? ?? 0,
      occupiedBeds: json['occupiedBeds'] as int? ?? 0,
      availableBeds: json['availableBeds'] as int? ?? 0,
      totalWards: json['totalWards'] as int? ?? 0,
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
      'address': address,
      'city': city,
      'state': state,
      'zipCode': zipCode,
      'phone': phone,
      'email': email,
      'totalBeds': totalBeds,
      'occupiedBeds': occupiedBeds,
      'availableBeds': availableBeds,
      'totalWards': totalWards,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  double get occupancyRate => totalBeds > 0 ? (occupiedBeds / totalBeds) * 100 : 0;

  FacilityApiModel copyWith({
    String? id,
    String? name,
    String? address,
    String? city,
    String? state,
    String? zipCode,
    String? phone,
    String? email,
    int? totalBeds,
    int? occupiedBeds,
    int? availableBeds,
    int? totalWards,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return FacilityApiModel(
      id: id ?? this.id,
      name: name ?? this.name,
      address: address ?? this.address,
      city: city ?? this.city,
      state: state ?? this.state,
      zipCode: zipCode ?? this.zipCode,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      totalBeds: totalBeds ?? this.totalBeds,
      occupiedBeds: occupiedBeds ?? this.occupiedBeds,
      availableBeds: availableBeds ?? this.availableBeds,
      totalWards: totalWards ?? this.totalWards,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

/// Create Facility Request model
class CreateFacilityRequest {
  final String name;
  final String address;
  final String? city;
  final String? state;
  final String? zipCode;
  final String? phone;
  final String? email;

  CreateFacilityRequest({
    required this.name,
    required this.address,
    this.city,
    this.state,
    this.zipCode,
    this.phone,
    this.email,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'address': address,
      'city': city,
      'state': state,
      'zipCode': zipCode,
      'phone': phone,
      'email': email,
    };
  }
}

/// Update Facility Request model
class UpdateFacilityRequest {
  final String? name;
  final String? address;
  final String? city;
  final String? state;
  final String? zipCode;
  final String? phone;
  final String? email;

  UpdateFacilityRequest({
    this.name,
    this.address,
    this.city,
    this.state,
    this.zipCode,
    this.phone,
    this.email,
  });

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
    
    if (name != null) json['name'] = name;
    if (address != null) json['address'] = address;
    if (city != null) json['city'] = city;
    if (state != null) json['state'] = state;
    if (zipCode != null) json['zipCode'] = zipCode;
    if (phone != null) json['phone'] = phone;
    if (email != null) json['email'] = email;
    
    return json;
  }
}
