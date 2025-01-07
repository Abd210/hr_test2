import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../models/test_domain.dart';
import '../../../../models/test_model.dart';
import '../../../../models/organization.dart';
import '../../../../models/user.dart';
import '../../../../providers/admin_provider.dart';
import '../../../../widgets/custom_text_field.dart';
import '../../../../widgets/custom_button.dart';

class DomainTab extends StatefulWidget {
  const DomainTab({Key? key}) : super(key: key);

  @override
  State<DomainTab> createState() => _DomainTabState();
}

class _DomainTabState extends State<DomainTab> {
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _domainNameController = TextEditingController();
  final TextEditingController _domainDescController = TextEditingController();

  TestDomain? _selectedDomain;
  List<int> _selectedTestIds = [];

  @override
  void dispose() {
    _searchController.dispose();
    _domainNameController.dispose();
    _domainDescController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final adminProvider = Provider.of<AdminProvider>(context, listen: true);

    final filteredDomains = adminProvider.testDomains.where((dom) {
      final query = _searchController.text.trim().toLowerCase();
      return dom.name.toLowerCase().contains(query) ||
          dom.description.toLowerCase().contains(query);
    }).toList();

    return Row(
      children: [
        // Left side: Domain List & Add Domain
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
                        label: 'Search Domains...',
                        controller: _searchController,
                        hintText: 'Search by name or description',
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
                Expanded(
                  child: filteredDomains.isEmpty
                      ? const Center(child: Text('No domains found.'))
                      : ListView.builder(
                    itemCount: filteredDomains.length,
                    itemBuilder: (ctx, i) {
                      final dom = filteredDomains[i];
                      return Card(
                        margin: const EdgeInsets.symmetric(vertical: 8),
                        child: ListTile(
                          title: Text(dom.name,
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold)),
                          subtitle: Text(dom.description),
                          onTap: () {
                            setState(() {
                              _selectedDomain = dom;
                              _loadDomainTests(dom, adminProvider);
                            });
                          },
                          trailing: SizedBox(
                            width: 80,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.edit,
                                      color: Colors.orange),
                                  onPressed: () {
                                    _showEditDomainDialog(dom, adminProvider);
                                  },
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete,
                                      color: Colors.red),
                                  onPressed: () {
                                    _confirmDeletion(
                                      context: context,
                                      title: 'Delete Domain',
                                      content:
                                      'Are you sure you want to delete "${dom.name}"?',
                                      onConfirm: () {
                                        adminProvider.deleteTestDomain(dom.id);
                                        Navigator.pop(context);
                                      },
                                    );
                                  },
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

        // Right side: Add Domain Form & Domain Detail
        Container(
          width: 360,
          padding: const EdgeInsets.all(16),
          child: SingleChildScrollView(
            child: Column(
              children: [
                Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        Text(
                          'Add Domain',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: Theme.of(context).primaryColor,
                          ),
                        ),
                        const SizedBox(height: 12),
                        CustomTextField(
                          label: 'Domain Name',
                          controller: _domainNameController,
                        ),
                        const SizedBox(height: 12),
                        CustomTextField(
                          label: 'Description',
                          controller: _domainDescController,
                        ),
                        const SizedBox(height: 12),
                        CustomButton(
                          text: 'Add Domain',
                          icon: Icons.add,
                          onPressed: () {
                            final name = _domainNameController.text.trim();
                            final desc = _domainDescController.text.trim();
                            if (name.isEmpty || desc.isEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Please fill all fields'),
                                  backgroundColor: Colors.red,
                                ),
                              );
                              return;
                            }
                            final newDom = TestDomain(
                              id: (adminProvider.testDomains.isEmpty)
                                  ? 1
                                  : adminProvider.testDomains
                                  .map((d) => d.id)
                                  .reduce((a, b) => a > b ? a : b) +
                                  1,
                              name: name,
                              description: desc,
                              createdAt: DateTime.now(),
                            );
                            adminProvider.addTestDomain(newDom);
                            _domainNameController.clear();
                            _domainDescController.clear();
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text('Domain added'),
                                  backgroundColor: Colors.green),
                            );
                          },
                          width: double.infinity,
                        )
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                if (_selectedDomain != null)
                  _buildDomainDetails(adminProvider, _selectedDomain!),
              ],
            ),
          ),
        ),
      ],
    );
  }

  /// Loads the tests for a given domain and checks default ones if needed.
  void _loadDomainTests(TestDomain domain, AdminProvider adminProvider) {
    final domainTests =
    adminProvider.tests.where((t) => t.domainId == domain.id).toList();
    _selectedTestIds.clear();

    // For example, if domain is Secretary (id=3), check some defaults:
    if (domain.id == 3) {
      // Suppose English Test, Word Test, Excel Test, All-in-One are automatically checked
      for (var test in domainTests) {
        if (test.name.contains('English') ||
            test.name.contains('Word') ||
            test.name.contains('Excel') ||
            test.name.contains('All-in-One')) {
          _selectedTestIds.add(test.id);
        }
      }
    }

    setState(() {});
  }

  Widget _buildDomainDetails(AdminProvider adminProvider, TestDomain domain) {
    final domainTests =
    adminProvider.tests.where((t) => t.domainId == domain.id).toList();

    if (domainTests.isEmpty) {
      return Container(
        margin: const EdgeInsets.only(top: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Text('No tests available for this domain.'),
      );
    }

    return Container(
      margin: const EdgeInsets.only(top: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            '${domain.name} Tests',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).primaryColor,
            ),
          ),
          const SizedBox(height: 16),
          ...domainTests.map((test) {
            final isChecked = _selectedTestIds.contains(test.id);
            return CheckboxListTile(
              title: Text('${test.name} (Code: ${test.code})'),
              value: isChecked,
              onChanged: (val) {
                setState(() {
                  if (val == true) {
                    _selectedTestIds.add(test.id);
                  } else {
                    _selectedTestIds.remove(test.id);
                  }
                });
              },
            );
          }).toList(),
          const SizedBox(height: 16),
          CustomButton(
            text: 'Assign Selected Tests',
            icon: Icons.send,
            onPressed: _selectedTestIds.isEmpty
                ? null
                : () {
              _showAssignTestsDialog(adminProvider, _selectedTestIds);
            },
          ),
        ],
      ),
    );
  }

  void _showAssignTestsDialog(AdminProvider adminProvider, List<int> testIds) {
    showDialog(
      context: context,
      builder: (ctx) {
        return AssignTestsDialog(
          testIdsToAssign: testIds,
          adminProvider: adminProvider,
        );
      },
    );
  }

  void _showEditDomainDialog(TestDomain dom, AdminProvider adminProvider) {
    final nameController = TextEditingController(text: dom.name);
    final descController = TextEditingController(text: dom.description);

    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Text('Edit Domain', style: TextStyle(fontWeight: FontWeight.bold)),
          content: SingleChildScrollView(
            child: Column(
              children: [
                CustomTextField(
                  label: 'Domain Name',
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
              child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
              onPressed: () => Navigator.pop(ctx),
            ),
            ElevatedButton(
              child: const Text('Save'),
              onPressed: () {
                final newName = nameController.text.trim();
                final newDesc = descController.text.trim();
                if (newName.isEmpty || newDesc.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Please fill all fields'),
                      backgroundColor: Colors.red,
                    ),
                  );
                  return;
                }
                final updatedDomain = TestDomain(
                  id: dom.id,
                  name: newName,
                  description: newDesc,
                  createdAt: dom.createdAt,
                );
                adminProvider.updateTestDomain(updatedDomain);
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Domain updated'),
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

  void _confirmDeletion({
    required BuildContext context,
    required String title,
    required String content,
    required VoidCallback onConfirm,
  }) {
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
          content: Text(content),
          actions: [
            TextButton(
              child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
              onPressed: () => Navigator.pop(ctx),
            ),
            ElevatedButton(
              child: const Text('Delete'),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              onPressed: onConfirm,
            ),
          ],
        );
      },
    );
  }
}

