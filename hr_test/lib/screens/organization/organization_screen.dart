import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/admin_provider.dart';
import '../../widgets/persistent_navbar.dart';
import '../../widgets/background_animation.dart';
import '../admin/tabs/dashboard_tab/dashboard_tab.dart';
import '../organization/tabs/users_tab/organization_users_tab.dart';

// Reuse the new DomainTab in organizations as well
import '../../screens/admin/tabs/domain_tab/domain_tab.dart';

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

    return Scaffold(
      body: Stack(
        children: [
          const BackgroundAnimation(),
          Row(
            children: [
              PersistentNavbar(
                currentIndex: _currentIndex,
                onItemSelected: (index) {
                  setState(() {
                    _currentIndex = index;
                  });
                },
                isAdmin: false,
              ),
              Expanded(
                child: Column(
                  children: [
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
                    Expanded(
                      child: IndexedStack(
                        index: _currentIndex,
                        children: const [
                          DashboardScreen(),
                          OrganizationUsersTab(),
                          // Now show DomainTab to allow assigning tests from an org perspective
                          DomainTab(),
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
