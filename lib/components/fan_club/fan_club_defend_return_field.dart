import 'package:crowdfans/constants/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Campo de defesa com contador 24–420 alinhado ao servidor (CF-200).
class FanClubDefendReturnField extends StatelessWidget {
  const FanClubDefendReturnField({
    super.key,
    required this.controller,
    required this.onChanged,
    this.errorText,
  });

  static const minChars = 24;
  static const maxChars = 420;

  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final String? errorText;

  @override
  Widget build(BuildContext context) {
    final colors = CrowdFansTheme.of(context);
    final length = controller.text.characters.length;
    final belowMin = length < minChars;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: controller,
          onChanged: onChanged,
          maxLines: 8,
          minLines: 5,
          maxLength: maxChars,
          maxLengthEnforcement: MaxLengthEnforcement.enforced,
          buildCounter: (
            context, {
            required currentLength,
            required isFocused,
            maxLength,
          }) =>
              const SizedBox.shrink(),
          style: TextStyle(fontSize: 15, color: colors.textPrimary),
          decoration: InputDecoration(
            hintText:
                'Conte o contexto, reconheça o problema e explique por que pode voltar sem repetir isso.',
            hintStyle: TextStyle(color: colors.textTertiary, fontSize: 14),
            filled: true,
            fillColor: colors.inputBackground,
            errorText: errorText,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(color: colors.inputBorder),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(color: colors.inputBorder),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(color: colors.primary, width: 1.5),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(color: colors.danger),
            ),
            contentPadding: const EdgeInsets.all(14),
          ),
        ),
        const SizedBox(height: 6),
        Row(
          children: [
            Expanded(
              child: Text(
                'Mínimo de $minChars caracteres.',
                style: TextStyle(
                  fontSize: 12,
                  color: belowMin && length > 0
                      ? colors.danger
                      : colors.textSecondary,
                ),
              ),
            ),
            Text(
              '$length/$maxChars',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: colors.textSecondary,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
