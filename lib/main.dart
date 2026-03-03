import 'package:bed_app/screens/role_selection_screen.dart';
import 'package:bed_app/screens/main_navigation.dart';
import 'package:bed_app/Auth/login.dart';
import 'package:bed_app/providers/auth.dart';
import 'package:bed_app/splashscreen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/bed_provider.dart';

import 'theme/app_theme.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp();

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => BedProvider()),
      ],
      child: MaterialApp(
        title: 'BedFlow - Bed Management System',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        home: SplashScreen(),
        routes: {
          '/login': (context) => LoginScreen(),
          '/role-selection': (context) => RoleSelectionScreen(),
          '/dashboard': (context) => MainNavigationScreen(),
        },
      ),
    );
  }
}

