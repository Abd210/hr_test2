import 'role.dart';
import 'organization.dart';

class User {
  final int id;
  String username;
  String email;
  String password;
  String? phoneNumber;
  DateTime createdAt;
  List<Role> roles;
  Organization organization;

  User({
    required this.id,
    required this.username,
    required this.email,
    required this.password,
    this.phoneNumber,
    required this.createdAt,
    required this.roles,
    required this.organization,
  });
}
