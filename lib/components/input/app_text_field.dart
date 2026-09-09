import 'package:crowdfans/constants/theme.dart';
import 'package:flutter/material.dart';

/// Campo de texto padrão CrowdFans (espelho do `InputComponent`).
class AppTextField extends StatefulWidget {
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
    this.maxLength,
    this.initialValue,
    this.enabled = true,
    this.readOnly = false,
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
  final int? maxLength;
  final bool enabled;
  final bool readOnly;
  final TextCapitalization textCapitalization;

  @override
  State<AppTextField> createState() => _AppTextFieldState();
}

class _AppTextFieldState extends State<AppTextField> {
  bool _visible = false;

  @override
  Widget build(BuildContext context) {
    final colors = CrowdFansTheme.of(context);
    final obscure = widget.obscureText && !_visible;
    final field = TextFormField(
      initialValue: widget.initialValue,
      onChanged: widget.onChanged,
      keyboardType: widget.keyboardType,
      obscureText: obscure,
      maxLines: widget.obscureText ? 1 : widget.maxLines,
      maxLength: widget.maxLength,
      enabled: widget.enabled,
      readOnly: widget.readOnly,
      textCapitalization: widget.textCapitalization,
      autocorrect: false,
      decoration: InputDecoration(
        hintText: widget.hint,
        hintStyle: TextStyle(color: colors.textTertiary),
        filled: true,
        fillColor: colors.inputBackground,
        counterText: widget.maxLength == null ? null : '',
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
        isDense: true,
        suffixIcon: widget.obscureText
            ? IconButton(
                onPressed: () => setState(() => _visible = !_visible),
                icon: Icon(
                  _visible ? Icons.visibility_off : Icons.visibility,
                  color: colors.textSecondary,
                  size: 18,
                ),
              )
            : null,
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: colors.inputBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: colors.primary),
        ),
      ),
      style: TextStyle(
        color: colors.textPrimary,
        fontSize: widget.maxLines > 1 ? 17 : 16,
      ),
    );
    if (widget.label == null &&
        (widget.helper == null || widget.helper!.isEmpty)) {
      return field;
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.label != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 7),
            child: Text(
              widget.label!,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: colors.textPrimary,
              ),
            ),
          ),
        field,
        if (widget.helper != null && widget.helper!.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 7),
            child: Text(
              widget.helper!,
              style: TextStyle(
                fontSize: 12,
                color: widget.helperColor ?? colors.textSecondary,
              ),
            ),
          ),
      ],
    );
  }
}
