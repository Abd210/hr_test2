// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import '../../../../providers/admin_provider.dart';
// import '../../../../providers/auth_provider.dart';
// import '../../../../models/test_domain.dart';
// import '../../../../widgets/admin_assign_tests_dialog.dart';
// import '../../../../widgets/custom_text_field.dart';
// import '../../../../widgets/custom_button.dart';
// import '../../../../widgets/org_assign_tests_dialog.dart';
//
//
//
// class DomainTab extends StatefulWidget {
//   const DomainTab({Key? key}) : super(key: key);
//
//   @override
//   State<DomainTab> createState() => _DomainTabState();
// }
//
// class _DomainTabState extends State<DomainTab> {
//   final TextEditingController _searchController = TextEditingController();
//   final TextEditingController _domainNameController = TextEditingController();
//   final TextEditingController _domainDescController = TextEditingController();
//
//   TestDomain? _selectedDomain;
//   List<int> _selectedTestIds = [];
//
//   @override
//   void dispose() {
//     _searchController.dispose();
//     _domainNameController.dispose();
//     _domainDescController.dispose();
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final adminProv = Provider.of<AdminProvider>(context, listen: true);
//     final authProv = Provider.of<AuthProvider>(context, listen: false);
//
//     final filtered = adminProv.testDomains.where((dom) {
//       final q = _searchController.text.trim().toLowerCase();
//       return dom.name.toLowerCase().contains(q) ||
//           dom.description.toLowerCase().contains(q);
//     }).toList();
//
//     return Column(
//       children: [
//         Container(
//           height: 60,
//           color: Theme.of(context).primaryColor.withOpacity(0.1),
//           padding: const EdgeInsets.symmetric(horizontal: 16),
//           child: Row(
//             children: [
//               Text(
//                 'Domains',
//                 style: TextStyle(
//                   color: Theme.of(context).primaryColor,
//                   fontSize: 20,
//                   fontWeight: FontWeight.bold,
//                 ),
//               ),
//               const Spacer(),
//               IconButton(
//                 icon: const Icon(Icons.logout),
//                 color: Theme.of(context).primaryColor,
//                 onPressed: () {
//                   authProv.logout();
//                   Navigator.pushReplacementNamed(context, '/');
//                 },
//                 tooltip: 'Logout',
//               ),
//             ],
//           ),
//         ),
//         Expanded(
//           child: Row(
//             children: [
//               // left side
//               Expanded(
//                 flex: 3,
//                 child: Padding(
//                   padding: const EdgeInsets.all(16),
//                   child: Column(
//                     children: [
//                       Row(
//                         children: [
//                           Expanded(
//                             child: CustomTextField(
//                               label: 'Search Domains...',
//                               controller: _searchController,
//                               onChanged: (_) => setState(() {}),
//                             ),
//                           ),
//                           const SizedBox(width: 8),
//                           IconButton(
//                             icon: const Icon(Icons.search),
//                             onPressed: () => setState(() {}),
//                           ),
//                         ],
//                       ),
//                       const SizedBox(height: 16),
//                       Expanded(
//                         child: filtered.isEmpty
//                             ? const Center(child: Text('No domains found.'))
//                             : ListView.builder(
//                           itemCount: filtered.length,
//                           itemBuilder: (ctx, i) {
//                             final dom = filtered[i];
//                             return Card(
//                               margin: const EdgeInsets.symmetric(vertical: 8),
//                               child: ListTile(
//                                 title: Text(
//                                   dom.name,
//                                   style: const TextStyle(fontWeight: FontWeight.bold),
//                                 ),
//                                 subtitle: Text(dom.description),
//                                 onTap: () {
//                                   setState(() {
//                                     _selectedDomain = dom;
//                                     _loadDomainTests(dom, adminProv);
//                                   });
//                                 },
//                               ),
//                             );
//                           },
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//               // right side
//               Container(
//                 width: 360,
//                 padding: const EdgeInsets.all(16),
//                 child: SingleChildScrollView(
//                   child: Column(
//                     children: [
//                       _buildAddDomainCard(adminProv),
//                       const SizedBox(height: 24),
//                       if (_selectedDomain != null)
//                         _buildDomainDetails(adminProv, _selectedDomain!),
//                     ],
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ],
//     );
//   }
//
//   Widget _buildAddDomainCard(AdminProvider adminProv) {
//     return Card(
//       elevation: 2,
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//       child: Padding(
//         padding: const EdgeInsets.all(16),
//         child: Column(
//           children: [
//             Text(
//               'Add Domain',
//               style: TextStyle(
//                 fontWeight: FontWeight.bold,
//                 fontSize: 16,
//                 color: Theme.of(context).primaryColor,
//               ),
//             ),
//             const SizedBox(height: 12),
//             CustomTextField(
//               label: 'Domain Name',
//               controller: _domainNameController,
//             ),
//             const SizedBox(height: 12),
//             CustomTextField(
//               label: 'Description',
//               controller: _domainDescController,
//             ),
//             const SizedBox(height: 12),
//             CustomButton(
//               text: 'Add Domain',
//               icon: Icons.add,
//               onPressed: () {
//                 final n = _domainNameController.text.trim();
//                 final d = _domainDescController.text.trim();
//                 if (n.isEmpty || d.isEmpty) {
//                   ScaffoldMessenger.of(context).showSnackBar(
//                     const SnackBar(
//                       content: Text('Please fill all fields'),
//                       backgroundColor: Colors.red,
//                     ),
//                   );
//                   return;
//                 }
//                 final newDom = TestDomain(
//                   id: (adminProv.testDomains.isEmpty)
//                       ? 1
//                       : adminProv.testDomains.map((x)=>x.id).reduce((a,b)=>a>b?a:b)+1,
//                   name: n,
//                   description: d,
//                   createdAt: DateTime.now(),
//                 );
//                 adminProv.addTestDomain(newDom);
//                 _domainNameController.clear();
//                 _domainDescController.clear();
//                 ScaffoldMessenger.of(context).showSnackBar(
//                   const SnackBar(
//                     content: Text('Domain added'),
//                     backgroundColor: Colors.green,
//                   ),
//                 );
//               },
//               width: double.infinity,
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   void _loadDomainTests(TestDomain dom, AdminProvider adminProv) {
//     final domainTests = adminProv.tests.where((t) => t.domainId == dom.id).toList();
//     _selectedTestIds.clear();
//
//     // Example default checks
//     if (dom.id == 3) {
//       for (var test in domainTests) {
//         if (test.name.contains('English') ||
//             test.name.contains('Word') ||
//             test.name.contains('Excel')) {
//           _selectedTestIds.add(test.id);
//         }
//       }
//     }
//     setState(() {});
//   }
//
//   Widget _buildDomainDetails(AdminProvider adminProv, TestDomain dom) {
//     final domainTests = adminProv.tests.where((t) => t.domainId == dom.id).toList();
//     if (domainTests.isEmpty) {
//       return Container(
//         margin: const EdgeInsets.only(top:16),
//         padding: const EdgeInsets.all(16),
//         decoration: BoxDecoration(
//           color: Colors.white,
//           borderRadius: BorderRadius.circular(12),
//         ),
//         child: const Text('No tests available for this domain.'),
//       );
//     }
//     return Container(
//       margin: const EdgeInsets.only(top:16),
//       padding: const EdgeInsets.all(16),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(12),
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.stretch,
//         children: [
//           Text(
//             '${dom.name} Tests',
//             style: TextStyle(
//               fontSize: 16,
//               fontWeight: FontWeight.bold,
//               color: Theme.of(context).primaryColor,
//             ),
//           ),
//           const SizedBox(height:16),
//           ...domainTests.map((test) {
//             final isChecked = _selectedTestIds.contains(test.id);
//             return CheckboxListTile(
//               title: Text('${test.name} (Code: ${test.code})'),
//               value: isChecked,
//               onChanged: (val){
//                 setState(() {
//                   if (val==true) {
//                     _selectedTestIds.add(test.id);
//                   } else {
//                     _selectedTestIds.remove(test.id);
//                   }
//                 });
//               },
//             );
//           }).toList(),
//           const SizedBox(height:16),
//           CustomButton(
//             text: 'Assign Selected Tests',
//             icon: Icons.send,
//             onPressed: _selectedTestIds.isEmpty
//                 ? null
//                 : () => _showAssignTestsDialog(adminProv),
//           ),
//         ],
//       ),
//     );
//   }
//
//   void _showAssignTestsDialog(AdminProvider adminProv) {
//     final authProv = Provider.of<AuthProvider>(context, listen: false);
//
//     if (authProv.isOrganizationMode) {
//       // Show org
//       showDialog(
//         context: context,
//         builder: (_) => OrgAssignTestsDialog(
//           testIdsToAssign: _selectedTestIds,
//           adminProvider: adminProv,
//         ),
//       );
//     } else {
//       // Show admin
//       showDialog(
//         context: context,
//         builder: (_) => AdminAssignTestsDialog(
//           testIdsToAssign: _selectedTestIds,
//           adminProvider: adminProv,
//         ),
//       );
//     }
//   }
// }
