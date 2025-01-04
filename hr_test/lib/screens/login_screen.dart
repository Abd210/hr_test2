// lib/screens/login_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/organization.dart';
import '../models/user.dart';
import '../providers/auth_provider.dart';
import '../providers/admin_provider.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/custom_button.dart';
import 'test_screen.dart'; // Ensure you have a TestScreen to display the test
import 'admin/admin_screen.dart';
import 'organization/organization_screen.dart';
import '../widgets/background_animation.dart'; // Import the BackgroundAnimation widget

/// Example palette for background:
const Color primaryDarkGreen = Color(0xFF1F4529);
const Color secondaryGreen = Color(0xFF47663B);
const Color backgroundLight = Color(0xFFE8ECD7);
const Color accentColor = Color(0xFFEED3B1);

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

enum LoginMode { Admin, Organization }

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();

  // Controllers for Admin Login
  final TextEditingController _adminUsernameController =
  TextEditingController(text: 'superadmin'); // Pre-filled username
  final TextEditingController _adminPasswordController =
  TextEditingController(text: 'admin123'); // Pre-filled password

  // Controller for Organization Login
  final TextEditingController _organizationNameController =
  TextEditingController();

  bool _passwordVisible = false;
  String _error = '';

  LoginMode _loginMode = LoginMode.Admin;

  @override
  void dispose() {
    _adminUsernameController.dispose();
    _adminPasswordController.dispose();
    _organizationNameController.dispose();
    super.dispose();
  }

  /// Attempts to log in either as an admin, organization, or using a test key.
  void _attemptLogin(AuthProvider authProvider, AdminProvider adminProvider) {
    if (_loginMode == LoginMode.Admin) {
      final username = _adminUsernameController.text.trim();
      final password = _adminPasswordController.text.trim();

      if (username.isEmpty || password.isEmpty) {
        setState(() {
          _error = 'Please enter both username and password.';
        });
        return;
      }

      // Check if the input matches any user's credentials
      final user = authProvider.allUsers.firstWhere(
            (u) => u.username == username && u.password == password,
        orElse: () => User(
            id: -1,
            username: '',
            email: '',
            password: '',
            phoneNumber: '',
            createdAt: DateTime.now(),
            roles: [],
            organization: Organization(
                id: 0, name: '', description: '', createdAt: DateTime.now())),
      );

      if (user.id != -1) {
        // Valid user credentials
        final success = authProvider.login(username, password);
        if (success) {
          if (user.roles.any((r) => r.roleName == 'SuperAdmin')) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const AdminScreen()),
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Logged in as admin'),
                backgroundColor: Colors.green,
              ),
            );
            // Navigate to admin-specific dashboard or home
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const AdminScreen()),
            );
          }
        } else {
          setState(() {
            _error = 'Invalid credentials. Please try again.';
          });
        }
        return;
      }

      // If not a valid user, treat the password field as a test key
      final questions = adminProvider.getTestByKey(password);
      if (questions != null) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => TestScreen(questions: questions),
          ),
        );
        return;
      }

      // If neither, show error
      setState(() {
        _error = 'Invalid credentials or test key.';
      });
    } else {
      // Organization Login Mode
      final organizationName = _organizationNameController.text.trim();

      if (organizationName.isEmpty) {
        setState(() {
          _error = 'Please enter an organization name.';
        });
        return;
      }

      // Attempt organization login
      final organization = adminProvider.organizations.firstWhere(
            (org) => org.name.toLowerCase() == organizationName.toLowerCase(),
        orElse: () => Organization(
            id: -1,
            name: '',
            description: '',
            createdAt: DateTime.now()),
      );

      if (organization.id != -1) {
        // Valid organization
        authProvider.loginAsOrganization(organization);
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const OrganizationScreen()),
        );
      } else {
        setState(() {
          _error = 'Organization not found. Please try again.';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final adminProvider = Provider.of<AdminProvider>(context);

    return Scaffold(
      // Use Stack to layer BackgroundAnimation behind the login form
      body: Stack(
        children: [
          // Animated Background
          const BackgroundAnimation(),

          // Semi-transparent overlay to enhance readability
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  secondaryGreen.withOpacity(0.6),
                  primaryDarkGreen.withOpacity(0.6),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),

          // Centered Login Form
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Container(
                constraints: const BoxConstraints(maxWidth: 400),
                // Slightly more refined card with transparency effect
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.85),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    )
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
                          style: Theme.of(context)
                              .textTheme
                              .titleLarge
                              ?.copyWith(
                            color: Theme.of(context).primaryColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 24),
                        // Toggle between Admin and Organization Login
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            ChoiceChip(
                              label: const Text('Admin'),
                              selected: _loginMode == LoginMode.Admin,
                              onSelected: (selected) {
                                setState(() {
                                  _loginMode = LoginMode.Admin;
                                  _error = '';
                                });
                              },
                              selectedColor: accentColor.withOpacity(0.7),
                            ),
                            const SizedBox(width: 16),
                            ChoiceChip(
                              label: const Text('Organization'),
                              selected: _loginMode == LoginMode.Organization,
                              onSelected: (selected) {
                                setState(() {
                                  _loginMode = LoginMode.Organization;
                                  _error = '';
                                });
                              },
                              selectedColor: accentColor.withOpacity(0.7),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        // Admin Login Fields
                        if (_loginMode == LoginMode.Admin) ...[
                          // Username Field (Pre-filled for SuperAdmin)
                          CustomTextField(
                            label: 'Username',
                            controller: _adminUsernameController,
                            validator: (value) => (value == null || value.isEmpty)
                                ? 'Enter username or leave blank for test key'
                                : null,
                          ),
                          const SizedBox(height: 16),
                          // Password Field (Pre-filled for SuperAdmin)
                          CustomTextField(
                            label: 'Password / Test Key',
                            controller: _adminPasswordController,
                            obscureText: !_passwordVisible,
                            validator: (value) => (value == null || value.isEmpty)
                                ? 'Enter password or test key'
                                : null,
                            suffixIcon: IconButton(
                              onPressed: () {
                                setState(() {
                                  _passwordVisible = !_passwordVisible;
                                });
                              },
                              icon: Icon(
                                _passwordVisible
                                    ? Icons.visibility
                                    : Icons.visibility_off,
                              ),
                            ),
                          ),
                        ] else ...[
                          // Organization Login Field
                          CustomTextField(
                            label: 'Organization Name',
                            controller: _organizationNameController,
                            validator: (value) => (value == null || value.isEmpty)
                                ? 'Enter organization name'
                                : null,
                          ),
                        ],
                        const SizedBox(height: 24),
                        // Login Button
                        CustomButton(
                          text: 'Login',
                          icon: Icons.login,
                          onPressed: () =>
                              _attemptLogin(authProvider, adminProvider),
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