/// Dialog for assigning tests to a user within an organization.
class AssignTestsDialog extends StatefulWidget {
  final List<int> testIdsToAssign;
  final AdminProvider adminProvider;

  const AssignTestsDialog({
    Key? key,
    required this.testIdsToAssign,
    required this.adminProvider,
  }) : super(key: key);

  @override
  State<AssignTestsDialog> createState() => _AssignTestsDialogState();
}

class _AssignTestsDialogState extends State<AssignTestsDialog> {
  int? _selectedOrganizationId;
  int? _selectedUserId;

  @override
  Widget build(BuildContext context) {
    final organizations = widget.adminProvider.organizations;
    List<User> usersOfOrg = [];

    if (_selectedOrganizationId != null) {
      usersOfOrg = widget.adminProvider.users.where((u) {
        return u.organization.id == _selectedOrganizationId;
      }).toList();
    }

    return AlertDialog(
      title: const Text('Assign Tests', style: TextStyle(fontWeight: FontWeight.bold)),
      content: SingleChildScrollView(
        child: Column(
          children: [
            DropdownButtonFormField<int>(
              decoration: const InputDecoration(labelText: 'Select Organization'),
              items: organizations.map((org) {
                return DropdownMenuItem<int>(
                  value: org.id,
                  child: Text(org.name),
                );
              }).toList(),
              onChanged: (val) {
                setState(() {
                  _selectedOrganizationId = val;
                  _selectedUserId = null;
                });
              },
              value: _selectedOrganizationId,
              hint: const Text('Choose Organization'),
            ),
            const SizedBox(height: 16),
            if (_selectedOrganizationId != null)
              DropdownButtonFormField<int>(
                decoration: const InputDecoration(labelText: 'Select Employee'),
                items: usersOfOrg.map((u) {
                  return DropdownMenuItem<int>(
                    value: u.id,
                    child: Text(u.username),
                  );
                }).toList(),
                onChanged: (val) {
                  setState(() {
                    _selectedUserId = val;
                  });
                },
                value: _selectedUserId,
                hint: const Text('Choose Employee'),
              ),
          ],
        ),
      ),
      actions: [
        TextButton(
          child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
          onPressed: () => Navigator.pop(context),
        ),
        ElevatedButton(
          child: const Text('Assign'),
          onPressed: (_selectedOrganizationId == null || _selectedUserId == null)
              ? null
              : () {
            widget.adminProvider.assignTestsToUser(
              _selectedUserId!,
              widget.testIdsToAssign,
            );
            Navigator.pop(context);
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Tests assigned to user successfully.'),
                backgroundColor: Colors.green,
              ),
            );
          },
        ),
      ],
    );
  }
}
