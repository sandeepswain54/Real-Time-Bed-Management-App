// lib/models/bed_model.dart
import 'package:flutter/material.dart';

enum BedStatus {
  available,
  occupied,
  reserved,
  cleaning,
  blocked,
}

class BedModel {
  final String id;
  final String number; // Bed number (e.g., 'A101')
  final String roomNumber; // Alias for compatibility
  final String facility; // Facility name
  final String facilityId; // Facility ID for filtering
  final String floor;
  final String ward;
  final String status; // String status for compatibility
  BedStatus? bedStatus; // Enum status
  final String? currentPatient;
  final String? assignedPatient;
  final DateTime? checkInTime;
  final DateTime? expectedCheckOut;
  final DateTime lastUpdated;
  final String? lastMaintenance;
  final double pricePerNight;
  final List<String> amenities;
  final String? notes;

  BedModel({
    required this.id,
    required this.number,
    required this.facility,
    required this.facilityId,
    required this.floor,
    required this.ward,
    required this.status,
    this.bedStatus,
    this.currentPatient,
    this.assignedPatient,
    this.checkInTime,
    this.expectedCheckOut,
    required this.lastUpdated,
    this.lastMaintenance,
    required this.pricePerNight,
    required this.amenities,
    this.notes,
  }) : roomNumber = number; // roomNumber is alias for compatibility

  Color get statusColor {
    switch (status.toLowerCase()) {
      case 'available':
        return const Color(0xFF36B37E); // Green
      case 'occupied':
        return const Color(0xFFFF5630); // Red
      case 'reserved':
        return const Color(0xFFFFAB00); // Orange
      case 'cleaning':
        return const Color(0xFF00B8D9); // Blue
      case 'blocked':
        return const Color(0xFF6B778C); // Grey
      default:
        return const Color(0xFFCCCCCC);
    }
  }

  String get statusText {
    switch (status.toLowerCase()) {
      case 'available':
        return 'Available';
      case 'occupied':
        return 'Occupied';
      case 'reserved':
        return 'Reserved';
      case 'cleaning':
        return 'Cleaning';
      case 'blocked':
        return 'Blocked';
      default:
        return status;
    }
  }

  BedModel copyWith({
    String? id,
    String? number,
    String? facility,
    String? facilityId,
    String? floor,
    String? ward,
    String? status,
    BedStatus? bedStatus,
    String? currentPatient,
    String? assignedPatient,
    DateTime? checkInTime,
    DateTime? expectedCheckOut,
    DateTime? lastUpdated,
    String? lastMaintenance,
    double? pricePerNight,
    List<String>? amenities,
    String? notes,
  }) {
    return BedModel(
      id: id ?? this.id,
      number: number ?? this.number,
      facility: facility ?? this.facility,
      facilityId: facilityId ?? this.facilityId,
      floor: floor ?? this.floor,
      ward: ward ?? this.ward,
      status: status ?? this.status,
      bedStatus: bedStatus ?? this.bedStatus,
      currentPatient: currentPatient ?? this.currentPatient,
      assignedPatient: assignedPatient ?? this.assignedPatient,
      checkInTime: checkInTime ?? this.checkInTime,
      expectedCheckOut: expectedCheckOut ?? this.expectedCheckOut,
      lastUpdated: lastUpdated ?? this.lastUpdated,
      lastMaintenance: lastMaintenance ?? this.lastMaintenance,
      pricePerNight: pricePerNight ?? this.pricePerNight,
      amenities: amenities ?? this.amenities,
      notes: notes ?? this.notes,
    );
  }
}