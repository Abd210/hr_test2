// lib/screens/admin/tabs/organizations_tab.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../providers/admin_provider.dart';
import '../../../../widgets/custom_text_field.dart';
import '../../../../widgets/custom_button.dart';
import '../../../../models/organization.dart';

class OrganizationsTab extends StatefulWidget {
  const OrganizationsTab({Key? key}) : super(key: key);

  @override
  State<OrganizationsTab> createState() => _OrganizationsTabState();
}

class _OrganizationsTabState extends State<OrganizationsTab> {
  // Controllers for Organizations
  final TextEditingController _orgSearchController = TextEditingController();
  final TextEditingController _orgNameController = TextEditingController();
  final TextEditingController _orgDescController = TextEditingController();

  @override
  void dispose() {
    // Dispose controllers
    _orgSearchController.dispose();
    _orgNameController.dispose();
    _orgDescController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final adminProvider = Provider.of<AdminProvider>(context);
    final filtered = adminProvider.organizations.where((org) {
      final query = _orgSearchController.text.trim().toLowerCase();
      return org.name.toLowerCase().contains(query) ||
          org.description.toLowerCase().contains(query);
    }).toList();

    return Row(
      children: [
        // Left: list
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
                        label: 'Search Organizations...',
                        controller: _orgSearchController,
                        onChanged: (_) => setState(() {}),
                        hintText: 'Search by name or description',
                        maxLines: 1,
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
                    ? const Center(child: Text('No organizations found.'))
                    : Expanded(
                  child: ListView.builder(
                    itemCount: filtered.length,
                    itemBuilder: (ctx, i) {
                      final org = filtered[i];
                      return Card(
                        margin: const EdgeInsets.symmetric(vertical: 8),
                        child: ListTile(
                          title: Text(org.name,
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold)),
                          subtitle:
                          Text('Description: ${org.description}'),
                          trailing: SizedBox(
                            width: 100,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.edit,
                                      color: Colors.orange),
                                  onPressed: () {
                                    _showEditOrganizationDialog(
                                        org, adminProvider);
                                  },
                                  tooltip: 'Edit',
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete,
                                      color: Colors.red),
                                  onPressed: () {
                                    _confirmDeletion(
                                      title: 'Delete Organization',
                                      content:
                                      'Are you sure you want to delete "${org.name}"?',
                                      onConfirm: () {
                                        adminProvider
                                            .deleteOrganization(org.id);
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
        // Right: add org form
        Container(
          width: 300,
          padding: const EdgeInsets.all(16),
          child: SingleChildScrollView(
            child: Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Text(
                      'Add Organization',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                    const SizedBox(height: 12),
                    CustomTextField(
                      label: 'Organization Name',
                      controller: _orgNameController,
                      validator: (value) =>
                      (value == null || value.isEmpty)
                          ? 'Please enter organization name'
                          : null,
                    ),
                    const SizedBox(height: 12),
                    CustomTextField(
                      label: 'Description',
                      controller: _orgDescController,
                      validator: (value) =>
                      (value == null || value.isEmpty)
                          ? 'Please enter description'
                          : null,
                    ),
                    const SizedBox(height: 12),
                    CustomButton(
                      text: 'Add Org',
                      icon: Icons.add,
                      onPressed: () {
                        if (_orgNameController.text.trim().isEmpty ||
                            _orgDescController.text.trim().isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Please fill all fields'),
                              backgroundColor: Colors.red,
                            ),
                          );
                          return;
                        }
                        adminProvider.addOrganization(
                          _orgNameController.text.trim(),
                          _orgDescController.text.trim(),
                        );
                        _orgNameController.clear();
                        _orgDescController.clear();
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text('Organization added'),
                              backgroundColor: Colors.green),
                        );
                      },
                      width: double.infinity,
                    ),
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

  void _showEditOrganizationDialog(
      Organization org, AdminProvider adminProvider) {
    final TextEditingController _editNameController =
    TextEditingController(text: org.name);
    final TextEditingController _editDescController =
    TextEditingController(text: org.description);

    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Text('Edit Organization',
              style: TextStyle(fontWeight: FontWeight.bold)),
          content: SingleChildScrollView(
            child: Column(
              children: [
                CustomTextField(
                    label: 'Organization Name',
                    controller: _editNameController,
                    validator: (value) =>
                    (value == null || value.isEmpty)
                        ? 'Please enter organization name'
                        : null),
                const SizedBox(height: 12),
                CustomTextField(
                    label: 'Description',
                    controller: _editDescController,
                    validator: (value) =>
                    (value == null || value.isEmpty)
                        ? 'Please enter description'
                        : null),
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
              child: const Text('Save'),
              onPressed: () {
                if (_editNameController.text.trim().isEmpty ||
                    _editDescController.text.trim().isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text('Fill all fields'),
                        backgroundColor: Colors.red),
                  );
                  return;
                }
                adminProvider.updateOrganization(
                  org.id,
                  _editNameController.text.trim(),
                  _editDescController.text.trim(),
                );
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content: Text('Organization updated'),
                      backgroundColor: Colors.green),
                );
              },
            )
          ],
        );
      },
    );
  }
}
