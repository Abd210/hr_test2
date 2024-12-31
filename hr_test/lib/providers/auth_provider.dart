//auth_provider.dart
import 'package:flutter/material.dart';
import '../models/user.dart';
import '../models/role.dart';
import '../models/organization.dart';
import '../utils/constants.dart';

class AuthProvider with ChangeNotifier {
  User? _currentUser;

  User? get currentUser => _currentUser;

  // Sample users for demonstration purposes
  final List<User> _users = [
    User(
      id: 1,
      username: 'superadmin',
      email: 'superadmin@example.com',
      password: 'admin123', // In production, passwords should be hashed
      phoneNumber: '1234567890',
      createdAt: DateTime.now(),
      roles: [
        Role(
          id: 1,
          roleName: Constants.superAdminRole,
          description: 'Super Administrator with full access',
        ),
      ],
      organization: Organization(
        id: 1,
        name: 'HR Department',
        description: 'Handles all HR related tasks.',
        createdAt: DateTime.now(),
      ),
    ),
    User(
      id: 2,
      username: 'admin',
      email: 'admin@example.com',
      password: 'admin123',
      phoneNumber: '0987654321',
      createdAt: DateTime.now(),
      roles: [
        Role(
          id: 2,
          roleName: Constants.adminRole,
          description: 'Administrator with limited access',
        ),
      ],
      organization: Organization(
        id: 2,
        name: 'IT Department',
        description: 'Handles all IT related tasks.',
        createdAt: DateTime.now(),
      ),
    ),
    // Add more users as needed
  ];

  /// Attempts to log in a user with the provided [username] and [password].
  /// Returns `true` if successful, `false` otherwise.
  bool login(String username, String password) {
    try {
      User user = _users.firstWhere(
              (user) => user.username == username && user.password == password);
      _currentUser = user;
      notifyListeners();
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Logs out the current user.
  void logout() {
    _currentUser = null;
    notifyListeners();
  }

  /// Retrieves all users. This can be restricted based on roles in a real application.
  List<User> get allUsers => _users;

  /// Adds a new user to the system.
  void addUser(User user) {
    _users.add(user);
    notifyListeners();
  }

  /// Removes a user by their [userId].
  void removeUser(int userId) {
    _users.removeWhere((user) => user.id == userId);
    notifyListeners();
  }

  /// Updates an existing user's details.
  void updateUser(User updatedUser) {
    int index = _users.indexWhere((user) => user.id == updatedUser.id);
    if (index != -1) {
      _users[index] = updatedUser;
      notifyListeners();
    }
  }
}
