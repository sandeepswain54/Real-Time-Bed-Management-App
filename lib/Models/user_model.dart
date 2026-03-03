// lib/models/user_model.dart
class User {
  final String id;
  final String name;
  final String email;
  final String role;
  final String avatar;
  final String facility;
  final String? phone;
  final DateTime? createdAt;
  final bool isActive;

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    required this.avatar,
    required this.facility,
    this.phone,
    this.createdAt,
    this.isActive = true,
  });

  User copyWith({
    String? id,
    String? name,
    String? email,
    String? role,
    String? avatar,
    String? facility,
    String? phone,
    DateTime? createdAt,
    bool? isActive,
  }) {
    return User(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      role: role ?? this.role,
      avatar: avatar ?? this.avatar,
      facility: facility ?? this.facility,
      phone: phone ?? this.phone,
      createdAt: createdAt ?? this.createdAt,
      isActive: isActive ?? this.isActive,
    );
  }
}

class UserRole {
  static const String admin = 'Admin';
  static const String operator = 'Operator';
  static const String maintenance = 'Maintenance Staff';
}