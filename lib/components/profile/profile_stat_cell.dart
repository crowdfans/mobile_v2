import 'package:crowdfans/constants/theme.dart';
import 'package:flutter/material.dart';

/// Célula de contador no bloco de identidade do perfil.
class ProfileStatCell extends StatelessWidget {
  const ProfileStatCell({
    super.key,
    required this.value,
    required this.label,
    this.divider = false,
    this.onTap,
  });

  final String value;
  final String label;
  final bool divider;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final colors = CrowdFansTheme.of(context);
    final content = DecoratedBox(
      decoration: BoxDecoration(
        border: divider ? Border(left: BorderSide(color: colors.border)) : null,
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 15),
        child: Column(
          children: [
            Text(
              value,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: colors.textPrimary,
              ),
            ),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: colors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
    return Expanded(
      child: onTap == null
          ? content
          : GestureDetector(onTap: onTap, child: content),
    );
  }
}
