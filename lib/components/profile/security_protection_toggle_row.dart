import 'package:crowdfans/constants/theme.dart';
import 'package:flutter/material.dart';

/// Linha com switch da seção Proteção da conta (CF-215).
///
/// Switch Material (não adaptive) para o track roxo do print — Cupertino
/// fica verde e ignora [activeTrackColor].
class SecurityProtectionToggleRow extends StatelessWidget {
  const SecurityProtectionToggleRow({
    super.key,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final colors = CrowdFansTheme.of(context);
    return Semantics(
      label: title,
      hint: subtitle,
      toggled: value,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: colors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 13,
                      height: 1.35,
                      color: colors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Switch(
              value: value,
              onChanged: onChanged,
              activeThumbColor: colors.surface,
              activeTrackColor: colors.primary,
              inactiveThumbColor: colors.surface,
              inactiveTrackColor: colors.border,
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
          ],
        ),
      ),
    );
  }
}
