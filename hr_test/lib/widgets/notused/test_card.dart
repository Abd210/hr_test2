// //test_card.dart
// import 'package:flutter/material.dart';
// import '../models/test_model.dart';
// import 'custom_button.dart';
//
// class TestCard extends StatelessWidget {
//   final TestModel test;
//   final VoidCallback onEdit;
//   final VoidCallback onDelete;
//   final VoidCallback onManageQuestions;
//
//   const TestCard({
//     Key? key,
//     required this.test,
//     required this.onEdit,
//     required this.onDelete,
//     required this.onManageQuestions,
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
//             Text(test.name,
//                 style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
//             SizedBox(height: 8),
//             Text('Code: ${test.code}'),
//             Text('Grade: ${test.grade}'),
//             Text('Duration: ${test.duration} minutes'),
//             Text('Status: ${test.isActive ? "Active" : "Inactive"}'),
//             SizedBox(height: 16),
//             Row(
//               mainAxisAlignment: MainAxisAlignment.end,
//               children: [
//                 CustomButton(
//                   text: 'Manage Questions',
//                   icon: Icons.question_answer,
//                   color: Colors.green,
//                   onPressed: onManageQuestions,
//                   width: 160,
//                 ),
//                 SizedBox(width: 8),
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
