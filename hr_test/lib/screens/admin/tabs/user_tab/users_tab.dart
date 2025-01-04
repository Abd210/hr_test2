// lib/screens/admin/tabs/users_tab.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../providers/admin_provider.dart';
import '../../../../widgets/custom_text_field.dart';
import '../../../../widgets/custom_button.dart';
import '../../../../models/user.dart';

class UsersTab extends StatefulWidget {
  const UsersTab({Key? key}) : super(key: key);

  @override
  State<UsersTab> createState() => _UsersTabState();
}

class _UsersTabState extends State<UsersTab> {
  // Controllers for Users
  final TextEditingController _userSearchController = TextEditingController();
  final TextEditingController _userNameController = TextEditingController();
  final TextEditingController _userEmailController = TextEditingController();
  final TextEditingController _userPasswordController = TextEditingController();
  final TextEditingController _userPhoneController = TextEditingController();

  @override
  void dispose() {
    // Dispose controllers
    _userSearchController.dispose();
    _userNameController.dispose();
    _userEmailController.dispose();
    _userPasswordController.dispose();
    _userPhoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final adminProvider = Provider.of<AdminProvider>(context);
    final filtered = adminProvider.users.where((u) {
      final query = _userSearchController.text.trim().toLowerCase();
      return u.username.toLowerCase().contains(query) ||
          u.email.toLowerCase().contains(query) ||
          (u.phoneNumber ?? '').toLowerCase().contains(query);
    }).toList();

    return Row(
      children: [
        Expanded(
          flex: 3,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // Search
                Row(
                  children: [
                    Expanded(
                      child: CustomTextField(
                        label: 'Search Users...',
                        controller: _userSearchController,
                        onChanged: (_) => setState(() {}),
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      icon: const Icon(Icons.search),
                      onPressed: () => setState(() {}),
                      tooltip: 'Search',
                    )
                  ],
                ),
                const SizedBox(height: 16),

                filtered.isEmpty
                    ? const Center(child: Text('No users found.'))
                    : Expanded(
                  child: ListView.builder(
                    itemCount: filtered.length,
                    itemBuilder: (ctx, i) {
                      final user = filtered[i];
                      return Card(
                        margin: const EdgeInsets.symmetric(vertical: 8),
                        child: ListTile(
                          title: Text(
                            user.username,
                            style: const TextStyle(
                                fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text(
                            'Email: ${user.email}\n'
                                'Phone: ${user.phoneNumber ?? 'N/A'}',
                          ),
                          isThreeLine: true,
                          trailing: SizedBox(
                            width: 100,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.edit,
                                      color: Colors.orange),
                                  onPressed: () {
                                    _showEditUserDialog(user, adminProvider);
                                  },
                                  tooltip: 'Edit',
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete,
                                      color: Colors.red),
                                  onPressed: () {
                                    _confirmDeletion(
                                      title: 'Delete User',
                                      content:
                                      'Delete "${user.username}"?',
                                      onConfirm: () {
                                        adminProvider.deleteUser(user.id);
                                        Navigator.pop(context);
                                      },
                                    );
                                  },
                                  tooltip: 'Delete',
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                )
              ],
            ),
          ),
        ),
        // Right: add user form
        Container(
          width: 300,
          padding: const EdgeInsets.all(16),
          child: SingleChildScrollView(
            child: Card(
              elevation: 2,
              shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Text(
                      'Add User',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                    const SizedBox(height: 12),
                    CustomTextField(
                      label: 'Username',
                      controller: _userNameController,
                    ),
                    const SizedBox(height: 12),
                    CustomTextField(
                      label: 'Email',
                      controller: _userEmailController,
                      keyboardType: TextInputType.emailAddress,
                    ),
                    const SizedBox(height: 12),
                    CustomTextField(
                      label: 'Password',
                      controller: _userPasswordController,
                      obscureText: true,
                    ),
                    const SizedBox(height: 12),
                    CustomTextField(
                      label: 'Phone Number',
                      controller: _userPhoneController,
                      keyboardType: TextInputType.phone,
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<int>(
                      decoration:
                      const InputDecoration(labelText: 'Select Organization'),
                      items: adminProvider.organizations
                          .map(
                            (org) => DropdownMenuItem<int>(
                          value: org.id,
                          child: Text(org.name),
                        ),
                      )
                          .toList(),
                      onChanged: (val) {
                        // Handle organization selection if needed
                      },
                      hint: const Text('Choose Org'),
                    ),
                    const SizedBox(height: 12),
                    CustomButton(
                      text: 'Add User',
                      icon: Icons.person_add,
                      onPressed: () {
                        if (_userNameController.text.trim().isEmpty ||
                            _userEmailController.text.trim().isEmpty ||
                            _userPasswordController.text.trim().isEmpty ||
                            _userPhoneController.text.trim().isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Please fill all fields'),
                              backgroundColor: Colors.red,
                            ),
                          );
                          return;
                        }
                        if (adminProvider.organizations.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('No organization available.'),
                              backgroundColor: Colors.red,
                            ),
                          );
                          return;
                        }
                        final selectedOrg = adminProvider.organizations.firstWhere(
                              (org) => org.id == (adminProvider.organizations.isNotEmpty ? org.id : 1),
                          orElse: () => adminProvider.organizations.first,
                        );
                        adminProvider.addUser(
                          username: _userNameController.text.trim(),
                          email: _userEmailController.text.trim(),
                          password: _userPasswordController.text.trim(),
                          phoneNumber: _userPhoneController.text.trim(),
                          roles: [],
                          organization: selectedOrg,
                        );
                        _userNameController.clear();
                        _userEmailController.clear();
                        _userPasswordController.clear();
                        _userPhoneController.clear();
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text('User added'),
                              backgroundColor: Colors.green),
                        );
                      },
                      width: double.infinity,
                    )
                  ],
                ),
              ),
            ),
          ),
        )
      ],
    );
  }

  // ----------------------------------------------------------------------
  // Reusable CRUD Helpers
  // ----------------------------------------------------------------------
  void _confirmDeletion({
    required String title,
    required String content,
    required VoidCallback onConfirm,
  }) {
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title:
          Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
          content: Text(content),
          actions: [
            TextButton(
              child: const Text('Cancel',
                  style: TextStyle(color: Colors.grey)),
              onPressed: () => Navigator.pop(ctx),
            ),
            ElevatedButton(
              onPressed: onConfirm,
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }

  void _showEditUserDialog(User user, AdminProvider adminProvider) {
    final _editNameController = TextEditingController(text: user.username);
    final _editEmailController = TextEditingController(text: user.email);
    final _editPhoneController =
    TextEditingController(text: user.phoneNumber ?? '');
    int selectedOrgId = user.organization.id;

    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setStateDialog) {
            return AlertDialog(
              title: const Text('Edit User',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              content: SingleChildScrollView(
                child: Column(
                  children: [
                    CustomTextField(
                        label: 'Username', controller: _editNameController),
                    const SizedBox(height: 12),
                    CustomTextField(
                        label: 'Email', controller: _editEmailController),
                    const SizedBox(height: 12),
                    CustomTextField(
                        label: 'Phone Number',
                        controller: _editPhoneController),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<int>(
                      decoration:
                      const InputDecoration(labelText: 'Select Organization'),
                      value: selectedOrgId,
                      items: adminProvider.organizations
                          .map(
                            (o) => DropdownMenuItem<int>(
                          value: o.id,
                          child: Text(o.name),
                        ),
                      )
                          .toList(),
                      onChanged: (val) {
                        if (val != null) {
                          setStateDialog(() {
                            selectedOrgId = val;
                          });
                        }
                      },
                      hint: const Text('Choose Org'),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  child: const Text('Cancel',
                      style: TextStyle(color: Colors.grey)),
                  onPressed: () => Navigator.pop(ctx),
                ),
                ElevatedButton(
                  child: const Text('Save',style: TextStyle(color: Colors.white),),
                  onPressed: () {
                    if (_editNameController.text.trim().isEmpty ||
                        _editEmailController.text.trim().isEmpty ||
                        _editPhoneController.text.trim().isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text('Fill all fields'),
                            backgroundColor: Colors.red),
                      );
                      return;
                    }
                    final selectedOrg = adminProvider.organizations.firstWhere(
                          (o) => o.id == selectedOrgId,
                      orElse: () => user.organization,
                    );
                    adminProvider.updateUser(
                      id: user.id,
                      username: _editNameController.text.trim(),
                      email: _editEmailController.text.trim(),
                      phoneNumber: _editPhoneController.text.trim(),
                      roles: user.roles,
                      organization: selectedOrg,
                    );
                    Navigator.pop(ctx);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text('User updated'),
                          backgroundColor: Colors.green),
                    );
                  },
                )
              ],
            );
          },
        );
      },
    );
  }
}
