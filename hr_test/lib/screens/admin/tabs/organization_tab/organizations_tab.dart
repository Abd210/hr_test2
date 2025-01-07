import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../providers/admin_provider.dart';
import '../../../../widgets/custom_text_field.dart';
import '../../../../widgets/custom_button.dart';
import '../../../../models/organization.dart';
import '../../../../models/user.dart';

class OrganizationsTab extends StatefulWidget {
  const OrganizationsTab({Key? key}) : super(key: key);

  @override
  State<OrganizationsTab> createState() => _OrganizationsTabState();
}

class _OrganizationsTabState extends State<OrganizationsTab> {
  final TextEditingController _orgSearchController = TextEditingController();
  final TextEditingController _orgNameController = TextEditingController();
  final TextEditingController _orgDescController = TextEditingController();

  // We track whether we’re viewing the main list or a specific org’s detail
  bool _viewingDetail = false;
  Organization? _selectedOrganization;

  @override
  void dispose() {
    _orgSearchController.dispose();
    _orgNameController.dispose();
    _orgDescController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final adminProvider = Provider.of<AdminProvider>(context, listen: true);

    return _viewingDetail && _selectedOrganization != null
        ? _buildOrganizationDetailView(context, adminProvider)
        : _buildOrganizationListView(context, adminProvider);
  }

  // --------------------------------------------------------------------------
  // 1) Organization List View
  // --------------------------------------------------------------------------
  Widget _buildOrganizationListView(
      BuildContext context, AdminProvider adminProvider) {
    final filteredOrgs = adminProvider.organizations.where((org) {
      final query = _orgSearchController.text.trim().toLowerCase();
      return org.name.toLowerCase().contains(query) ||
          org.description.toLowerCase().contains(query);
    }).toList();

    return Row(
      children: [
        // Left: Organization List & Search
        Expanded(
          flex: 3,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
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
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                filteredOrgs.isEmpty
                    ? const Center(child: Text('No organizations found.'))
                    : Expanded(
                  child: ListView.builder(
                    itemCount: filteredOrgs.length,
                    itemBuilder: (ctx, i) {
                      final org = filteredOrgs[i];
                      return Card(
                        margin: const EdgeInsets.symmetric(vertical: 8),
                        child: ListTile(
                          title: Text(
                            org.name,
                            style: const TextStyle(
                                fontWeight: FontWeight.bold),
                          ),
                          subtitle:
                          Text('Description: ${org.description}'),
                          onTap: () {
                            setState(() {
                              _selectedOrganization = org;
                              _viewingDetail = true;
                            });
                          },
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
                ),
              ],
            ),
          ),
        ),

        // Right: Add Organization form
        Container(
          width: 300,
          padding: const EdgeInsets.all(16),
          child: SingleChildScrollView(
            child: Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
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
                      validator: (value) => (value == null || value.isEmpty)
                          ? 'Please enter organization name'
                          : null,
                    ),
                    const SizedBox(height: 12),
                    CustomTextField(
                      label: 'Description',
                      controller: _orgDescController,
                      validator: (value) => (value == null || value.isEmpty)
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
                            backgroundColor: Colors.green,
                          ),
                        );
                      },
                      width: double.infinity,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // --------------------------------------------------------------------------
  // 2) Organization Detail View
  // --------------------------------------------------------------------------
  Widget _buildOrganizationDetailView(
      BuildContext context, AdminProvider adminProvider) {
    final org = _selectedOrganization!;
    return OrganizationDetailView(
      organization: org,
      onBack: () {
        setState(() {
          _viewingDetail = false;
          _selectedOrganization = null;
        });
      },
    );
  }

  // --------------------------------------------------------------------------
  // Utility methods
  // --------------------------------------------------------------------------
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
              child:
              const Text('Cancel', style: TextStyle(color: Colors.grey)),
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
    final nameController = TextEditingController(text: org.name);
    final descController = TextEditingController(text: org.description);

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
                  controller: nameController,
                ),
                const SizedBox(height: 12),
                CustomTextField(
                  label: 'Description',
                  controller: descController,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              child:
              const Text('Cancel', style: TextStyle(color: Colors.grey)),
              onPressed: () => Navigator.pop(ctx),
            ),
            ElevatedButton(
              child: const Text('Save', style: TextStyle(color: Colors.white)),
              onPressed: () {
                final newName = nameController.text.trim();
                final newDesc = descController.text.trim();
                if (newName.isEmpty || newDesc.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Fill all fields'),
                      backgroundColor: Colors.red,
                    ),
                  );
                  return;
                }
                adminProvider.updateOrganization(org.id, newName, newDesc);
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Organization updated'),
                    backgroundColor: Colors.green,
                  ),
                );
              },
            ),
          ],
        );
      },
    );
  }
}

/// Separate widget (full screen in the context of the tab) that shows
/// the chosen organization’s user listing, with a search bar, etc.
class OrganizationDetailView extends StatefulWidget {
  final Organization organization;
  final VoidCallback onBack;

  const OrganizationDetailView({
    Key? key,
    required this.organization,
    required this.onBack,
  }) : super(key: key);

  @override
  State<OrganizationDetailView> createState() => _OrganizationDetailViewState();
}

class _OrganizationDetailViewState extends State<OrganizationDetailView> {
  final TextEditingController _userSearchController = TextEditingController();

  @override
  void dispose() {
    _userSearchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final adminProvider = Provider.of<AdminProvider>(context, listen: true);
    final orgUsers = adminProvider.users.where((u) {
      return u.organization.id == widget.organization.id;
    }).toList();

    final query = _userSearchController.text.trim().toLowerCase();
    final filteredUsers = orgUsers.where((u) {
      final phone = u.phoneNumber ?? '';
      return u.username.toLowerCase().contains(query) ||
          u.email.toLowerCase().contains(query) ||
          phone.toLowerCase().contains(query);
    }).toList();

    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Top Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                widget.organization.name,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).primaryColor,
                ),
              ),
              CustomButton(
                text: 'Back to Orgs',
                icon: Icons.arrow_back,
                isOutlined: true,
                onPressed: widget.onBack,
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            widget.organization.description,
            style: const TextStyle(fontSize: 14),
          ),
          const SizedBox(height: 16),

          // Search bar for users
          Row(
            children: [
              Expanded(
                child: CustomTextField(
                  label: 'Search Users...',
                  controller: _userSearchController,
                  hintText: 'Search by username, email or phone',
                  onChanged: (_) => setState(() {}),
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                icon: const Icon(Icons.search),
                onPressed: () => setState(() {}),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // List of users
          if (filteredUsers.isEmpty)
            const Expanded(
              child: Center(child: Text('No users found.')),
            )
          else
            Expanded(
              child: ListView.builder(
                itemCount: filteredUsers.length,
                itemBuilder: (ctx, i) {
                  final user = filteredUsers[i];
                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    child: ListTile(
                      title: Text(user.username),
                      subtitle: Text(
                        'Email: ${user.email}\nPhone: ${user.phoneNumber ?? 'N/A'}',
                      ),
                      isThreeLine: true,
                    ),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}
