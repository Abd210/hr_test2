// //user_card.dart
// import 'package:flutter/material.dart';
// import '../models/role.dart';
// import '../models/user.dart';
// import 'custom_button.dart';
//
// class UserCard extends StatelessWidget {
//   final User user;
//   final VoidCallback onEdit;
//   final VoidCallback onDelete;
//
//   const UserCard({
//     Key? key,
//     required this.user,
//     required this.onEdit,
//     required this.onDelete,
//   }) : super(key: key);
//
//   String getRoles(List<Role> roles) {
//     return roles.map((role) => role.roleName).join(', ');
//   }
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
//             Text(user.username,
//                 style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
//             SizedBox(height: 8),
//             Text('Email: ${user.email}'),
//             Text('Phone: ${user.phoneNumber ?? 'N/A'}'),
//             Text('Organization: ${user.organization.name}'),
//             Text('Roles: ${getRoles(user.roles)}'),
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
