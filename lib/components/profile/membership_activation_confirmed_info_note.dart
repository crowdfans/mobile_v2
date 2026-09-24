import 'package:crowdfans/constants/theme.dart';
import 'package:flutter/material.dart';

/// Nota de notificações após ativar membership (CF-207).
class MembershipActivationConfirmedInfoNote extends StatelessWidget {
  const MembershipActivationConfirmedInfoNote({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = CrowdFansTheme.of(context);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: colors.surfaceAlt,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Text(
          'Fica de olho nas notificações, porque sempre que rolar algo novo, você vai receber primeiro.',
          style: TextStyle(
            fontSize: 13,
            height: 18 / 13,
            color: colors.textSecondary,
          ),
        ),
      ),
    );
  }
}
