import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/admin_provider.dart';
import '../providers/auth_provider.dart';
import '../models/organization.dart';
import '../models/user.dart';
import '../widgets/custom_button.dart';

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
  int? _selectedOrgId;
  int? _selectedUserId;

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    final isOrganization = authProvider.currentOrganization != null;
    final org = authProvider.currentOrganization;

    return AlertDialog(
      title: const Text('Assign Tests', style: TextStyle(fontWeight: FontWeight.bold)),
      content: isOrganization && org != null
          ? _buildOrganizationFlow(org)
          : _buildAdminFlow(),
      actions: [
        TextButton(
          child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
          onPressed: () => Navigator.pop(context),
        ),
        ElevatedButton(
          child: const Text('Assign'),
          onPressed: _canAssign() ? _doAssign : null,
        ),
      ],
    );
  }

  // --------------------------------------------------------------------------
  // 1) Organization Flow
  // --------------------------------------------------------------------------
  Widget _buildOrganizationFlow(Organization org) {
    // Show a single dropdown of users who belong to this org
    final orgUsers = widget.adminProvider.users.where((u) {
      return u.organization.id == org.id;
    }).toList();

    return SizedBox(
      width: 300,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          DropdownButtonFormField<int>(
            decoration: const InputDecoration(labelText: 'Select User'),
            items: orgUsers.map((u) {
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
    );
  }

  // --------------------------------------------------------------------------
  // 2) Admin Flow
  // --------------------------------------------------------------------------
  Widget _buildAdminFlow() {
    final allOrgs = widget.adminProvider.organizations;
    // If _selectedOrgId is not set, the orgUsers list is empty
    final selectedOrg = allOrgs.firstWhere(
          (o) => o.id == _selectedOrgId,
      orElse: () => (allOrgs.isEmpty)
          ? Organization(id: -1, name: 'No Orgs', description: '', createdAt: DateTime.now())
          : allOrgs[0],
    );

    final orgUsers = (_selectedOrgId == null || selectedOrg.id == -1)
        ? <User>[]
        : widget.adminProvider.users.where((u) => u.organization.id == _selectedOrgId).toList();

    return SizedBox(
      width: 320,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 1) Organization dropdown
          DropdownButtonFormField<int>(
            decoration: const InputDecoration(labelText: 'Select Organization'),
            items: allOrgs.map((org) {
              return DropdownMenuItem<int>(
                value: org.id,
                child: Text(org.name),
              );
            }).toList(),
            onChanged: (val) {
              setState(() {
                _selectedOrgId = val;
                _selectedUserId = null; // reset user
              });
            },
            value: _selectedOrgId,
            hint: const Text('Choose Organization'),
          ),
          const SizedBox(height: 16),
          // 2) User dropdown
          if (_selectedOrgId != null)
            DropdownButtonFormField<int>(
              decoration: const InputDecoration(labelText: 'Select User'),
              items: orgUsers.map((u) {
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
    );
  }

  // --------------------------------------------------------------------------
  // 3) Validate & Assign
  // --------------------------------------------------------------------------
  bool _canAssign() {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final isOrganization = authProvider.currentOrganization != null;

    if (isOrganization) {
      // Need a user
      return _selectedUserId != null;
    } else {
      // Admin
      return (_selectedOrgId != null) && (_selectedUserId != null);
    }
  }

  void _doAssign() {
    if (_selectedUserId == null) return;

    widget.adminProvider.assignTestsToUser(_selectedUserId!, widget.testIdsToAssign);

    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Tests assigned successfully.'),
        backgroundColor: Colors.green,
      ),
    );
  }
}
