// lib/screens/admin/admin_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/test_model.dart';
import 'tabs/dashboard_tab/dashboard_tab.dart';
import 'tabs/organization_tab/organizations_tab.dart';
import 'tabs/user_tab/users_tab.dart';
import 'tabs/test_tab/tests_tab.dart';
import '../../providers/admin_provider.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/persistent_navbar.dart';
import '../../widgets/background_animation.dart';
import '../../utils/theme.dart';

class AdminScreen extends StatefulWidget {
  const AdminScreen({Key? key}) : super(key: key);

  @override
  State<AdminScreen> createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen> {
  // Current tab index
  int _currentIndex = 0;

  // Manage Questions inline state
  bool _showManageQuestions = false;
  TestModel? _selectedTestForQuestions;

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    return Scaffold(
      body: Stack(
        children: [
          // Background wave animation
          const BackgroundAnimation(),

          // Main content
          Row(
            children: [
              // Left persistent navbar
              PersistentNavbar(
                currentIndex: _currentIndex,
                onItemSelected: (index) {
                  setState(() {
                    _currentIndex = index;
                    // If we leave the Tests tab, also close Manage Questions
                    if (_currentIndex != 3) {
                      _showManageQuestions = false;
                      _selectedTestForQuestions = null;
                    }
                  });
                },
              ),

              // Main area
              Expanded(
                child: Column(
                  children: [
                    // Top bar
                    Container(
                      height: 60,
                      color: Theme.of(context).primaryColor.withOpacity(0.1),
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Row(
                        children: [
                          Text(
                            'Admin Dashboard',
                            style: TextStyle(
                              color: Theme.of(context).primaryColor,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const Spacer(),
                          IconButton(
                            icon: const Icon(Icons.logout),
                            color: Theme.of(context).primaryColor,
                            onPressed: () {
                              authProvider.logout();
                              Navigator.pushReplacementNamed(context, '/');
                            },
                            tooltip: 'Logout',
                          ),
                        ],
                      ),
                    ),

                    // Body: Tabs managed by separate widgets
                    Expanded(
                      child: IndexedStack(
                        index: _currentIndex,
                        children: [
                          // 0 => DashboardScreen
                          const DashboardScreen(),

                          // 1 => Organizations
                          OrganizationsTab(),

                          // 2 => Users
                          UsersTab(),

                          // 3 => Tests
                          TestsTab(
                            showManageQuestions: _showManageQuestions,
                            selectedTestForQuestions: _selectedTestForQuestions,
                            onManageQuestions: (test) {
                              setState(() {
                                _showManageQuestions = true;
                                _selectedTestForQuestions = test;
                              });
                            },
                            onCloseManageQuestions: () {
                              setState(() {
                                _showManageQuestions = false;
                                _selectedTestForQuestions = null;
                              });
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
