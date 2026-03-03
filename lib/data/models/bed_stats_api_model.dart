/// Bed Statistics Model for API responses
class BedStatsApiModel {
  final int totalBeds;
  final int availableBeds;
  final int occupiedBeds;
  final int reservedBeds;
  final int cleaningBeds;
  final int blockedBeds;
  final double occupancyRate;
  final double availabilityRate;
  final Map<String, int> bedsByWard;
  final Map<String, int> bedsByFloor;
  final Map<String, int> bedsByStatus;

  BedStatsApiModel({
    required this.totalBeds,
    required this.availableBeds,
    required this.occupiedBeds,
    required this.reservedBeds,
    required this.cleaningBeds,
    required this.blockedBeds,
    required this.occupancyRate,
    required this.availabilityRate,
    required this.bedsByWard,
    required this.bedsByFloor,
    required this.bedsByStatus,
  });

  factory BedStatsApiModel.fromJson(Map<String, dynamic> json) {
    return BedStatsApiModel(
      totalBeds: json['totalBeds'] as int? ?? 0,
      availableBeds: json['availableBeds'] as int? ?? 0,
      occupiedBeds: json['occupiedBeds'] as int? ?? 0,
      reservedBeds: json['reservedBeds'] as int? ?? 0,
      cleaningBeds: json['cleaningBeds'] as int? ?? 0,
      blockedBeds: json['blockedBeds'] as int? ?? 0,
      occupancyRate: (json['occupancyRate'] as num?)?.toDouble() ?? 0.0,
      availabilityRate: (json['availabilityRate'] as num?)?.toDouble() ?? 0.0,
      bedsByWard: json['bedsByWard'] != null 
          ? Map<String, int>.from(json['bedsByWard'] as Map)
          : {},
      bedsByFloor: json['bedsByFloor'] != null 
          ? Map<String, int>.from(json['bedsByFloor'] as Map)
          : {},
      bedsByStatus: json['bedsByStatus'] != null 
          ? Map<String, int>.from(json['bedsByStatus'] as Map)
          : {},
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'totalBeds': totalBeds,
      'availableBeds': availableBeds,
      'occupiedBeds': occupiedBeds,
      'reservedBeds': reservedBeds,
      'cleaningBeds': cleaningBeds,
      'blockedBeds': blockedBeds,
      'occupancyRate': occupancyRate,
      'availabilityRate': availabilityRate,
      'bedsByWard': bedsByWard,
      'bedsByFloor': bedsByFloor,
      'bedsByStatus': bedsByStatus,
    };
  }

  BedStatsApiModel copyWith({
    int? totalBeds,
    int? availableBeds,
    int? occupiedBeds,
    int? reservedBeds,
    int? cleaningBeds,
    int? blockedBeds,
    double? occupancyRate,
    double? availabilityRate,
    Map<String, int>? bedsByWard,
    Map<String, int>? bedsByFloor,
    Map<String, int>? bedsByStatus,
  }) {
    return BedStatsApiModel(
      totalBeds: totalBeds ?? this.totalBeds,
      availableBeds: availableBeds ?? this.availableBeds,
      occupiedBeds: occupiedBeds ?? this.occupiedBeds,
      reservedBeds: reservedBeds ?? this.reservedBeds,
      cleaningBeds: cleaningBeds ?? this.cleaningBeds,
      blockedBeds: blockedBeds ?? this.blockedBeds,
      occupancyRate: occupancyRate ?? this.occupancyRate,
      availabilityRate: availabilityRate ?? this.availabilityRate,
      bedsByWard: bedsByWard ?? this.bedsByWard,
      bedsByFloor: bedsByFloor ?? this.bedsByFloor,
      bedsByStatus: bedsByStatus ?? this.bedsByStatus,
    );
  }
}
