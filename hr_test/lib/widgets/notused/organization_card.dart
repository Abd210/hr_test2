// //organization.dart
// import 'package:flutter/material.dart';
// import '../models/organization.dart';
// import 'custom_button.dart';
//
// class OrganizationCard extends StatelessWidget {
//   final Organization organization;
//   final VoidCallback onEdit;
//   final VoidCallback onDelete;
//
//   const OrganizationCard({
//     Key? key,
//     required this.organization,
//     required this.onEdit,
//     required this.onDelete,
//   }) : super(key: key);
//
//   @override
//   Widget build(BuildContext context) {
//     return Card(
//       color: Colors.white,
//       elevation: 3,
//       margin: EdgeInsets.symmetric(vertical: 8, horizontal: 4),
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//       child: Padding(
//         padding: EdgeInsets.all(16.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Text(organization.name,
//                 style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
//             SizedBox(height: 8),
//             Text(organization.description),
//             SizedBox(height: 16),
//             Row(
//               mainAxisAlignment: MainAxisAlignment.end,
//               children: [
//                 CustomButton(
//                   text: 'Edit',
//                   icon: Icons.edit,
//                   color: Colors.orange,
//                   onPressed: onEdit,
//                   width: 100,
//                 ),
//                 SizedBox(width: 8),
//                 CustomButton(
//                   text: 'Delete',
//                   icon: Icons.delete,
//                   color: Colors.red,
//                   onPressed: onDelete,
//                   width: 100,
//                 ),
//               ],
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
