import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_text_field.dart';
import '../utils/constants.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();

  // Define controllers as state variables
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  String _error = '';
  bool _passwordVisible = false;

  @override
  void dispose() {
    // Dispose controllers when the widget is disposed
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _attemptLogin(AuthProvider authProvider) {
    if (_formKey.currentState!.validate()) {
      String username = _usernameController.text.trim();
      String password = _passwordController.text.trim();
      bool success = authProvider.login(username, password);
      if (success) {
        if (authProvider.currentUser!.roles
            .any((role) => role.roleName == Constants.superAdminRole)) {
          Navigator.pushReplacementNamed(context, '/admin');
        } else {
          // Navigate to other dashboards based on role
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Logged in as user.'),
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
      body: Center(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(24.0),
          child: Container(
            constraints: BoxConstraints(maxWidth: 400),
            child: Card(
              color: Colors.white,
              elevation: 8,
              shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: EdgeInsets.all(24.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'HR Tester Login',
                        style:
                        TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 32),
                      // Username Field
                      CustomTextField(
                        label: 'Username',
                        controller: _usernameController,
                        validator: (value) =>
                        value!.isEmpty ? 'Please enter username' : null,
                      ),
                      SizedBox(height: 16),
                      // Password Field
                      CustomTextField(
                        label: 'Password',
                        controller: _passwordController,
                        obscureText: !_passwordVisible,
                        validator: (value) =>
                        value!.isEmpty ? 'Please enter password' : null,
                        suffixIcon: IconButton(
                          icon: Icon(
                            _passwordVisible
                                ? Icons.visibility
                                : Icons.visibility_off,
                          ),
                          onPressed: () {
                            setState(() {
                              _passwordVisible = !_passwordVisible;
                            });
                          },
                        ),
                      ),
                      SizedBox(height: 24),
                      // Login Button
                      CustomButton(
                        text: 'Login',
                        icon: Icons.login,
                        onPressed: () => _attemptLogin(authProvider),
                      ),
                      if (_error.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 16.0),
                          child: Text(
                            _error,
                            style: TextStyle(color: Colors.red),
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
