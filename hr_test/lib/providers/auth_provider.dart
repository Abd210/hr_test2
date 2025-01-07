import 'package:flutter/material.dart';
import '../models/organization.dart';
import '../models/user.dart';
import 'admin_provider.dart';

class AuthProvider with ChangeNotifier {
  User? _currentUser;
  Organization? _currentOrganization;
  bool _isOrganizationMode = false;

  final AdminProvider _adminProvider;
  AuthProvider(this._adminProvider);

  User? get currentUser => _currentUser;
  Organization? get currentOrganization => _currentOrganization;
  bool get isOrganizationMode => _isOrganizationMode;

  // Admin login
  bool login(String username, String password) {
    try {
      final user = _adminProvider.users.firstWhere(
            (u) => u.username == username && u.password == password,
      );
      _currentUser = user;
      _currentOrganization = null;
      _isOrganizationMode = false;
      notifyListeners();
      return true;
    } catch (e) {
      return false;
    }
  }

  // Organization login
  void loginAsOrganization(Organization org) {
    _currentUser = null;
    _currentOrganization = org;
    _isOrganizationMode = true;
    notifyListeners();
  }

  // Normal user
  void loginAsNormalUser(String username) {
    try {
      final user = _adminProvider.users.firstWhere(
            (u) => u.username.toLowerCase() == username.toLowerCase(),
      );
      _currentUser = user;
      _currentOrganization = null;
      _isOrganizationMode = false;
      notifyListeners();
    } catch (e) {
      _currentUser = null;
      _isOrganizationMode = false;
    }
  }

  // Logout
  void logout() {
    _currentUser = null;
    _currentOrganization = null;
    _isOrganizationMode = false;
    notifyListeners();
  }
}
