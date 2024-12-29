// lib/screens/admin_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';

import '../providers/admin_provider.dart';
import '../providers/auth_provider.dart';
import '../utils/theme.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/custom_button.dart';
import '../widgets/persistent_navbar.dart';
import '../models/test_model.dart';
import 'manage_questions_screen.dart';

class AdminScreen extends StatefulWidget {
  const AdminScreen({Key? key}) : super(key: key);

  @override
  State<AdminScreen> createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen> {
  // Current tab in the navbar
  int _currentIndex = 0;

  // For Dashboard bar/pie charts data
  final List<BarChartGroupData> _barGroups = [
    BarChartGroupData(x: 0, barRods: [BarChartRodData(toY: 8, color: secondaryGreen)]),
    BarChartGroupData(x: 1, barRods: [BarChartRodData(toY: 12, color: accentColor)]),
    BarChartGroupData(x: 2, barRods: [BarChartRodData(toY: 5, color: Colors.orange)]),
    BarChartGroupData(x: 3, barRods: [BarChartRodData(toY: 9, color: primaryDarkGreen)]),
    BarChartGroupData(x: 4, barRods: [BarChartRodData(toY: 11, color: Colors.blueGrey)]),
  ];
  final List<PieChartSectionData> _pieSections = [
    PieChartSectionData(
      color: secondaryGreen, value: 35, title: '35%', radius: 36,
      titleStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
    ),
    PieChartSectionData(
      color: accentColor, value: 30, title: '30%', radius: 36,
      titleStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
    ),
    PieChartSectionData(
      color: Colors.orange, value: 20, title: '20%', radius: 36,
      titleStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
    ),
    PieChartSectionData(
      color: Colors.blueGrey, value: 15, title: '15%', radius: 36,
      titleStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
    ),
  ];

  // For Organizations, Users, Tests
  final TextEditingController _orgSearchController = TextEditingController();
  final TextEditingController _orgNameController = TextEditingController();
  final TextEditingController _orgDescController = TextEditingController();

  final TextEditingController _userSearchController = TextEditingController();
  final TextEditingController _userNameController = TextEditingController();
  final TextEditingController _userEmailController = TextEditingController();
  final TextEditingController _userPasswordController = TextEditingController();
  final TextEditingController _userPhoneController = TextEditingController();

  final TextEditingController _testSearchController = TextEditingController();
  final TextEditingController _testCodeController = TextEditingController();
  final TextEditingController _testNameController = TextEditingController();
  final TextEditingController _testGradeController = TextEditingController();
  final TextEditingController _testDurationController = TextEditingController();

  // Manage Questions inline state
  bool _showManageQuestions = false;
  TestModel? _selectedTestForQuestions;

  @override
  void dispose() {
    // Dispose
    _orgSearchController.dispose();
    _orgNameController.dispose();
    _orgDescController.dispose();

    _userSearchController.dispose();
    _userNameController.dispose();
    _userEmailController.dispose();
    _userPasswordController.dispose();
    _userPhoneController.dispose();

    _testSearchController.dispose();
    _testCodeController.dispose();
    _testNameController.dispose();
    _testGradeController.dispose();
    _testDurationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    return Scaffold(
      // Background or gradient if you want
      body: Row(
        children: [
          // Left persistent navbar
          PersistentNavbar(
            currentIndex: _currentIndex,
            onItemSelected: (index) {
              setState(() {
                _currentIndex = index;
                // If we leave the Tests tab, also close Manage Questions
                if (_currentIndex != 3) {
                  _showManageQuestions = false;
                  _selectedTestForQuestions = null;
                }
              });
            },
          ),

          // Main area
          Expanded(
            child: Column(
              children: [
                // Top bar
                Container(
                  height: 60,
                  color: Theme.of(context).primaryColor.withOpacity(0.1),
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [
                      Text(
                        'Admin Dashboard',
                        style: TextStyle(
                          color: Theme.of(context).primaryColor,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Spacer(),
                      IconButton(
                        icon: const Icon(Icons.logout),
                        color: Theme.of(context).primaryColor,
                        onPressed: () {
                          authProvider.logout();
                          Navigator.pushReplacementNamed(context, '/');
                        },
                        tooltip: 'Logout',
                      ),
                    ],
                  ),
                ),

                // Body: 4 tabs in an IndexedStack
                Expanded(
                  child: IndexedStack(
                    index: _currentIndex,
                    children: [
                      _buildDashboardTab(),          // 0 => Dashboard
                      _buildOrganizationsTab(),      // 1 => Orgs
                      _buildUsersTab(),              // 2 => Users
                      _buildTestsTab(),              // 3 => Tests
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ----------------------------------------------------------------------------
  // TAB 0: DASHBOARD
  // ----------------------------------------------------------------------------
  Widget _buildDashboardTab() {
    // We'll do a 2x2 approach: top row for a grid of stats, second row for bar + pie
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildDashboardHeader(),
          const SizedBox(height: 12),
          // 1) Stats grid (2x2)
          _buildStatsGrid(),
          const SizedBox(height: 12),
          // 2) 2 columns => bar chart + pie chart
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 3,
                child: _buildBarChartCard(),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 2,
                child: _buildPieChartCard(),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDashboardHeader() {
    return Row(
      children: [
        Text(
          'Dashboard Overview',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: primaryDarkGreen,
            fontSize: 18,
          ),
        ),
        const Spacer(),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: accentColor.withOpacity(0.95),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            children: const [
              CircleAvatar(
                radius: 14,
                backgroundColor: Colors.white,
                child: Icon(Icons.person, color: Colors.black54, size: 16),
              ),
              SizedBox(width: 6),
              Text('SuperAdmin', style: TextStyle(color: Colors.white, fontSize: 13)),
            ],
          ),
        ),
      ],
    );
  }

  // Example 4 stats in a 2x2
  Widget _buildStatsGrid() {
    final stats = [
      _StatData('Users', '1,232', Icons.people, Colors.green),
      _StatData('Active Tests', '27', Icons.assessment, Colors.blue),
      _StatData('Feedback', '99+', Icons.feedback, Colors.orange),
      _StatData('Revenue', '\$12,345', Icons.attach_money, Colors.red),
    ];
    return SizedBox(
      height: 120,
      child: GridView.builder(
        physics: const NeverScrollableScrollPhysics(),
        itemCount: stats.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2, // 2 columns
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 2.6,
        ),
        itemBuilder: (ctx, i) {
          final e = stats[i];
          return Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Color(0xFFE8ECD7),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black12.withOpacity(0.05),
                  blurRadius: 6,
                  offset: const Offset(0, 3),
                )
              ],
            ),
            child: Row(
              children: [
                Icon(e.icon, size: 26, color: e.color),
                const SizedBox(width: 8),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      e.title,
                      style: TextStyle(fontSize: 13, color: Colors.grey[800]),
                    ),
                    Text(
                      e.value,
                      style: TextStyle(fontSize: 16, color: e.color, fontWeight: FontWeight.bold),
                    ),
                  ],
                )
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildBarChartCard() {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        padding: const EdgeInsets.all(12),
        height: 300,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Bar Chart', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Expanded(
              child: BarChart(
                BarChartData(
                  barGroups: _barGroups,
                  borderData: FlBorderData(show: false),
                  titlesData: FlTitlesData(
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: true, reservedSize: 28),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (val, meta) {
                          final names = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri'];
                          if (val >= 0 && val < names.length) {
                            return Text(names[val.toInt()]);
                          }
                          return const SizedBox.shrink();
                        },
                      ),
                    ),
                  ),
                  gridData: FlGridData(show: true),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPieChartCard() {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        padding: const EdgeInsets.all(12),
        height: 300,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Pie Chart', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Expanded(
              child: PieChart(
                PieChartData(
                  sections: _pieSections,
                  centerSpaceRadius: 30,
                  borderData: FlBorderData(show: false),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ----------------------------------------------------------------------------
  // TAB 1: ORGANIZATIONS
  // ----------------------------------------------------------------------------
  Widget _buildOrganizationsTab() {
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
                // search
                Row(
                  children: [
                    Expanded(
                      child: CustomTextField(
                        label: 'Search Organizations...',
                        controller: _orgSearchController,
                        onChanged: (_) => setState(() {}),
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      icon: const Icon(Icons.search),
                      onPressed: () => setState(() {}),
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
                              style: const TextStyle(fontWeight: FontWeight.bold)),
                          subtitle: Text('Description: ${org.description}'),
                          trailing: SizedBox(
                            width: 100,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.edit, color: Colors.orange),
                                  onPressed: () {
                                    _showEditOrganizationDialog(org, adminProvider);
                                  },
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete, color: Colors.red),
                                  onPressed: () {
                                    _confirmDeletion(
                                      title: 'Delete Organization',
                                      content:
                                      'Are you sure you want to delete "${org.name}"?',
                                      onConfirm: () {
                                        adminProvider.deleteOrganization(org.id);
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
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Text('Add Organization',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: Theme.of(context).primaryColor,
                        )),
                    const SizedBox(height: 12),
                    CustomTextField(
                      label: 'Organization Name',
                      controller: _orgNameController,
                    ),
                    const SizedBox(height: 12),
                    CustomTextField(
                      label: 'Description',
                      controller: _orgDescController,
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
                          const SnackBar(content: Text('Organization added'), backgroundColor: Colors.green),
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

  // ----------------------------------------------------------------------------
  // TAB 2: USERS
  // ----------------------------------------------------------------------------
  Widget _buildUsersTab() {
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
                // search
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
                          title: Text(user.username,
                              style: const TextStyle(fontWeight: FontWeight.bold)),
                          subtitle: Text(
                            'Email: ${user.email}\nPhone: ${user.phoneNumber ?? 'N/A'}',
                          ),
                          isThreeLine: true,
                          trailing: SizedBox(
                            width: 100,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.edit, color: Colors.orange),
                                  onPressed: () {
                                    _showEditUserDialog(user, adminProvider);
                                  },
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete, color: Colors.red),
                                  onPressed: () {
                                    _confirmDeletion(
                                      title: 'Delete User',
                                      content: 'Delete "${user.username}"?',
                                      onConfirm: () {
                                        adminProvider.deleteUser(user.id);
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
                )
              ],
            ),
          ),
        ),
        // add user form
        Container(
          width: 300,
          padding: const EdgeInsets.all(16),
          child: SingleChildScrollView(
            child: Card(
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Text('Add User',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: Theme.of(context).primaryColor,
                        )),
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
                      decoration: const InputDecoration(labelText: 'Select Organization'),
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
                              content: Text('No org available.'),
                              backgroundColor: Colors.red,
                            ),
                          );
                          return;
                        }
                        final selectedOrg = adminProvider.organizations.first;
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
                          const SnackBar(content: Text('User added'), backgroundColor: Colors.green),
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

  // ----------------------------------------------------------------------------
  // TAB 3 => TESTS + Manage Questions inline
  // ----------------------------------------------------------------------------
  Widget _buildTestsTab() {
    if (_showManageQuestions && _selectedTestForQuestions != null) {
      // Show inline ManageQuestionsWidget
      return Padding(
        padding: const EdgeInsets.all(16.0),
        child: ManageQuestionsWidget(
          test: _selectedTestForQuestions!,
          onBack: () {
            setState(() {
              _showManageQuestions = false;
              _selectedTestForQuestions = null;
            });
          },
        ),
      );
    }

    final adminProvider = Provider.of<AdminProvider>(context);
    final filtered = adminProvider.tests.where((t) {
      final query = _testSearchController.text.trim().toLowerCase();
      return t.name.toLowerCase().contains(query) ||
          t.code.toLowerCase().contains(query) ||
          t.grade.toLowerCase().contains(query);
    }).toList();

    return Row(
      children: [
        Expanded(
          flex: 3,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // search
                Row(
                  children: [
                    Expanded(
                      child: CustomTextField(
                        label: 'Search Tests...',
                        controller: _testSearchController,
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

                filtered.isEmpty
                    ? const Center(child: Text('No tests found.'))
                    : Expanded(
                  child: ListView.builder(
                    itemCount: filtered.length,
                    itemBuilder: (ctx, i) {
                      final t = filtered[i];
                      return Card(
                        margin: const EdgeInsets.symmetric(vertical: 8),
                        child: ListTile(
                          title: Text(
                            '${t.name} (Code: ${t.code})',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text(
                            'Grade: ${t.grade}\n'
                                'Duration: ${t.duration} mins\n'
                                'Status: ${t.isActive ? "Active" : "Inactive"}',
                          ),
                          isThreeLine: true,
                          trailing: SizedBox(
                            width: 170,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.question_answer, color: Colors.blue),
                                  tooltip: 'Manage Questions',
                                  onPressed: () {
                                    // Show inline Manage Questions
                                    setState(() {
                                      _showManageQuestions = true;
                                      _selectedTestForQuestions = t;
                                    });
                                  },
                                ),
                                IconButton(
                                  icon: const Icon(Icons.edit, color: Colors.orange),
                                  onPressed: () {
                                    _showEditTestDialog(t, adminProvider);
                                  },
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete, color: Colors.red),
                                  onPressed: () {
                                    _confirmDeletion(
                                      title: 'Delete Test',
                                      content: 'Delete "${t.name}"?',
                                      onConfirm: () {
                                        adminProvider.deleteTest(t.id);
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
                )
              ],
            ),
          ),
        ),
        // Add Test form
        Container(
          width: 300,
          padding: const EdgeInsets.all(16),
          child: SingleChildScrollView(
            child: Card(
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Text('Add Test',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: Theme.of(context).primaryColor,
                        )),
                    const SizedBox(height: 12),
                    CustomTextField(
                      label: 'Test Code',
                      controller: _testCodeController,
                    ),
                    const SizedBox(height: 12),
                    CustomTextField(
                      label: 'Test Name',
                      controller: _testNameController,
                    ),
                    const SizedBox(height: 12),
                    CustomTextField(
                      label: 'Grade',
                      controller: _testGradeController,
                    ),
                    const SizedBox(height: 12),
                    CustomTextField(
                      label: 'Duration (minutes)',
                      controller: _testDurationController,
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<int>(
                      decoration: const InputDecoration(labelText: 'Select Domain'),
                      items: adminProvider.testDomains
                          .map(
                            (dom) => DropdownMenuItem<int>(
                          value: dom.id,
                          child: Text(dom.name),
                        ),
                      )
                          .toList(),
                      onChanged: (value) {},
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        const Text('Is Active'),
                        const Spacer(),
                        Switch(
                          value: true,
                          onChanged: (val) {},
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
                          duration: int.parse(_testDurationController.text.trim()),
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
                              content: Text('Test added'), backgroundColor: Colors.green),
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
  // REUSABLE CRUD HELPERS
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
          title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
          content: Text(content),
          actions: [
            TextButton(
              child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
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

  void _showEditOrganizationDialog(org, adminProvider) {
    final TextEditingController _editNameController =
    TextEditingController(text: org.name);
    final TextEditingController _editDescController =
    TextEditingController(text: org.description);

    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Text('Edit Organization', style: TextStyle(fontWeight: FontWeight.bold)),
          content: SingleChildScrollView(
            child: Column(
              children: [
                CustomTextField(label: 'Organization Name', controller: _editNameController),
                const SizedBox(height: 12),
                CustomTextField(label: 'Description', controller: _editDescController),
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
                if (_editNameController.text.trim().isEmpty ||
                    _editDescController.text.trim().isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Fill all fields'), backgroundColor: Colors.red),
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
                  const SnackBar(content: Text('Updated'), backgroundColor: Colors.green),
                );
              },
            )
          ],
        );
      },
    );
  }

  void _showEditUserDialog(user, adminProvider) {
    final _editNameController = TextEditingController(text: user.username);
    final _editEmailController = TextEditingController(text: user.email);
    final _editPhoneController = TextEditingController(text: user.phoneNumber ?? '');
    var selectedOrg = user.organization;

    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Text('Edit User', style: TextStyle(fontWeight: FontWeight.bold)),
          content: SingleChildScrollView(
            child: Column(
              children: [
                CustomTextField(label: 'Username', controller: _editNameController),
                const SizedBox(height: 12),
                CustomTextField(label: 'Email', controller: _editEmailController),
                const SizedBox(height: 12),
                CustomTextField(label: 'Phone Number', controller: _editPhoneController),
                const SizedBox(height: 12),
                DropdownButtonFormField<int>(
                  decoration: const InputDecoration(labelText: 'Select Organization'),
                  value: selectedOrg.id,
                  items: adminProvider.organizations
                      .map(
                        (o) => DropdownMenuItem<int>(
                      value: o.id,
                      child: Text(o.name),
                    ),
                  )
                      .toList(),
                  onChanged: (val) {
                    selectedOrg = adminProvider.organizations.firstWhere(
                          (x) => x.id == val,
                      orElse: () => user.organization,
                    );
                  },
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
                if (_editNameController.text.trim().isEmpty ||
                    _editEmailController.text.trim().isEmpty ||
                    _editPhoneController.text.trim().isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Fill all fields'), backgroundColor: Colors.red),
                  );
                  return;
                }
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
                  const SnackBar(content: Text('User updated'), backgroundColor: Colors.green),
                );
              },
            )
          ],
        );
      },
    );
  }

  void _showEditTestDialog(test, adminProvider) {
    final _editCodeController = TextEditingController(text: test.code);
    final _editNameController = TextEditingController(text: test.name);
    final _editGradeController = TextEditingController(text: test.grade);
    final _editDurationController = TextEditingController(text: test.duration.toString());
    var selectedDomainId = test.domainId;
    bool isActive = test.isActive;

    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (dialogCtx, setStateDialog) {
            return AlertDialog(
              title: const Text('Edit Test', style: TextStyle(fontWeight: FontWeight.bold)),
              content: SingleChildScrollView(
                child: Column(
                  children: [
                    CustomTextField(label: 'Test Code', controller: _editCodeController),
                    const SizedBox(height: 12),
                    CustomTextField(label: 'Test Name', controller: _editNameController),
                    const SizedBox(height: 12),
                    CustomTextField(label: 'Grade', controller: _editGradeController),
                    const SizedBox(height: 12),
                    CustomTextField(
                      label: 'Duration (minutes)',
                      controller: _editDurationController,
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<int>(
                      decoration: const InputDecoration(labelText: 'Select Domain'),
                      value: selectedDomainId,
                      items: adminProvider.testDomains
                          .map(
                            (dom) => DropdownMenuItem<int>(
                          value: dom.id,
                          child: Text(dom.name),
                        ),
                      )
                          .toList(),
                      onChanged: (val) {
                        setStateDialog(() {
                          selectedDomainId = val ?? test.domainId;
                        });
                      },
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        const Text('Is Active'),
                        const Spacer(),
                        Switch(
                          value: isActive,
                          onChanged: (sw) {
                            setStateDialog(() {
                              isActive = sw;
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
                  child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
                  onPressed: () => Navigator.pop(ctx),
                ),
                ElevatedButton(
                  child: const Text('Save'),
                  onPressed: () {
                    if (_editCodeController.text.trim().isEmpty ||
                        _editNameController.text.trim().isEmpty ||
                        _editGradeController.text.trim().isEmpty ||
                        _editDurationController.text.trim().isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Fill all fields'), backgroundColor: Colors.red),
                      );
                      return;
                    }
                    test.code = _editCodeController.text.trim();
                    test.name = _editNameController.text.trim();
                    test.grade = _editGradeController.text.trim();
                    test.duration = int.tryParse(_editDurationController.text.trim()) ?? 0;
                    test.domainId = selectedDomainId;
                    test.isActive = isActive;

                    adminProvider.updateTest(test);
                    Navigator.pop(ctx);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Test updated'), backgroundColor: Colors.green),
                    );
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }
}

// For the dashboard stats
class _StatData {
  final String title;
  final String value;
  final IconData icon;
  final Color color;
  _StatData(this.title, this.value, this.icon, this.color);
}
