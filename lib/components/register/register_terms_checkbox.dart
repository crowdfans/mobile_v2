import 'package:crowdfans/constants/theme.dart';
import 'package:flutter/material.dart';

/// Checkbox dos termos no cadastro Superfã.
class RegisterTermsCheckbox extends StatelessWidget {
  const RegisterTermsCheckbox({
    super.key,
    required this.accepted,
    required this.onToggle,
  });

  final bool accepted;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    final colors = CrowdFansTheme.of(context);
    return GestureDetector(
      key: const Key('register-terms-checkbox'),
      onTap: onToggle,
      behavior: HitTestBehavior.opaque,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          DecoratedBox(
            decoration: BoxDecoration(
              color: accepted ? colors.primary : Colors.transparent,
              borderRadius: BorderRadius.circular(4),
              border: Border.all(
                color: accepted ? colors.primary : colors.inputBorder,
                width: 2,
              ),
            ),
            child: SizedBox(
              width: 22,
              height: 22,
              child: accepted
                  ? const Icon(
                      Icons.check,
                      size: 14,
                      color: AppPalette.platinum50,
                    )
                  : null,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Ao prosseguir, você está de acordo com os Termos de Uso e a Política de Privacidade da Crowd Fans.',
              style: TextStyle(
                fontSize: 14,
                height: 20 / 14,
                color: colors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
