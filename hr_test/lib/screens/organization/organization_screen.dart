// lib/screens/organization/organization_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/admin_provider.dart';
import '../../widgets/persistent_navbar.dart';
import '../../widgets/background_animation.dart';
import '../admin/tabs/dashboard_tab/dashboard_tab.dart'; // Reusing DashboardScreen
import '../admin/tabs/test_tab/tests_tab.dart'; // Reusing TestsTab
import 'tabs/users_tab/organization_users_tab.dart'; // New UsersTab
import '../../widgets/custom_button.dart';

class OrganizationScreen extends StatefulWidget {
  const OrganizationScreen({Key? key}) : super(key: key);

  @override
  State<OrganizationScreen> createState() => _OrganizationScreenState();
}

class _OrganizationScreenState extends State<OrganizationScreen> {
  // Current tab index
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final adminProvider = Provider.of<AdminProvider>(context, listen: false);
    final organization = authProvider.currentOrganization;

    return Scaffold(
      body: Stack(
        children: [
          // Background wave animation
          const BackgroundAnimation(),

          // Main content
          Row(
            children: [
              // Left persistent navbar with dynamic items
              PersistentNavbar(
                currentIndex: _currentIndex,
                onItemSelected: (index) {
                  setState(() {
                    _currentIndex = index;
                  });
                },
                isAdmin: false, // Indicate that this is for Organization
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
                            '${organization?.name ?? 'Organization'} Dashboard',
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
                          // 0 => DashboardScreen (Reused from Admin)
                          const DashboardScreen(),

                          // 1 => Users (New OrganizationUsersTab)
                          const OrganizationUsersTab(),

                          // 2 => Tests (Reused from Admin)
                          TestsTab(
                            showManageQuestions: false, // Organizations might not need this
                            selectedTestForQuestions: null,

                            onManageQuestions: (test) {
                              // Implement if needed
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Manage Questions not available.'),
                                ),
                              );
                            },
                            onCloseManageQuestions: () {
                              // Implement if needed
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
