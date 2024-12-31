//item_card.dart
import 'package:flutter/material.dart';
import '../widgets/custom_button.dart';

class ItemCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final List<String> additionalInfo;
  final List<CardAction> actions;

  const ItemCard({
    Key? key,
    required this.title,
    required this.subtitle,
    this.additionalInfo = const [],
    this.actions = const [],
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: 300,
      margin: const EdgeInsets.only(bottom: 16),
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        elevation: 4,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: theme.primaryColor,
                ),
              ),
              const SizedBox(height: 8),
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
              const SizedBox(height: 16),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: actions
                    .map(
                      (action) => CustomButton(
                    text: action.label,
                    icon: action.icon,
                    color: action.color,
                    onPressed: action.onPressed,
                    width: 110,
                    height: 40,
                    isOutlined: action.isOutlined,
                  ),
                )
                    .toList(),
              ),
            ],
          ),
        ),
      ),
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
