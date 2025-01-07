import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/admin_provider.dart';
import 'providers/auth_provider.dart';
import 'screens/login_screen.dart';
import 'screens/admin/admin_screen.dart';
import 'screens/organization/organization_screen.dart';
import 'screens/user/user_tests_screen.dart';
import 'utils/theme.dart';

void main() {
  runApp(const HRTesterApp());
}

class HRTesterApp extends StatelessWidget {
  const HRTesterApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<AdminProvider>(
          create: (_) => AdminProvider(),
        ),
        ChangeNotifierProxyProvider<AdminProvider, AuthProvider>(
          create: (ctx) => AuthProvider(
            Provider.of<AdminProvider>(ctx, listen: false),
          ),
          update: (ctx, adminProv, previous) => AuthProvider(adminProv),
        ),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'HR Tester',
        theme: appTheme,
        initialRoute: '/',
        routes: {
          '/': (context) => const LoginScreen(),
          '/admin': (context) => const AdminScreen(),
          '/organization': (context) => const OrganizationScreen(),
          '/user': (context) => const UserTestsScreen(),
        },
      ),
    );
  }
}
