import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/organization.dart';
import '../models/user.dart';
import '../providers/auth_provider.dart';
import '../providers/admin_provider.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/custom_button.dart';
import 'test_screen.dart';
import 'admin/admin_screen.dart';
import 'organization/organization_screen.dart';
import 'user/user_tests_screen.dart';
import '../widgets/background_animation.dart';
import '../utils/constants.dart';

enum LoginMode { Admin, Organization, User }

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();

  // Admin Login
  final TextEditingController _adminUsernameController =
  TextEditingController(text: 'superadmin');
  final TextEditingController _adminPasswordController =
  TextEditingController(text: 'admin123');

  // Organization Login
  final TextEditingController _organizationNameController =
  TextEditingController(text: 'HR Department');
  final TextEditingController _organizationPasswordController =
  TextEditingController();

  // User Login (username-only)
  final TextEditingController _userUsernameController =
  TextEditingController(text: 'john_hr');

  bool _passwordVisible = false;
  String _error = '';
  LoginMode _loginMode = LoginMode.Admin;

  @override
  void dispose() {
    _adminUsernameController.dispose();
    _adminPasswordController.dispose();
    _organizationNameController.dispose();
    _organizationPasswordController.dispose();
    _userUsernameController.dispose();
    super.dispose();
  }

  void _attemptLogin(AuthProvider authProvider, AdminProvider adminProvider) {
    setState(() => _error = '');
    if (_loginMode == LoginMode.Admin) {
      final username = _adminUsernameController.text.trim();
      final password = _adminPasswordController.text.trim();
      if (username.isEmpty || password.isEmpty) {
        setState(() => _error = 'Please enter both username and password.');
        return;
      }
      final success = authProvider.login(username, password);
      if (success) {
        final user = authProvider.currentUser!;
        // If user password didn't match a real user, it might be a test key
        if (user.id != -1) {
          // If user is superAdmin or admin, go AdminScreen
          if (user.roles.any((r) => r.roleName == Constants.superAdminRole) ||
              user.roles.any((r) => r.roleName == Constants.adminRole)) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const AdminScreen()),
            );
            return;
          }
        }
      }
      // If not found, check if it's a test key
      final questions = adminProvider.getTestByKey(password);
      if (questions != null) {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => TestScreen(questions: questions)),
        );
        return;
      }
      setState(() => _error = 'Invalid credentials or test key.');
    }

    else if (_loginMode == LoginMode.Organization) {
      final orgName = _organizationNameController.text.trim();
      if (orgName.isEmpty) {
        setState(() => _error = 'Please enter an organization name.');
        return;
      }
      final organization = adminProvider.organizations.firstWhere(
            (org) => org.name.toLowerCase() == orgName.toLowerCase(),
        orElse: () => Organization(id: -1, name: '', description: '', createdAt: DateTime.now()),
      );
      if (organization.id != -1) {
        authProvider.loginAsOrganization(organization);
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const OrganizationScreen()),
        );
      } else {
        setState(() => _error = 'Organization not found.');
      }
    }

    else {
      // LoginMode.User => username only
      final enteredUsername = _userUsernameController.text.trim();
      if (enteredUsername.isEmpty) {
        setState(() => _error = 'Please enter your username.');
        return;
      }
      // Let AuthProvider handle it
      authProvider.loginAsNormalUser(enteredUsername);
      if (authProvider.currentUser != null &&
          authProvider.currentUser!.id != -1) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const UserTestsScreen()),
        );
      } else {
        setState(() => _error = 'No user found with username "$enteredUsername".');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final adminProvider = Provider.of<AdminProvider>(context);

    return Scaffold(
      body: Stack(
        children: [
          const BackgroundAnimation(),
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.green.withOpacity(0.6),
                  Colors.teal.withOpacity(0.6),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Container(
                constraints: const BoxConstraints(maxWidth: 400),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.85),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'HR Tester Login',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            color: Theme.of(context).primaryColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 24),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            ChoiceChip(
                              label: const Text('Admin'),
                              selected: _loginMode == LoginMode.Admin,
                              onSelected: (sel) {
                                setState(() {
                                  _loginMode = LoginMode.Admin;
                                  _error = '';
                                });
                              },
                              selectedColor: Colors.orangeAccent.withOpacity(0.7),
                            ),
                            const SizedBox(width: 12),
                            ChoiceChip(
                              label: const Text('Organization'),
                              selected: _loginMode == LoginMode.Organization,
                              onSelected: (sel) {
                                setState(() {
                                  _loginMode = LoginMode.Organization;
                                  _error = '';
                                });
                              },
                              selectedColor: Colors.orangeAccent.withOpacity(0.7),
                            ),
                            const SizedBox(width: 12),
                            ChoiceChip(
                              label: const Text('User'),
                              selected: _loginMode == LoginMode.User,
                              onSelected: (sel) {
                                setState(() {
                                  _loginMode = LoginMode.User;
                                  _error = '';
                                });
                              },
                              selectedColor: Colors.orangeAccent.withOpacity(0.7),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),

                        if (_loginMode == LoginMode.Admin) ...[
                          CustomTextField(
                            label: 'Username',
                            controller: _adminUsernameController,
                          ),
                          const SizedBox(height: 16),
                          CustomTextField(
                            label: 'Password / Test Key',
                            controller: _adminPasswordController,
                            obscureText: !_passwordVisible,
                            suffixIcon: IconButton(
                              onPressed: () {
                                setState(() => _passwordVisible = !_passwordVisible);
                              },
                              icon: Icon(
                                _passwordVisible
                                    ? Icons.visibility
                                    : Icons.visibility_off,
                              ),
                            ),
                          ),
                        ] else if (_loginMode == LoginMode.Organization) ...[
                          CustomTextField(
                            label: 'Organization Name',
                            controller: _organizationNameController,
                          ),
                          CustomTextField(
                            label: 'Password (Optional)',
                            controller: _organizationPasswordController,
                            obscureText: !_passwordVisible,
                            suffixIcon: IconButton(
                              onPressed: () {
                                setState(() => _passwordVisible = !_passwordVisible);
                              },
                              icon: Icon(
                                _passwordVisible
                                    ? Icons.visibility
                                    : Icons.visibility_off,
                              ),
                            ),
                          ),
                        ] else ...[
                          CustomTextField(
                            label: 'Username',
                            controller: _userUsernameController,
                          ),
                        ],
                        const SizedBox(height: 24),

                        CustomButton(
                          text: 'Login',
                          icon: Icons.login,
                          onPressed: () => _attemptLogin(authProvider, adminProvider),
                          width: double.infinity,
                        ),
                        if (_error.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(top: 16),
                            child: Text(
                              _error,
                              style: const TextStyle(color: Colors.red),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
