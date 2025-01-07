import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../models/test_domain.dart';
import '../../../../providers/admin_provider.dart';
import '../../../../providers/auth_provider.dart';
import '../../../../widgets/admin_assign_tests_dialog.dart';
import '../../../../widgets/custom_button.dart';
import '../../../../widgets/custom_text_field.dart';


class DomainTabAdmin extends StatefulWidget {
  const DomainTabAdmin({Key? key}) : super(key: key);

  @override
  State<DomainTabAdmin> createState() => _DomainTabAdminState();
}

class _DomainTabAdminState extends State<DomainTabAdmin> {
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
    final adminProv = Provider.of<AdminProvider>(context, listen: true);
    final authProv = Provider.of<AuthProvider>(context, listen: false);

    // We assume if you're on DomainTabAdmin, you're an admin user
    // or we can do a check, but let's keep it simple:
    final filteredDomains = adminProv.testDomains.where((dom) {
      final q = _searchController.text.trim().toLowerCase();
      return dom.name.toLowerCase().contains(q) ||
          dom.description.toLowerCase().contains(q);
    }).toList();

    return Column(
      children: [
        Container(
          height: 60,
          color: Theme.of(context).primaryColor.withOpacity(0.1),
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              Text(
                'Domains (Admin)',
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
                  authProv.logout();
                  Navigator.pushReplacementNamed(context, '/');
                },
                tooltip: 'Logout',
              ),
            ],
          ),
        ),
        Expanded(
          child: Row(
            children: [
              // Left side => domain list
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
                                title: Text(
                                  dom.name,
                                  style: const TextStyle(fontWeight: FontWeight.bold),
                                ),
                                subtitle: Text(dom.description),
                                onTap: () {
                                  setState(() {
                                    _selectedDomain = dom;
                                    _loadDomainTests(dom, adminProv);
                                  });
                                },
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              // Right side => add domain + domain detail
              Container(
                width: 360,
                padding: const EdgeInsets.all(16),
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      _buildAddDomainCard(adminProv),
                      const SizedBox(height: 24),
                      if (_selectedDomain != null)
                        _buildDomainDetails(adminProv, _selectedDomain!),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAddDomainCard(AdminProvider adminProv) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
                final n = _domainNameController.text.trim();
                final d = _domainDescController.text.trim();
                if (n.isEmpty || d.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Please fill all fields'),
                      backgroundColor: Colors.red,
                    ),
                  );
                  return;
                }
                final newDom = TestDomain(
                  id: (adminProv.testDomains.isEmpty)
                      ? 1
                      : adminProv.testDomains.map((x) => x.id).reduce((a, b) => a>b?a:b)+1,
                  name: n,
                  description: d,
                  createdAt: DateTime.now(),
                );
                adminProv.addTestDomain(newDom);
                _domainNameController.clear();
                _domainDescController.clear();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Domain added'),
                    backgroundColor: Colors.green,
                  ),
                );
              },
              width: double.infinity,
            ),
          ],
        ),
      ),
    );
  }

  void _loadDomainTests(TestDomain dom, AdminProvider adminProv) {
    final tests = adminProv.tests.where((t) => t.domainId == dom.id).toList();
    _selectedTestIds.clear();

    // Example auto-check if domain id=3 => secretary
    if (dom.id == 3) {
      for (var t in tests) {
        if (t.name.contains('English') || t.name.contains('Word') || t.name.contains('Excel')) {
          _selectedTestIds.add(t.id);
        }
      }
    }
    setState(() {});
  }

  Widget _buildDomainDetails(AdminProvider adminProv, TestDomain dom) {
    final domainTests = adminProv.tests.where((t) => t.domainId == dom.id).toList();
    if (domainTests.isEmpty) {
      return Container(
        margin: const EdgeInsets.only(top:16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white, borderRadius: BorderRadius.circular(12),
        ),
        child: const Text('No tests available for this domain.'),
      );
    }
    return Container(
      margin: const EdgeInsets.only(top:16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            '${dom.name} Tests',
            style: TextStyle(
                fontSize:16,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).primaryColor
            ),
          ),
          const SizedBox(height:16),
          ...domainTests.map((test) {
            final isChecked = _selectedTestIds.contains(test.id);
            return CheckboxListTile(
              title: Text('${test.name} (Code: ${test.code})'),
              value: isChecked,
              onChanged: (val){
                setState(() {
                  if (val==true) {
                    _selectedTestIds.add(test.id);
                  } else {
                    _selectedTestIds.remove(test.id);
                  }
                });
              },
            );
          }).toList(),
          const SizedBox(height:16),
          CustomButton(
            text: 'Assign Selected Tests',
            icon: Icons.send,
            onPressed: _selectedTestIds.isEmpty ? null : () => _assignTests(adminProv),
          ),
        ],
      ),
    );
  }

  void _assignTests(AdminProvider adminProv){
    // always show the adminAssignTestsDialog because it's admin
    showDialog(
      context: context,
      builder: (_) => AdminAssignTestsDialog(
        testIdsToAssign: _selectedTestIds,
        adminProvider: adminProv,
      ),
    );
  }
}
