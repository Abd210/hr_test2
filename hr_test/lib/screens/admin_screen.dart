// lib/screens/admin_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/role.dart';
import '../providers/admin_provider.dart';
import '../providers/auth_provider.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_text_field.dart';
import '../models/organization.dart';
import '../models/user.dart';
import '../models/test_model.dart';
import '../utils/constants.dart';
import 'manage_questions_screen.dart';

class AdminScreen extends StatefulWidget {
  const AdminScreen({Key? key}) : super(key: key);

  @override
  State<AdminScreen> createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // Controllers for adding organization
  final TextEditingController _orgNameController = TextEditingController();
  final TextEditingController _orgDescController = TextEditingController();

  // Controllers for adding user
  final TextEditingController _userNameController = TextEditingController();
  final TextEditingController _userEmailController = TextEditingController();
  final TextEditingController _userPasswordController = TextEditingController();
  final TextEditingController _userPhoneController = TextEditingController();

  // Controllers for adding test
  final TextEditingController _testCodeController = TextEditingController();
  final TextEditingController _testNameController = TextEditingController();
  final TextEditingController _testGradeController = TextEditingController();
  final TextEditingController _testDurationController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
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

    return Scaffold(
      appBar: AppBar(
        title: Text('SuperAdmin Dashboard'),
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(text: 'Organizations'),
            Tab(text: 'Users'),
            Tab(text: 'Tests'),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            tooltip: 'Logout',
            onPressed: () {
              authProvider.logout();
              Navigator.pushReplacementNamed(context, '/');
            },
          ),
        ],
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Organizations Tab
          _buildOrganizationsTab(adminProvider),
          // Users Tab
          _buildUsersTab(adminProvider),
          // Tests Tab
          _buildTestsTab(adminProvider),
        ],
      ),
    );
  }

  /// Builds the Organizations management tab.
  Widget _buildOrganizationsTab(AdminProvider adminProvider) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          // Add Organization Form
          Card(
            elevation: 4,
            shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'Add Organization',
                      style:
                      TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 16),
                    CustomTextField(
                      label: 'Organization Name',
                      controller: _orgNameController,
                      validator: (value) =>
                      value!.isEmpty ? 'Please enter organization name' : null,
                    ),
                    SizedBox(height: 16),
                    CustomTextField(
                      label: 'Description',
                      controller: _orgDescController,
                      validator: (value) =>
                      value!.isEmpty ? 'Please enter description' : null,
                    ),
                    SizedBox(height: 16),
                    CustomButton(
                      text: 'Add Organization',
                      icon: Icons.add,
                      onPressed: () {
                        if (_orgNameController.text.trim().isEmpty ||
                            _orgDescController.text.trim().isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
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
                          SnackBar(
                            content: Text('Organization added successfully'),
                            backgroundColor: Colors.green,
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
          SizedBox(height: 24),
          // List of Organizations
          Expanded(
            child: adminProvider.organizations.isEmpty
                ? Center(child: Text('No organizations found.'))
                : SingleChildScrollView(
              scrollDirection: Axis.vertical,
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: DataTable(
                  columns: [
                    DataColumn(label: Text('ID')),
                    DataColumn(label: Text('Name')),
                    DataColumn(label: Text('Description')),
                    DataColumn(label: Text('Created At')),
                    DataColumn(label: Text('Actions')),
                  ],
                  rows: adminProvider.organizations
                      .map(
                        (org) => DataRow(cells: [
                      DataCell(Text(org.id.toString())),
                      DataCell(Text(org.name)),
                      DataCell(Text(org.description)),
                      DataCell(Text(
                          '${org.createdAt.day}/${org.createdAt.month}/${org.createdAt.year}')),
                      DataCell(Row(
                        children: [
                          IconButton(
                            icon: Icon(Icons.edit, color: Colors.orange),
                            tooltip: 'Edit',
                            onPressed: () {
                              _showEditOrganizationDialog(org, adminProvider);
                            },
                          ),
                          IconButton(
                            icon: Icon(Icons.delete, color: Colors.red),
                            tooltip: 'Delete',
                            onPressed: () {
                              _confirmDeletion(
                                context,
                                'Delete Organization',
                                'Are you sure you want to delete "${org.name}"?',
                                    () {
                                  adminProvider.deleteOrganization(org.id);
                                  Navigator.pop(context);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text('Organization deleted'),
                                      backgroundColor: Colors.green,
                                    ),
                                  );
                                },
                              );
                            },
                          ),
                        ],
                      )),
                    ]),
                  )
                      .toList(),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Builds the Users management tab.
  Widget _buildUsersTab(AdminProvider adminProvider) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          // Add User Form
          Card(
            elevation: 4,
            shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'Add User',
                      style:
                      TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 16),
                    CustomTextField(
                      label: 'Username',
                      controller: _userNameController,
                      validator: (value) =>
                      value!.isEmpty ? 'Please enter username' : null,
                    ),
                    SizedBox(height: 16),
                    CustomTextField(
                      label: 'Email',
                      controller: _userEmailController,
                      keyboardType: TextInputType.emailAddress,
                      validator: (value) =>
                      value!.isEmpty ? 'Please enter email' : null,
                    ),
                    SizedBox(height: 16),
                    CustomTextField(
                      label: 'Password',
                      controller: _userPasswordController,
                      obscureText: true,
                      validator: (value) =>
                      value!.isEmpty ? 'Please enter password' : null,
                    ),
                    SizedBox(height: 16),
                    CustomTextField(
                      label: 'Phone Number',
                      controller: _userPhoneController,
                      keyboardType: TextInputType.phone,
                      validator: (value) =>
                      value!.isEmpty ? 'Please enter phone number' : null,
                    ),
                    SizedBox(height: 16),
                    // Organization Selection
                    DropdownButtonFormField<Organization>(
                      decoration: InputDecoration(
                        labelText: 'Select Organization',
                      ),
                      items: adminProvider.organizations
                          .map(
                            (org) => DropdownMenuItem<Organization>(
                          value: org,
                          child: Text(org.name),
                        ),
                      )
                          .toList(),
                      onChanged: (value) {},
                      validator: (value) =>
                      value == null ? 'Please select an organization' : null,
                    ),
                    SizedBox(height: 16),
                    // Role Selection
                    // For simplicity, assigning 'User' role to all new users
                    // You can enhance this by allowing role selection
                    CustomButton(
                      text: 'Add User',
                      icon: Icons.person_add,
                      onPressed: () {
                        if (_userNameController.text.trim().isEmpty ||
                            _userEmailController.text.trim().isEmpty ||
                            _userPasswordController.text.trim().isEmpty ||
                            _userPhoneController.text.trim().isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Please fill all fields'),
                              backgroundColor: Colors.red,
                            ),
                          );
                          return;
                        }

                        // Fetch selected organization from the dropdown
                        // Implement proper selection logic
                        Organization? selectedOrganization;
                        // For this example, assume the first organization is selected
                        selectedOrganization = adminProvider.organizations.isNotEmpty
                            ? adminProvider.organizations.first
                            : null;

                        if (selectedOrganization == null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('No organizations available.'),
                              backgroundColor: Colors.red,
                            ),
                          );
                          return;
                        }

                        adminProvider.addUser(
                          username: _userNameController.text.trim(),
                          email: _userEmailController.text.trim(),
                          password: _userPasswordController.text.trim(),
                          phoneNumber: _userPhoneController.text.trim(),
                          roles: [
                            Role(
                              id: 3,
                              roleName: 'User',
                              description: 'Regular employee',
                            ),
                          ],
                          organization: selectedOrganization,
                        );
                        _userNameController.clear();
                        _userEmailController.clear();
                        _userPasswordController.clear();
                        _userPhoneController.clear();
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('User added successfully'),
                            backgroundColor: Colors.green,
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
          SizedBox(height: 24),
          // List of Users
          Expanded(
            child: adminProvider.users.isEmpty
                ? Center(child: Text('No users found.'))
                : SingleChildScrollView(
              scrollDirection: Axis.vertical,
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: DataTable(
                  columns: [
                    DataColumn(label: Text('ID')),
                    DataColumn(label: Text('Username')),
                    DataColumn(label: Text('Email')),
                    DataColumn(label: Text('Phone')),
                    DataColumn(label: Text('Organization')),
                    DataColumn(label: Text('Roles')),
                    DataColumn(label: Text('Actions')),
                  ],
                  rows: adminProvider.users
                      .map(
                        (user) => DataRow(cells: [
                      DataCell(Text(user.id.toString())),
                      DataCell(Text(user.username)),
                      DataCell(Text(user.email)),
                      DataCell(Text(user.phoneNumber ?? 'N/A')),
                      DataCell(Text(user.organization.name)),
                      DataCell(Text(
                          user.roles.map((role) => role.roleName).join(', '))),
                      DataCell(Row(
                        children: [
                          IconButton(
                            icon: Icon(Icons.edit, color: Colors.orange),
                            tooltip: 'Edit',
                            onPressed: () {
                              _showEditUserDialog(user, adminProvider);
                            },
                          ),
                          IconButton(
                            icon: Icon(Icons.delete, color: Colors.red),
                            tooltip: 'Delete',
                            onPressed: () {
                              _confirmDeletion(
                                context,
                                'Delete User',
                                'Are you sure you want to delete "${user.username}"?',
                                    () {
                                  adminProvider.deleteUser(user.id);
                                  Navigator.pop(context);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text('User deleted'),
                                      backgroundColor: Colors.green,
                                    ),
                                  );
                                },
                              );
                            },
                          ),
                        ],
                      )),
                    ]),
                  )
                      .toList(),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Builds the Tests management tab.
  Widget _buildTestsTab(AdminProvider adminProvider) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          // Add Test Form
          Card(
            elevation: 4,
            shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'Add Test',
                      style:
                      TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 16),
                    CustomTextField(
                      label: 'Test Code',
                      controller: _testCodeController,
                      validator: (value) =>
                      value!.isEmpty ? 'Please enter test code' : null,
                    ),
                    SizedBox(height: 16),
                    CustomTextField(
                      label: 'Test Name',
                      controller: _testNameController,
                      validator: (value) =>
                      value!.isEmpty ? 'Please enter test name' : null,
                    ),
                    SizedBox(height: 16),
                    CustomTextField(
                      label: 'Grade',
                      controller: _testGradeController,
                      validator: (value) =>
                      value!.isEmpty ? 'Please enter grade' : null,
                    ),
                    SizedBox(height: 16),
                    CustomTextField(
                      label: 'Duration (minutes)',
                      controller: _testDurationController,
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value!.isEmpty) return 'Please enter duration';
                        if (int.tryParse(value) == null)
                          return 'Please enter a valid number';
                        return null;
                      },
                    ),
                    SizedBox(height: 16),
                    // Domain Selection
                    DropdownButtonFormField<int>(
                      decoration: InputDecoration(
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
                      onChanged: (value) {
                        // No action needed; value can be captured if implementing state
                      },
                      validator: (value) =>
                      value == null ? 'Please select a domain' : null,
                    ),
                    SizedBox(height: 16),
                    // Active Switch
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Is Active',
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.w500)),
                        Switch(
                          value: true,
                          onChanged: (value) {
                            // Implement state management if needed
                          },
                        ),
                      ],
                    ),
                    SizedBox(height: 16),
                    CustomButton(
                      text: 'Add Test',
                      icon: Icons.add_task,
                      onPressed: () {
                        if (_testCodeController.text.trim().isEmpty ||
                            _testNameController.text.trim().isEmpty ||
                            _testGradeController.text.trim().isEmpty ||
                            _testDurationController.text.trim().isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Please fill all fields'),
                              backgroundColor: Colors.red,
                            ),
                          );
                          return;
                        }

                        // For simplicity, setting isActive to true and assigning first domain
                        adminProvider.addTest(
                          code: _testCodeController.text.trim(),
                          name: _testNameController.text.trim(),
                          grade: _testGradeController.text.trim(),
                          date: DateTime.now(),
                          duration: int.parse(_testDurationController.text.trim()),
                          isActive: true,
                          domainId: adminProvider.testDomains.isNotEmpty
                              ? adminProvider.testDomains[0].id
                              : 1, // Assign based on availability
                        );
                        _testCodeController.clear();
                        _testNameController.clear();
                        _testGradeController.clear();
                        _testDurationController.clear();
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Test added successfully'),
                            backgroundColor: Colors.green,
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
          SizedBox(height: 24),
          // List of Tests
          Expanded(
            child: adminProvider.tests.isEmpty
                ? Center(child: Text('No tests found.'))
                : SingleChildScrollView(
              scrollDirection: Axis.vertical,
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: DataTable(
                  columns: [
                    DataColumn(label: Text('ID')),
                    DataColumn(label: Text('Code')),
                    DataColumn(label: Text('Name')),
                    DataColumn(label: Text('Grade')),
                    DataColumn(label: Text('Duration')),
                    DataColumn(label: Text('Status')),
                    DataColumn(label: Text('Actions')),
                  ],
                  rows: adminProvider.tests
                      .map(
                        (test) => DataRow(cells: [
                      DataCell(Text(test.id.toString())),
                      DataCell(Text(test.code)),
                      DataCell(Text(test.name)),
                      DataCell(Text(test.grade)),
                      DataCell(Text('${test.duration} mins')),
                      DataCell(Text(
                          test.isActive ? 'Active' : 'Inactive')),
                      DataCell(Row(
                        children: [
                          IconButton(
                            icon:
                            Icon(Icons.question_answer, color: Colors.blue),
                            tooltip: 'Manage Questions',
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      ManageQuestionsScreen(test: test),
                                ),
                              );
                            },
                          ),
                          IconButton(
                            icon: Icon(Icons.edit, color: Colors.orange),
                            tooltip: 'Edit',
                            onPressed: () {
                              _showEditTestDialog(test, adminProvider);
                            },
                          ),
                          IconButton(
                            icon: Icon(Icons.delete, color: Colors.red),
                            tooltip: 'Delete',
                            onPressed: () {
                              _confirmDeletion(
                                context,
                                'Delete Test',
                                'Are you sure you want to delete "${test.name}"?',
                                    () {
                                  adminProvider.deleteTest(test.id);
                                  Navigator.pop(context);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text('Test deleted'),
                                      backgroundColor: Colors.green,
                                    ),
                                  );
                                },
                              );
                            },
                          ),
                        ],
                      )),
                    ]),
                  )
                      .toList(),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Confirmation Dialog
  void _confirmDeletion(BuildContext context, String title, String content,
      VoidCallback onConfirm) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(title,
              style: TextStyle(fontWeight: FontWeight.bold)),
          content: Text(content),
          actions: [
            TextButton(
              child: Text('Cancel',
                  style: TextStyle(color: Colors.grey)),
              onPressed: () => Navigator.pop(context),
            ),
            ElevatedButton(
              child: Text('Delete'),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              onPressed: onConfirm,
            ),
          ],
        );
      },
    );
  }

  /// Edit Organization Dialog
  void _showEditOrganizationDialog(
      Organization org, AdminProvider adminProvider) {
    final TextEditingController _editNameController =
    TextEditingController(text: org.name);
    final TextEditingController _editDescController =
    TextEditingController(text: org.description);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Edit Organization",
              style: TextStyle(fontWeight: FontWeight.bold)),
          content: SingleChildScrollView(
            child: Column(
              children: [
                CustomTextField(
                  label: 'Organization Name',
                  controller: _editNameController,
                  validator: (value) =>
                  value!.isEmpty ? 'Please enter organization name' : null,
                ),
                SizedBox(height: 16),
                CustomTextField(
                  label: 'Description',
                  controller: _editDescController,
                  validator: (value) =>
                  value!.isEmpty ? 'Please enter description' : null,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              child: Text("Cancel",
                  style: TextStyle(color: Colors.grey)),
              onPressed: () => Navigator.pop(context),
            ),
            ElevatedButton(
              child: Text("Save"),
              onPressed: () {
                if (_editNameController.text.trim().isEmpty ||
                    _editDescController.text.trim().isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
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
                  SnackBar(
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

  /// Edit User Dialog
  void _showEditUserDialog(User user, AdminProvider adminProvider) {
    final TextEditingController _editNameController =
    TextEditingController(text: user.username);
    final TextEditingController _editEmailController =
    TextEditingController(text: user.email);
    final TextEditingController _editPhoneController =
    TextEditingController(text: user.phoneNumber ?? '');

    Organization? selectedOrg = user.organization;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Edit User",
              style: TextStyle(fontWeight: FontWeight.bold)),
          content: SingleChildScrollView(
            child: Column(
              children: [
                CustomTextField(
                  label: 'Username',
                  controller: _editNameController,
                  validator: (value) =>
                  value!.isEmpty ? 'Please enter username' : null,
                ),
                SizedBox(height: 16),
                CustomTextField(
                  label: 'Email',
                  controller: _editEmailController,
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) =>
                  value!.isEmpty ? 'Please enter email' : null,
                ),
                SizedBox(height: 16),
                CustomTextField(
                  label: 'Phone Number',
                  controller: _editPhoneController,
                  keyboardType: TextInputType.phone,
                  validator: (value) =>
                  value!.isEmpty ? 'Please enter phone number' : null,
                ),
                SizedBox(height: 16),
                DropdownButtonFormField<Organization>(
                  decoration: InputDecoration(
                    labelText: 'Select Organization',
                  ),
                  value: selectedOrg,
                  items: adminProvider.organizations
                      .map(
                        (org) => DropdownMenuItem<Organization>(
                      value: org,
                      child: Text(org.name),
                    ),
                  )
                      .toList(),
                  onChanged: (value) {
                    selectedOrg = value;
                  },
                  validator: (value) =>
                  value == null ? 'Please select an organization' : null,
                ),
                SizedBox(height: 16),
                // Role Selection can be added here
                // For simplicity, roles are not being edited
              ],
            ),
          ),
          actions: [
            TextButton(
              child: Text("Cancel",
                  style: TextStyle(color: Colors.grey)),
              onPressed: () => Navigator.pop(context),
            ),
            ElevatedButton(
              child: Text("Save"),
              onPressed: () {
                if (_editNameController.text.trim().isEmpty ||
                    _editEmailController.text.trim().isEmpty ||
                    _editPhoneController.text.trim().isEmpty ||
                    selectedOrg == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
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
                  roles: user.roles, // Update roles if needed
                  organization: selectedOrg!,
                );

                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
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

  /// Edit Test Dialog
  void _showEditTestDialog(TestModel test, AdminProvider adminProvider) {
    final TextEditingController _editCodeController =
    TextEditingController(text: test.code);
    final TextEditingController _editNameController =
    TextEditingController(text: test.name);
    final TextEditingController _editGradeController =
    TextEditingController(text: test.grade);
    final TextEditingController _editDurationController =
    TextEditingController(text: test.duration.toString());
    int? selectedDomainId = test.domainId;
    bool isActive = test.isActive;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Edit Test",
              style: TextStyle(fontWeight: FontWeight.bold)),
          content: SingleChildScrollView(
            child: Column(
              children: [
                CustomTextField(
                  label: 'Test Code',
                  controller: _editCodeController,
                  validator: (value) =>
                  value!.isEmpty ? 'Please enter test code' : null,
                ),
                SizedBox(height: 16),
                CustomTextField(
                  label: 'Test Name',
                  controller: _editNameController,
                  validator: (value) =>
                  value!.isEmpty ? 'Please enter test name' : null,
                ),
                SizedBox(height: 16),
                CustomTextField(
                  label: 'Grade',
                  controller: _editGradeController,
                  validator: (value) =>
                  value!.isEmpty ? 'Please enter grade' : null,
                ),
                SizedBox(height: 16),
                CustomTextField(
                  label: 'Duration (minutes)',
                  controller: _editDurationController,
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value!.isEmpty) return 'Please enter duration';
                    if (int.tryParse(value) == null)
                      return 'Please enter a valid number';
                    return null;
                  },
                ),
                SizedBox(height: 16),
                DropdownButtonFormField<int>(
                  decoration: InputDecoration(
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
                    selectedDomainId = value;
                  },
                  validator: (value) =>
                  value == null ? 'Please select a domain' : null,
                ),
                SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Is Active',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w500)),
                    Switch(
                      value: isActive,
                      onChanged: (value) {
                        setState(() {
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
              child: Text("Cancel",
                  style: TextStyle(color: Colors.grey)),
              onPressed: () => Navigator.pop(context),
            ),
            ElevatedButton(
              child: Text("Save"),
              onPressed: () {
                if (_editCodeController.text.trim().isEmpty ||
                    _editNameController.text.trim().isEmpty ||
                    _editGradeController.text.trim().isEmpty ||
                    _editDurationController.text.trim().isEmpty ||
                    selectedDomainId == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Please fill all fields'),
                      backgroundColor: Colors.red,
                    ),
                  );
                  return;
                }

                final updatedTest = TestModel(
                  id: test.id,
                  code: _editCodeController.text.trim(),
                  name: _editNameController.text.trim(),
                  grade: _editGradeController.text.trim(),
                  date: test.date,
                  duration: int.parse(_editDurationController.text.trim()),
                  isActive: isActive,
                  createdAt: test.createdAt,
                  domainId: selectedDomainId!,
                );

                adminProvider.updateTest(updatedTest);
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Test updated successfully'),
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
