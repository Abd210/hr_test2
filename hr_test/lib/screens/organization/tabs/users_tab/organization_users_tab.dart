// lib/screens/organization/tabs/users_tab/organization_users_tab.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../models/user.dart';
import '../../../../providers/admin_provider.dart';
import '../../../../providers/auth_provider.dart';


class OrganizationUsersTab extends StatelessWidget {
  const OrganizationUsersTab({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final adminProvider = Provider.of<AdminProvider>(context);
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final organization = authProvider.currentOrganization;

    // Filter users based on the current organization
    final organizationUsers = adminProvider.users.where((user) {
      return user.organization.id == organization?.id;
    }).toList();

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Header
          Row(
            children: [
              Text(
                'Users',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).primaryColor,
                ),
              ),
              const Spacer(),
              // Add User Button (Optional)
              // You can implement adding users if required
              // CustomButton(
              //   text: 'Add User',
              //   icon: Icons.add,
              //   onPressed: () {
              //     // Implement add user functionality
              //   },
              // ),
            ],
          ),
          const SizedBox(height: 16),

          // Users List
          organizationUsers.isEmpty
              ? const Center(child: Text('No users found for this organization.'))
              : Expanded(
            child: ListView.builder(
              itemCount: organizationUsers.length,
              itemBuilder: (ctx, index) {
                final user = organizationUsers[index];
                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  child: ListTile(
                    title: Text(
                      user.username,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(
                      'Email: ${user.email}\nPhone: ${user.phoneNumber ?? 'N/A'}',
                    ),
                    isThreeLine: true,
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Edit User Button
                        IconButton(
                          icon: const Icon(Icons.edit, color: Colors.orange),
                          onPressed: () {
                            // Implement edit user functionality
                            // For simplicity, show a snackbar
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Edit User not implemented.'),
                              ),
                            );
                          },
                          tooltip: 'Edit',
                        ),
                        // Delete User Button
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () {
                            _confirmDeletion(
                              context: context,
                              user: user,
                            );
                          },
                          tooltip: 'Delete',
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  /// Confirms the deletion of a user.
  void _confirmDeletion({
    required BuildContext context,
    required User user,
  }) {
    final adminProvider = Provider.of<AdminProvider>(context, listen: false);
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Text('Delete User', style: TextStyle(fontWeight: FontWeight.bold)),
          content: Text('Are you sure you want to delete user "${user.username}"?'),
          actions: [
            TextButton(
              child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
              onPressed: () => Navigator.pop(ctx),
            ),
            ElevatedButton(
              onPressed: () {
                adminProvider.deleteUser(user.id);
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('User deleted successfully.'),
                    backgroundColor: Colors.green,
                  ),
                );
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }
}
