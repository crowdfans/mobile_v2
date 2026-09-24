import 'package:crowdfans/constants/theme.dart';
import 'package:flutter/material.dart';

/// Checkbox de aceite dos termos (CF-206) — não pré-marcado.
class MembershipSubscribeTermsCheckbox extends StatelessWidget {
  const MembershipSubscribeTermsCheckbox({
    super.key,
    required this.accepted,
    required this.onChanged,
  });

  final bool accepted;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final colors = CrowdFansTheme.of(context);
    return InkWell(
      onTap: () => onChanged(!accepted),
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 24,
              height: 24,
              child: Checkbox(
                value: accepted,
                onChanged: (value) => onChanged(value ?? false),
                activeColor: colors.primary,
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                visualDensity: VisualDensity.compact,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                'Ao prosseguir, você está de acordo com os Termos de Uso e Condições de Serviço',
                style: TextStyle(
                  fontSize: 13,
                  height: 18 / 13,
                  color: colors.textPrimary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
