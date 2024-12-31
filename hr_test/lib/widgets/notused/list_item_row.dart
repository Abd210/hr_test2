// // lib/widgets/list_item_row.dart
//
// import 'package:flutter/material.dart';
// import '../widgets/custom_button.dart';
//
// class ListItemRow extends StatelessWidget {
//   final String title;
//   final String subtitle;
//   final List<String> additionalInfo;
//   final List<RowAction> actions;
//   final IconData? leadingIcon;
//   final Color? leadingColor;
//
//   const ListItemRow({
//     Key? key,
//     required this.title,
//     required this.subtitle,
//     this.additionalInfo = const [],
//     this.actions = const [],
//     this.leadingIcon,
//     this.leadingColor,
//   }) : super(key: key);
//
//   @override
//   Widget build(BuildContext context) {
//     final theme = Theme.of(context);
//     return Container(
//       padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
//       decoration: BoxDecoration(
//         border: Border(
//           bottom: BorderSide(color: Colors.grey.shade300),
//         ),
//       ),
//       child: Row(
//         children: [
//           // Leading Icon
//           if (leadingIcon != null) ...[
//             CircleAvatar(
//               backgroundColor: leadingColor ?? theme.primaryColor,
//               child: Icon(
//                 leadingIcon,
//                 color: Colors.white,
//                 size: 20,
//               ),
//               radius: 20,
//             ),
//             const SizedBox(width: 12),
//           ],
//
//           // Title and Subtitle
//           Expanded(
//             flex: 3,
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   title,
//                   style: theme.textTheme.titleMedium?.copyWith(
//                     fontWeight: FontWeight.bold,
//                     color: theme.primaryColor,
//                   ),
//                 ),
//                 const SizedBox(height: 4),
//                 Text(
//                   subtitle,
//                   style: theme.textTheme.bodyMedium?.copyWith(
//                     color: Colors.black87,
//                     fontWeight: FontWeight.w500,
//                   ),
//                 ),
//                 for (final info in additionalInfo) ...[
//                   const SizedBox(height: 2),
//                   Text(
//                     info,
//                     style: theme.textTheme.bodyMedium,
//                   ),
//                 ],
//               ],
//             ),
//           ),
//
//           // Actions
//           if (actions.isNotEmpty) ...[
//             const SizedBox(width: 12),
//             Row(
//               children: actions
//                   .map(
//                     (action) => Padding(
//                   padding: const EdgeInsets.only(left: 4.0),
//                   child: CustomButton(
//                     text: action.label,
//                     icon: action.icon ?? Icons.settings,
//                     color: action.color ?? theme.primaryColor,
//                     onPressed: action.onPressed,
//                     width: 80,
//                     height: 35,
//                     isOutlined: action.isOutlined,
//                   ),
//                 ),
//               )
//                   .toList(),
//             ),
//           ],
//         ],
//       ),
//     );
//   }
// }
//
// class RowAction {
//   final String label;
//   final IconData? icon;
//   final Color? color;
//   final VoidCallback onPressed;
//   final bool isOutlined;
//
//   RowAction({
//     required this.label,
//     required this.onPressed,
//     this.icon,
//     this.color,
//     this.isOutlined = false,
//   });
// }
