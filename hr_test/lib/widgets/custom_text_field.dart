// lib/widgets/custom_text_field.dart

import 'package:flutter/material.dart';

class CustomTextField extends StatelessWidget {
  final String label;
  final String? hintText; // Added
  final TextEditingController controller;
  final bool obscureText;
  final TextInputType keyboardType;
  final String? Function(String?)? validator;
  final Widget? suffixIcon;
  final double verticalPadding;
  final double horizontalPadding;
  final ValueChanged<String>? onChanged;
  final int maxLines; // Added

  const CustomTextField({
    Key? key,
    required this.label,
    this.hintText, // Added
    required this.controller,
    this.obscureText = false,
    this.keyboardType = TextInputType.text,
    this.validator,
    this.suffixIcon,
    this.verticalPadding = 0.0,
    this.horizontalPadding = 20.0,
    this.onChanged, // <-- new
    this.maxLines = 1, // Added
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(
          vertical: verticalPadding, horizontal: horizontalPadding),
      child: TextFormField(
        controller: controller,
        obscureText: obscureText,
        keyboardType: keyboardType,
        validator: validator,
        onChanged: onChanged,
        maxLines: maxLines, // Added
        decoration: InputDecoration(
          labelText: label,
          hintText: hintText, // Added
          suffixIcon: suffixIcon,
          border: const OutlineInputBorder(),
        ),
      ),
    );
  }
}
