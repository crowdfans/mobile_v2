import 'package:crowdfans/constants/theme.dart';
import 'package:flutter/material.dart';

/// Campo de texto padrão CrowdFans.
class AppTextField extends StatelessWidget {
  const AppTextField({
    super.key,
    required this.onChanged,
    this.hint,
    this.keyboardType,
    this.obscureText = false,
    this.maxLines = 1,
    this.initialValue,
  });

  final String? initialValue;
  final String? hint;
  final ValueChanged<String> onChanged;
  final TextInputType? keyboardType;
  final bool obscureText;
  final int maxLines;

  @override
  Widget build(BuildContext context) {
    final colors = CrowdFansTheme.of(context);
    return TextFormField(
      initialValue: initialValue,
      onChanged: onChanged,
      keyboardType: keyboardType,
      obscureText: obscureText,
      maxLines: maxLines,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: colors.textTertiary),
        filled: true,
        fillColor: colors.inputBackground,
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: colors.inputBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: colors.primary),
        ),
      ),
      style: TextStyle(color: colors.textPrimary, fontSize: 18),
    );
  }
}
