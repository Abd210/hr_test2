// lib/widgets/list_item_widget.dart

import 'package:flutter/material.dart';
import '../widgets/custom_button.dart';

class ListItemWidget extends StatelessWidget {
  final String title;
  final String subtitle;
  final List<String> additionalInfo;
  final List<CardAction> actions;
  final IconData? leadingIcon;
  final Color? leadingColor;

  const ListItemWidget({
    Key? key,
    required this.title,
    required this.subtitle,
    this.additionalInfo = const [],
    this.actions = const [],
    this.leadingIcon,
    this.leadingColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      leading: leadingIcon != null
          ? CircleAvatar(
        backgroundColor: leadingColor ?? theme.primaryColor,
        child: Icon(
          leadingIcon,
          color: Colors.white,
        ),
      )
          : null,
      title: Text(
        title,
        style: theme.textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.bold,
          color: theme.primaryColor,
        ),
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            subtitle,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: Colors.black87,
              fontWeight: FontWeight.w500,
            ),
          ),
          for (final info in additionalInfo) ...[
            const SizedBox(height: 4),
            Text(
              info,
              style: theme.textTheme.bodyMedium,
            ),
          ],
        ],
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: actions
            .map(
              (action) => Padding(
            padding: const EdgeInsets.only(left: 4.0),
            child: CustomButton(
              text: action.label,
              icon: action.icon ?? Icons.settings, // Provide a default icon if none
              color: action.color ?? theme.primaryColor,
              onPressed: action.onPressed,
              width: 90,
              height: 35,
              isOutlined: action.isOutlined,
            ),
          ),
        )
            .toList(),
      ),
      onTap: () {
        // Handle item tap if needed
      },
    );
  }
}

class CardAction {
  final String label;
  final IconData? icon;
  final Color? color;
  final VoidCallback onPressed;
  final bool isOutlined;

  CardAction({
    required this.label,
    required this.onPressed,
    this.icon,
    this.color,
    this.isOutlined = false,
  });
}
