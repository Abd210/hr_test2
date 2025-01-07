import 'package:flutter/material.dart';
import 'package:hr_test/screens/organization/tabs/users_tab/domain_tab_org.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/admin_provider.dart';
import '../../widgets/persistent_navbar.dart';
import '../../widgets/background_animation.dart';
import '../../utils/theme.dart';

// Example reused from admin
import '../admin/tabs/dashboard_tab/dashboard_tab.dart';

import 'tabs/users_tab/organization_users_tab.dart';

class OrganizationScreen extends StatefulWidget {
  const OrganizationScreen({Key? key}) : super(key: key);

  @override
  State<OrganizationScreen> createState() => _OrganizationScreenState();
}

class _OrganizationScreenState extends State<OrganizationScreen> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final organization = authProvider.currentOrganization;

    // If for some reason organization is null, maybe show an error or redirect
    if (organization == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Error')),
        body: const Center(
          child: Text('No organization found. Please login as organization.'),
        ),
      );
    }

    return Scaffold(
      body: Stack(
        children: [
          const BackgroundAnimation(),

          Row(
            children: [
              // left persistent navbar with isAdmin=false
              PersistentNavbar(
                currentIndex: _currentIndex,
                onItemSelected: (index) {
                  setState(() => _currentIndex = index);
                },
                isAdmin: false,
              ),

              Expanded(
                child: Column(
                  children: [
                    // top bar
                    Container(
                      height: 60,
                      color: Theme.of(context).primaryColor.withOpacity(0.1),
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Row(
                        children: [
                          Text(
                            '${organization.name} Dashboard',
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

                    // body => your tabs
                    Expanded(
                      child: IndexedStack(
                        index: _currentIndex,
                        children: [
                          // 0 => Dashboard
                          const DashboardScreen(),
                          // 1 => OrganizationUsersTab
                          const OrganizationUsersTab(),
                          // 2 => DomainTabOrg, but we pass "organization"
                          DomainTabOrg(organization: organization),
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
