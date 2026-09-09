import 'package:crowdfans/constants/theme.dart';
import 'package:flutter/material.dart';

/// Bio opcional no cadastro (máximo 300 caracteres).
class RegisterProfileBioField extends StatelessWidget {
  const RegisterProfileBioField({
    super.key,
    required this.value,
    required this.onChanged,
    this.maxLength = 300,
  });

  final String value;
  final ValueChanged<String> onChanged;
  final int maxLength;

  @override
  Widget build(BuildContext context) {
    final colors = CrowdFansTheme.of(context);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: colors.inputBackground,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: colors.inputBorder),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Máximo de $maxLength caracteres',
              style: TextStyle(fontSize: 13, color: colors.textSecondary),
            ),
            const SizedBox(height: 8),
            TextFormField(
              initialValue: value,
              minLines: 3,
              maxLines: 5,
              maxLength: maxLength,
              onChanged: onChanged,
              decoration: InputDecoration(
                hintText: 'Descrição',
                hintStyle: TextStyle(color: colors.textTertiary),
                border: InputBorder.none,
                isDense: true,
                counterText: '',
              ),
              style: TextStyle(fontSize: 17, color: colors.textPrimary),
            ),
          ],
        ),
      ),
    );
  }
}
