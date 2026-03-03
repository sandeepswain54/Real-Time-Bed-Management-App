import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:bed_app/Theme/app_theme.dart';
import 'package:bed_app/providers/auth.dart';
import 'package:bed_app/screens/dashboard_screen.dart';
import 'package:bed_app/screens/beds_screen.dart';
import 'package:bed_app/screens/allocate_screen.dart';
import 'package:bed_app/screens/analytics_screen.dart';
import 'package:bed_app/screens/profile_screen.dart';

class MainNavigationScreen extends StatefulWidget {
  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _selectedIndex = 0;

  late List<Widget> _screens;

  @override
  void initState() {
    super.initState();
    _screens = [
      DashboardScreen(),
      BedsScreen(),
      AllocateScreen(),
      AnalyticsScreen(),
      ProfileScreen(),
    ];
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final userRole = authProvider.currentUser?.role ?? 'Operator';

    // Hide maintenance-restricted tabs
    final isMaintenance = userRole == 'Maintenance Staff';

    return Scaffold(
      body: _screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        elevation: 16,
        selectedItemColor: AppTheme.primaryColor,
        unselectedItemColor: AppTheme.textSecondary,
        selectedFontSize: 12,
        unselectedFontSize: 12,
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard_rounded),
            label: 'Dashboard',
          ),
          if (!isMaintenance)
            BottomNavigationBarItem(
              icon: Icon(Icons.bed_rounded),
              label: 'Beds',
            ),
          if (!isMaintenance)
            BottomNavigationBarItem(
              icon: Icon(Icons.add_circle_outline_rounded),
              label: 'Allocate',
            ),
          if (!isMaintenance)
            BottomNavigationBarItem(
              icon: Icon(Icons.bar_chart_rounded),
              label: 'Analytics',
            ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_rounded),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
