import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/admin_provider.dart';
import '../providers/auth_provider.dart';
import '../models/organization.dart';
import '../models/user.dart';

class OrgAssignTestsDialog extends StatefulWidget {
  final List<int> testIdsToAssign;
  final AdminProvider adminProvider;

  const OrgAssignTestsDialog({
    Key? key,
    required this.testIdsToAssign,
    required this.adminProvider,
  }) : super(key: key);

  @override
  State<OrgAssignTestsDialog> createState() => _OrgAssignTestsDialogState();
}

class _OrgAssignTestsDialogState extends State<OrgAssignTestsDialog> {
  int? _selectedUserId;

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final org = authProvider.currentOrganization;

    if (org == null) {
      return AlertDialog(
        title: const Text('Error'),
        content: const Text('Not in organization mode.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      );
    }

    final orgUsers = widget.adminProvider.users.where((u) {
      return u.organization.id == org.id;
    }).toList();

    return AlertDialog(
      title: Text(
        'Assign Tests to ${org.name}',
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
      content: SizedBox(
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
      ),
      actions: [
        TextButton(
          child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
          onPressed: () => Navigator.pop(context),
        ),
        ElevatedButton(
          child: const Text('Assign'),
          onPressed: (_selectedUserId == null) ? null : _handleAssign,
        ),
      ],
    );
  }

  void _handleAssign() {
    widget.adminProvider.assignTestsToUser(
      _selectedUserId!,
      widget.testIdsToAssign,
    );

    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Tests assigned successfully.'),
        backgroundColor: Colors.green,
      ),
    );
  }
}
