import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/admin_provider.dart';
import '../providers/auth_provider.dart';
import '../widgets/persistent_navbar.dart';
import '../widgets/item_card.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/custom_button.dart';

class AdminScreen extends StatefulWidget {
  const AdminScreen({Key? key}) : super(key: key);

  @override
  State<AdminScreen> createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen> {
  // Organization
  final TextEditingController _orgNameController = TextEditingController();
  final TextEditingController _orgDescController = TextEditingController();

  // User
  final TextEditingController _userNameController = TextEditingController();
  final TextEditingController _userEmailController = TextEditingController();
  final TextEditingController _userPasswordController = TextEditingController();
  final TextEditingController _userPhoneController = TextEditingController();

  // Test
  final TextEditingController _testCodeController = TextEditingController();
  final TextEditingController _testNameController = TextEditingController();
  final TextEditingController _testGradeController = TextEditingController();
  final TextEditingController _testDurationController = TextEditingController();

  int _currentIndex = 0;

  @override
  void dispose() {
    _orgNameController.dispose();
    _orgDescController.dispose();
    _userNameController.dispose();
    _userEmailController.dispose();
    _userPasswordController.dispose();
    _userPhoneController.dispose();
    _testCodeController.dispose();
    _testNameController.dispose();
    _testGradeController.dispose();
    _testDurationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final adminProvider = Provider.of<AdminProvider>(context);
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    final tabs = [
      _buildOrganizationsTab(adminProvider),
      _buildUsersTab(adminProvider),
      _buildTestsTab(adminProvider),
    ];

    return Scaffold(
      body: Column(
        children: [
          PersistentNavbar(
            title: const Text('SuperAdmin Dashboard'),
            actions: [
              IconButton(
                onPressed: () {
                  authProvider.logout();
                  Navigator.pushReplacementNamed(context, '/');
                },
                icon: const Icon(Icons.logout, color: Colors.white),
                tooltip: 'Logout',
              ),
            ],
          ),
          // "Website-like" horizontal menu bar
          Container(
            height: 56,
            color: Theme.of(context).colorScheme.surface,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                _buildNavItem('Organizations', 0),
                const SizedBox(width: 16),
                _buildNavItem('Users', 1),
                const SizedBox(width: 16),
                _buildNavItem('Tests', 2),
              ],
            ),
          ),
          Expanded(child: tabs[_currentIndex]),
        ],
      ),
    );
  }

  Widget _buildNavItem(String text, int index) {
    final isSelected = _currentIndex == index;
    return InkWell(
      onTap: () {
        setState(() => _currentIndex = index);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: isSelected
            ? BoxDecoration(
          color: Theme.of(context).primaryColor.withOpacity(0.2),
          borderRadius: BorderRadius.circular(8),
        )
            : null,
        child: Text(
          text,
          style: TextStyle(
            color:
            isSelected ? Theme.of(context).primaryColor : Colors.black87,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
      ),
    );
  }

  // -----------------------------------------------
  // Organizations Tab
  // -----------------------------------------------
  Widget _buildOrganizationsTab(AdminProvider adminProvider) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          _buildAddOrganizationCard(adminProvider),
          const SizedBox(height: 32),
          Wrap(
            spacing: 16,
            runSpacing: 16,
            children: adminProvider.organizations.isEmpty
                ? [
              const Center(
                child: Text('No organizations found.'),
              ),
            ]
                : adminProvider.organizations.map((org) {
              return ItemCard(
                title: org.name,
                subtitle: 'ID: ${org.id}',
                additionalInfo: [
                  'Description: ${org.description}',
                  'Created At: ${DateFormat.yMMMd().format(org.createdAt)}',
                ],
                actions: [
                  CardAction(
                    label: 'Edit',
                    icon: Icons.edit,
                    color: Colors.orange,
                    onPressed: () {
                      _showEditOrganizationDialog(org, adminProvider);
                    },
                  ),
                  CardAction(
                    label: 'Delete',
                    icon: Icons.delete,
                    color: Colors.red,
                    onPressed: () {
                      _confirmDeletion(
                        title: 'Delete Organization',
                        content:
                        'Are you sure you want to delete "${org.name}"?',
                        onConfirm: () {
                          adminProvider.deleteOrganization(org.id);
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Organization deleted'),
                              backgroundColor: Colors.green,
                            ),
                          );
                        },
                      );
                    },
                  ),
                ],
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildAddOrganizationCard(AdminProvider adminProvider) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Form(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Add Organization',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).primaryColor,
              ),
            ),
            const SizedBox(height: 16),
            CustomTextField(
              label: 'Organization Name',
              controller: _orgNameController,
              validator: (value) =>
              value == null || value.isEmpty ? 'Required' : null,
            ),
            const SizedBox(height: 16),
            CustomTextField(
              label: 'Description',
              controller: _orgDescController,
              validator: (value) =>
              value == null || value.isEmpty ? 'Required' : null,
            ),
            const SizedBox(height: 16),
            CustomButton(
              text: 'Add Organization',
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
                    content: Text('Organization added successfully'),
                    backgroundColor: Colors.green,
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  // -----------------------------------------------
  // Users Tab
  // -----------------------------------------------
  Widget _buildUsersTab(AdminProvider adminProvider) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          _buildAddUserCard(adminProvider),
          const SizedBox(height: 32),
          Wrap(
            spacing: 16,
            runSpacing: 16,
            children: adminProvider.users.isEmpty
                ? [
              const Center(
                child: Text('No users found.'),
              )
            ]
                : adminProvider.users.map((user) {
              return ItemCard(
                title: user.username,
                subtitle: 'ID: ${user.id}',
                additionalInfo: [
                  'Email: ${user.email}',
                  'Phone: ${user.phoneNumber ?? 'N/A'}',
                  'Organization: ${user.organization.name}',
                  'Roles: ${user.roles.map((r) => r.roleName).join(', ')}',
                ],
                actions: [
                  CardAction(
                    label: 'Edit',
                    icon: Icons.edit,
                    color: Colors.orange,
                    onPressed: () {
                      _showEditUserDialog(user, adminProvider);
                    },
                  ),
                  CardAction(
                    label: 'Delete',
                    icon: Icons.delete,
                    color: Colors.red,
                    onPressed: () {
                      _confirmDeletion(
                        title: 'Delete User',
                        content:
                        'Are you sure you want to delete "${user.username}"?',
                        onConfirm: () {
                          adminProvider.deleteUser(user.id);
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('User deleted'),
                              backgroundColor: Colors.green,
                            ),
                          );
                        },
                      );
                    },
                  ),
                ],
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildAddUserCard(AdminProvider adminProvider) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Form(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Add User',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).primaryColor,
              ),
            ),
            const SizedBox(height: 16),
            CustomTextField(
              label: 'Username',
              controller: _userNameController,
              validator: (value) =>
              value == null || value.isEmpty ? 'Required' : null,
            ),
            const SizedBox(height: 16),
            CustomTextField(
              label: 'Email',
              controller: _userEmailController,
              keyboardType: TextInputType.emailAddress,
              validator: (value) =>
              value == null || value.isEmpty ? 'Required' : null,
            ),
            const SizedBox(height: 16),
            CustomTextField(
              label: 'Password',
              controller: _userPasswordController,
              obscureText: true,
              validator: (value) =>
              value == null || value.isEmpty ? 'Required' : null,
            ),
            const SizedBox(height: 16),
            CustomTextField(
              label: 'Phone Number',
              controller: _userPhoneController,
              keyboardType: TextInputType.phone,
              validator: (value) =>
              value == null || value.isEmpty ? 'Required' : null,
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<int>(
              decoration: const InputDecoration(
                labelText: 'Select Organization',
              ),
              items: adminProvider.organizations
                  .map(
                    (org) => DropdownMenuItem<int>(
                  value: org.id,
                  child: Text(org.name),
                ),
              )
                  .toList(),
              onChanged: (value) {},
            ),
            const SizedBox(height: 16),
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

                // Simplified logic (just picking the first org)
                final orgList = adminProvider.organizations;
                if (orgList.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('No organizations available.'),
                      backgroundColor: Colors.red,
                    ),
                  );
                  return;
                }

                final selectedOrg = orgList.first;
                adminProvider.addUser(
                  username: _userNameController.text.trim(),
                  email: _userEmailController.text.trim(),
                  password: _userPasswordController.text.trim(),
                  phoneNumber: _userPhoneController.text.trim(),
                  roles: [], // keep your logic
                  organization: selectedOrg,
                );
                _userNameController.clear();
                _userEmailController.clear();
                _userPasswordController.clear();
                _userPhoneController.clear();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('User added successfully'),
                    backgroundColor: Colors.green,
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  // -----------------------------------------------
  // Tests Tab
  // -----------------------------------------------
  Widget _buildTestsTab(AdminProvider adminProvider) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          _buildAddTestCard(adminProvider),
          const SizedBox(height: 32),
          Wrap(
            spacing: 16,
            runSpacing: 16,
            children: adminProvider.tests.isEmpty
                ? [
              const Center(
                child: Text('No tests found.'),
              )
            ]
                : adminProvider.tests.map((test) {
              return ItemCard(
                title: test.name,
                subtitle: 'ID: ${test.id}',
                additionalInfo: [
                  'Code: ${test.code}',
                  'Grade: ${test.grade}',
                  'Duration: ${test.duration} minutes',
                  'Status: ${test.isActive ? "Active" : "Inactive"}',
                ],
                actions: [
                  CardAction(
                    label: 'Manage Qs',
                    icon: Icons.question_answer,
                    color: Colors.blue,
                    onPressed: () {
                      // keep your logic to navigate to ManageQuestions
                    },
                  ),
                  CardAction(
                    label: 'Edit',
                    icon: Icons.edit,
                    color: Colors.orange,
                    onPressed: () {
                      _showEditTestDialog(test, adminProvider);
                    },
                  ),
                  CardAction(
                    label: 'Delete',
                    icon: Icons.delete,
                    color: Colors.red,
                    onPressed: () {
                      _confirmDeletion(
                        title: 'Delete Test',
                        content:
                        'Are you sure you want to delete "${test.name}"?',
                        onConfirm: () {
                          adminProvider.deleteTest(test.id);
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Test deleted'),
                              backgroundColor: Colors.green,
                            ),
                          );
                        },
                      );
                    },
                  ),
                ],
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildAddTestCard(AdminProvider adminProvider) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Form(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Add Test',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).primaryColor,
              ),
            ),
            const SizedBox(height: 16),
            CustomTextField(
              label: 'Test Code',
              controller: _testCodeController,
              validator: (value) =>
              value == null || value.isEmpty ? 'Required' : null,
            ),
            const SizedBox(height: 16),
            CustomTextField(
              label: 'Test Name',
              controller: _testNameController,
              validator: (value) =>
              value == null || value.isEmpty ? 'Required' : null,
            ),
            const SizedBox(height: 16),
            CustomTextField(
              label: 'Grade',
              controller: _testGradeController,
              validator: (value) =>
              value == null || value.isEmpty ? 'Required' : null,
            ),
            const SizedBox(height: 16),
            CustomTextField(
              label: 'Duration (minutes)',
              controller: _testDurationController,
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || value.isEmpty) return 'Required';
                if (int.tryParse(value) == null) return 'Enter a valid number';
                return null;
              },
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<int>(
              decoration: const InputDecoration(
                labelText: 'Select Domain',
              ),
              items: adminProvider.testDomains
                  .map(
                    (domain) => DropdownMenuItem<int>(
                  value: domain.id,
                  child: Text(domain.name),
                ),
              )
                  .toList(),
              onChanged: (value) {},
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                const Text('Is Active', style: TextStyle(fontSize: 16)),
                const Spacer(),
                Switch(
                  value: true,
                  onChanged: (value) {
                    // Keep your logic if you wish to handle active state
                  },
                ),
              ],
            ),
            const SizedBox(height: 16),
            CustomButton(
              text: 'Add Test',
              icon: Icons.add_task,
              onPressed: () {
                if (_testCodeController.text.trim().isEmpty ||
                    _testNameController.text.trim().isEmpty ||
                    _testGradeController.text.trim().isEmpty ||
                    _testDurationController.text.trim().isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Please fill all fields'),
                      backgroundColor: Colors.red,
                    ),
                  );
                  return;
                }
                adminProvider.addTest(
                  code: _testCodeController.text.trim(),
                  name: _testNameController.text.trim(),
                  grade: _testGradeController.text.trim(),
                  date: DateTime.now(),
                  duration:
                  int.parse(_testDurationController.text.trim()),
                  isActive: true,
                  domainId: adminProvider.testDomains.isNotEmpty
                      ? adminProvider.testDomains.first.id
                      : 1,
                );
                _testCodeController.clear();
                _testNameController.clear();
                _testGradeController.clear();
                _testDurationController.clear();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Test added successfully'),
                    backgroundColor: Colors.green,
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  // -----------------------------------------------
  // Confirmation Dialog
  // -----------------------------------------------
  void _confirmDeletion({
    required String title,
    required String content,
    required VoidCallback onConfirm,
  }) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          content: Text(content),
          actions: [
            TextButton(
              child: const Text('Cancel'),
              onPressed: () => Navigator.pop(context),
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

  // -----------------------------------------------
  // Edit Organization Dialog
  // -----------------------------------------------
  void _showEditOrganizationDialog(org, AdminProvider adminProvider) {
    final TextEditingController _editNameController =
    TextEditingController(text: org.name);
    final TextEditingController _editDescController =
    TextEditingController(text: org.description);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text(
            'Edit Organization',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          content: SingleChildScrollView(
            child: Column(
              children: [
                CustomTextField(
                  label: 'Organization Name',
                  controller: _editNameController,
                ),
                const SizedBox(height: 16),
                CustomTextField(
                  label: 'Description',
                  controller: _editDescController,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              child: const Text('Cancel'),
              onPressed: () => Navigator.pop(context),
            ),
            ElevatedButton(
              child: const Text('Save'),
              onPressed: () {
                if (_editNameController.text.trim().isEmpty ||
                    _editDescController.text.trim().isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Please fill all fields'),
                      backgroundColor: Colors.red,
                    ),
                  );
                  return;
                }
                adminProvider.updateOrganization(
                  org.id,
                  _editNameController.text.trim(),
                  _editDescController.text.trim(),
                );
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Organization updated successfully'),
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

  // -----------------------------------------------
  // Edit User Dialog
  // -----------------------------------------------
  void _showEditUserDialog(user, AdminProvider adminProvider) {
    final TextEditingController _editNameController =
    TextEditingController(text: user.username);
    final TextEditingController _editEmailController =
    TextEditingController(text: user.email);
    final TextEditingController _editPhoneController =
    TextEditingController(text: user.phoneNumber ?? '');
    var selectedOrg = user.organization;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text(
            'Edit User',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          content: SingleChildScrollView(
            child: Column(
              children: [
                CustomTextField(
                  label: 'Username',
                  controller: _editNameController,
                ),
                const SizedBox(height: 16),
                CustomTextField(
                  label: 'Email',
                  controller: _editEmailController,
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 16),
                CustomTextField(
                  label: 'Phone Number',
                  controller: _editPhoneController,
                  keyboardType: TextInputType.phone,
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<int>(
                  decoration: const InputDecoration(
                    labelText: 'Select Organization',
                  ),
                  value: selectedOrg.id,
                  items: adminProvider.organizations
                      .map(
                        (org) => DropdownMenuItem<int>(
                      value: org.id,
                      child: Text(org.name),
                    ),
                  )
                      .toList(),
                  onChanged: (value) {
                    selectedOrg = adminProvider.organizations.firstWhere(
                          (o) => o.id == value,
                      orElse: () => user.organization,
                    );
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              child: const Text('Cancel'),
              onPressed: () => Navigator.pop(context),
            ),
            ElevatedButton(
              child: const Text('Save'),
              onPressed: () {
                if (_editNameController.text.trim().isEmpty ||
                    _editEmailController.text.trim().isEmpty ||
                    _editPhoneController.text.trim().isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Please fill all fields'),
                      backgroundColor: Colors.red,
                    ),
                  );
                  return;
                }
                adminProvider.updateUser(
                  id: user.id,
                  username: _editNameController.text.trim(),
                  email: _editEmailController.text.trim(),
                  phoneNumber: _editPhoneController.text.trim(),
                  roles: user.roles, // keep your roles logic
                  organization: selectedOrg,
                );
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('User updated successfully'),
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

  // -----------------------------------------------
  // Edit Test Dialog
  // -----------------------------------------------
  void _showEditTestDialog(test, AdminProvider adminProvider) {
    final TextEditingController _editCodeController =
    TextEditingController(text: test.code);
    final TextEditingController _editNameController =
    TextEditingController(text: test.name);
    final TextEditingController _editGradeController =
    TextEditingController(text: test.grade);
    final TextEditingController _editDurationController =
    TextEditingController(text: test.duration.toString());
    var selectedDomainId = test.domainId;
    bool isActive = test.isActive;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(builder: (context, setStateDialog) {
          return AlertDialog(
            title: const Text(
              'Edit Test',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            content: SingleChildScrollView(
              child: Column(
                children: [
                  CustomTextField(
                    label: 'Test Code',
                    controller: _editCodeController,
                  ),
                  const SizedBox(height: 16),
                  CustomTextField(
                    label: 'Test Name',
                    controller: _editNameController,
                  ),
                  const SizedBox(height: 16),
                  CustomTextField(
                    label: 'Grade',
                    controller: _editGradeController,
                  ),
                  const SizedBox(height: 16),
                  CustomTextField(
                    label: 'Duration (minutes)',
                    controller: _editDurationController,
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<int>(
                    decoration: const InputDecoration(
                      labelText: 'Select Domain',
                    ),
                    value: selectedDomainId,
                    items: adminProvider.testDomains
                        .map(
                          (domain) => DropdownMenuItem<int>(
                        value: domain.id,
                        child: Text(domain.name),
                      ),
                    )
                        .toList(),
                    onChanged: (value) {
                      setStateDialog(() {
                        selectedDomainId = value ?? test.domainId;
                      });
                    },
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      const Text('Is Active', style: TextStyle(fontSize: 16)),
                      const Spacer(),
                      Switch(
                        value: isActive,
                        onChanged: (value) {
                          setStateDialog(() {
                            isActive = value;
                          });
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                child: const Text('Cancel'),
                onPressed: () => Navigator.pop(context),
              ),
              ElevatedButton(
                child: const Text('Save'),
                onPressed: () {
                  if (_editCodeController.text.trim().isEmpty ||
                      _editNameController.text.trim().isEmpty ||
                      _editGradeController.text.trim().isEmpty ||
                      _editDurationController.text.trim().isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Please fill all fields'),
                        backgroundColor: Colors.red,
                      ),
                    );
                    return;
                  }

                  test.code = _editCodeController.text.trim();
                  test.name = _editNameController.text.trim();
                  test.grade = _editGradeController.text.trim();
                  test.duration = int.tryParse(
                    _editDurationController.text.trim(),
                  ) ??
                      0;
                  test.domainId = selectedDomainId;
                  test.isActive = isActive;

                  adminProvider.updateTest(test);
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Test updated successfully'),
                      backgroundColor: Colors.green,
                    ),
                  );
                },
              ),
            ],
          );
        });
      },
    );
  }
}
