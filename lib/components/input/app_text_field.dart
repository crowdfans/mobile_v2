import 'package:crowdfans/constants/theme.dart';
import 'package:flutter/material.dart';

/// Campo de texto padrão CrowdFans.
class AppTextField extends StatelessWidget {
  const AppTextField({
    super.key,
    required this.onChanged,
    this.hint,
    this.label,
    this.helper,
    this.helperColor,
    this.keyboardType,
    this.obscureText = false,
    this.maxLines = 1,
    this.initialValue,
    this.textCapitalization = TextCapitalization.none,
  });

  final String? initialValue;
  final String? hint;
  final String? label;
  final String? helper;
  final Color? helperColor;
  final ValueChanged<String> onChanged;
  final TextInputType? keyboardType;
  final bool obscureText;
  final int maxLines;
  final TextCapitalization textCapitalization;

  @override
  Widget build(BuildContext context) {
    final colors = CrowdFansTheme.of(context);
    final field = TextFormField(
      initialValue: initialValue,
      onChanged: onChanged,
      keyboardType: keyboardType,
      obscureText: obscureText,
      maxLines: maxLines,
      textCapitalization: textCapitalization,
      autocorrect: false,
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
    if (label == null && (helper == null || helper!.isEmpty)) {
      return field;
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 7),
            child: Text(
              label!,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: colors.textPrimary,
              ),
            ),
          ),
        field,
        if (helper != null && helper!.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 7),
            child: Text(
              helper!,
              style: TextStyle(
                fontSize: 12,
                color: helperColor ?? colors.textSecondary,
              ),
            ),
          ),
      ],
    );
  }
}
