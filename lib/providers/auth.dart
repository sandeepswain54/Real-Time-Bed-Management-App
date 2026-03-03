import 'package:flutter/material.dart';
import 'package:bed_app/Models/user_model.dart';
import 'package:bed_app/Models/mock_data.dart';

class AuthProvider extends ChangeNotifier {
  User? _currentUser;
  bool _isLoading = false;
  String? _selectedRole;

  User? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _currentUser != null;
  String? get selectedRole => _selectedRole;

  Future<bool> login(String email, String password) async {
    _isLoading = true;
    notifyListeners();

    // Simulate API call
    await Future.delayed(const Duration(seconds: 1));

    // Match against mock users
    try {
      final user = MockData.mockUsers.firstWhere(
        (u) => u['email'] == email && u['password'] == password,
      );

      final name = email.split('@')[0];
      _currentUser = User(
        id: email.hashCode.toString(),
        name: name.replaceFirst(name[0], name[0].toUpperCase()),
        email: email,
        role: user['role']!,
        avatar: 'https://i.pravatar.cc/150?img=${email.hashCode % 70}',
        facility: MockData.facilities[0]['name']! as String,
        phone: '+1-555-0100',
      );

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  void selectRole(String role) {
    _selectedRole = role;
    if (_currentUser != null) {
      _currentUser = _currentUser!.copyWith(role: role);
    }
    notifyListeners();
  }

  void logout() {
    _currentUser = null;
    _selectedRole = null;
    notifyListeners();
  }
}
