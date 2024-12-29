import 'package:flutter/material.dart';

/// Adjust this color to match your existing backgroundLight color:
const Color backgroundLight = Color(0xFFE8ECD7);

class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final Color? color;
  final double? width;
  final double? height;
  final IconData? icon;
  final bool isOutlined;

  const CustomButton({
    Key? key,
    required this.text,
    required this.onPressed,
    this.color,
    this.width,
    this.height,
    this.icon,
    this.isOutlined = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final Color buttonTextColor = backgroundLight;
    // <-- All button text is backgroundLight now

    if (isOutlined) {
      return OutlinedButton.icon(
        icon: icon != null
            ? Icon(
          icon,
          color: color ?? Theme.of(context).primaryColor,
        )
            : const SizedBox.shrink(),
        label: Text(
          text,
          style: TextStyle(
            color: buttonTextColor, // <-- text color here
          ),
        ),
        style: OutlinedButton.styleFrom(
          minimumSize: Size(width ?? 100, height ?? 45),
          side: BorderSide(
            color: color ?? Theme.of(context).primaryColor,
            width: 2,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        onPressed: onPressed,
      );
    } else {
      return ElevatedButton.icon(
        icon: icon != null ? Icon(icon, color: buttonTextColor) : const SizedBox.shrink(),
        label: Text(
          text,
          style: TextStyle(
            color: buttonTextColor, // <-- text color here
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: color ?? Theme.of(context).primaryColor,
          minimumSize: Size(width ?? 100, height ?? 45),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        onPressed: onPressed,
      );
    }
  }
}
