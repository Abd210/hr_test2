import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/persistent_navbar.dart';
import '../../widgets/background_animation.dart';
import '../../utils/theme.dart';

// Existing tabs
import 'tabs/dashboard_tab/dashboard_tab.dart';
import 'tabs/organization_tab/organizations_tab.dart';
import 'tabs/user_tab/users_tab.dart';

// NEW DomainTab (replaces TestsTab)
import 'tabs/domain_tab/domain_tab.dart';

class AdminScreen extends StatefulWidget {
  const AdminScreen({Key? key}) : super(key: key);

  @override
  State<AdminScreen> createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

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
                    Expanded(
                      child: IndexedStack(
                        index: _currentIndex,
                        children: const [
                          // 0 => Dashboard
                          DashboardScreen(),
                          // 1 => Organizations
                          OrganizationsTab(),
                          // 2 => Users
                          UsersTab(),
                          // 3 => Domains (replaced Tests)
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
