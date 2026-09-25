import 'package:crowdfans/constants/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// Campo de busca com lupa e limpar (prints Search / resultados).
class SearchQueryField extends StatelessWidget {
  const SearchQueryField({
    super.key,
    required this.hint,
    required this.onChanged,
    this.controller,
    this.autofocus = false,
    this.onSubmitted,
    this.onClear,
    this.showClear = false,
    this.pill = false,
    this.semanticLabel,
  });

  final String hint;
  final ValueChanged<String> onChanged;
  final TextEditingController? controller;
  final bool autofocus;
  final ValueChanged<String>? onSubmitted;
  final VoidCallback? onClear;
  final bool showClear;

  /// Cantos tipo pílula (print CF-240).
  final bool pill;

  /// Rótulo acessível quando o hint visual é só "…".
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final colors = CrowdFansTheme.of(context);
    final radius = BorderRadius.circular(pill ? 999 : 10);
    final field = TextField(
      controller: controller,
      autofocus: autofocus,
      onChanged: onChanged,
      onSubmitted: onSubmitted,
      textInputAction: TextInputAction.search,
      autocorrect: false,
      cursorColor: colors.primary,
      style: TextStyle(color: colors.textPrimary, fontSize: 16),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: colors.textTertiary),
        filled: true,
        fillColor: pill ? colors.surfaceAlt : colors.inputBackground,
        isDense: true,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 14,
        ),
        prefixIcon: Padding(
          padding: const EdgeInsets.only(left: 12, right: 8),
          child: SvgPicture.asset(
            'assets/icons/General/search-md.svg',
            width: 20,
            height: 20,
            colorFilter: ColorFilter.mode(
              colors.textTertiary,
              BlendMode.srcIn,
            ),
          ),
        ),
        prefixIconConstraints: const BoxConstraints(
          minWidth: 40,
          minHeight: 20,
        ),
        suffixIcon: showClear
            ? IconButton(
                onPressed: onClear,
                tooltip: 'Limpar busca',
                icon: Icon(Icons.close, size: 18, color: colors.textSecondary),
              )
            : null,
        enabledBorder: OutlineInputBorder(
          borderRadius: radius,
          borderSide: BorderSide(
            color: pill
                ? colors.border.withValues(alpha: 0.7)
                : colors.inputBorder,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: radius,
          borderSide: BorderSide(color: colors.primary),
        ),
      ),
    );
    final label = semanticLabel?.trim();
    if (label == null || label.isEmpty) {
      return field;
    }
    return Semantics(textField: true, label: label, child: field);
  }
}
