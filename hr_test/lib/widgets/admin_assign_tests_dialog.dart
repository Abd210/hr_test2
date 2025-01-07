import 'package:flutter/material.dart';
import '../providers/admin_provider.dart';
import '../models/user.dart';
import '../models/organization.dart';

class AdminAssignTestsDialog extends StatefulWidget {
  final List<int> testIdsToAssign;
  final AdminProvider adminProvider;

  const AdminAssignTestsDialog({
    Key? key,
    required this.testIdsToAssign,
    required this.adminProvider,
  }) : super(key: key);

  @override
  State<AdminAssignTestsDialog> createState() => _AdminAssignTestsDialogState();
}

class _AdminAssignTestsDialogState extends State<AdminAssignTestsDialog> {
  int? _selectedOrgId;
  int? _selectedUserId;

  @override
  Widget build(BuildContext context) {
    final orgs = widget.adminProvider.organizations;

    List<User> orgUsers = [];
    if (_selectedOrgId != null) {
      orgUsers = widget.adminProvider.users.where((u) {
        return u.organization.id == _selectedOrgId;
      }).toList();
    }

    return AlertDialog(
      title: const Text('Assign Tests (Admin)', style: TextStyle(fontWeight: FontWeight.bold)),
      content: SizedBox(
        width: 350,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            DropdownButtonFormField<int>(
              decoration: const InputDecoration(labelText: 'Select Organization'),
              items: orgs.map((org) {
                return DropdownMenuItem<int>(
                  value: org.id,
                  child: Text(org.name),
                );
              }).toList(),
              onChanged: (val) {
                setState(() {
                  _selectedOrgId = val;
                  _selectedUserId = null;
                });
              },
              value: _selectedOrgId,
              hint: const Text('Choose Organization'),
            ),
            const SizedBox(height: 16),
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
      ),
      actions: [
        TextButton(
          child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
          onPressed: () => Navigator.pop(context),
        ),
        ElevatedButton(
          child: const Text('Assign'),
          onPressed: _canAssign() ? _handleAssign : null,
        ),
      ],
    );
  }

  bool _canAssign() {
    return _selectedOrgId != null && _selectedUserId != null;
  }

  void _handleAssign() {
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
  }
}
