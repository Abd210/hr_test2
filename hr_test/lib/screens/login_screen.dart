//login_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/custom_button.dart';

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

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();

  // Pre-fill username & password
  final TextEditingController _usernameController =
  TextEditingController(text: 'superadmin');
  final TextEditingController _passwordController =
  TextEditingController(text: 'admin123');

  bool _passwordVisible = false;
  String _error = '';

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _attemptLogin(AuthProvider authProvider) {
    if (_formKey.currentState!.validate()) {
      final success = authProvider.login(
        _usernameController.text.trim(),
        _passwordController.text.trim(),
      );
      if (success) {
        if (authProvider.currentUser != null &&
            authProvider.currentUser!.roles.any((r) => r.roleName == 'SuperAdmin')) {
          Navigator.pushReplacementNamed(context, '/admin');
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Logged in as user'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } else {
        setState(() {
          _error = 'Invalid credentials. Please try again.';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    return Scaffold(
      // Enhanced background with gradient
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              secondaryGreen,
              primaryDarkGreen,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Container(
              constraints: const BoxConstraints(maxWidth: 400),
              // Slightly more refined card with transparency effect
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.9),
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
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: Theme.of(context).primaryColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 24),
                      // Username Field
                      CustomTextField(
                        label: 'Username',
                        controller: _usernameController,
                        validator: (value) =>
                        (value == null || value.isEmpty) ? 'Enter username' : null,
                      ),
                      const SizedBox(height: 16),
                      // Password Field
                      CustomTextField(
                        label: 'Password',
                        controller: _passwordController,
                        obscureText: !_passwordVisible,
                        validator: (value) =>
                        (value == null || value.isEmpty) ? 'Enter password' : null,
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
                      const SizedBox(height: 24),
                      // Login Button
                      CustomButton(
                        text: 'Login',
                        icon: Icons.login,
                        onPressed: () => _attemptLogin(authProvider),
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
      ),
    );
  }
}
