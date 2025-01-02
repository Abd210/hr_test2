//main.dart
import 'package:flutter/material.dart';

import 'package:provider/provider.dart';
import 'providers/auth_provider.dart';
import 'providers/admin_provider.dart';
import 'screens/login_screen.dart';
import 'screens/admin/admin_screen.dart';
import 'utils/theme.dart';

void main() {
  runApp(HRTesterApp());
}

class HRTesterApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<AuthProvider>(
          create: (_) => AuthProvider(),
        ),
        ChangeNotifierProvider<AdminProvider>(
          create: (_) => AdminProvider(),
        ),
        // Add other providers here
      ],
      child: MaterialApp(
        title: 'HR Tester',
        theme: appTheme,
        initialRoute: '/',
        routes: {
          '/': (context) => LoginScreen(),
          '/admin': (context) => AdminScreen(),
          // Define other routes here
        },
      ),
    );
  }
}
