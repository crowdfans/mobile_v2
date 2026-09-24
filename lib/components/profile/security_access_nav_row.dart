import 'package:crowdfans/constants/theme.dart';
import 'package:flutter/material.dart';

/// Item de acesso da central Segurança e Login (CF-215).
class SecurityAccessNavRow extends StatelessWidget {
  const SecurityAccessNavRow({
    super.key,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.showDivider = true,
  });

  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final bool showDivider;

  @override
  Widget build(BuildContext context) {
    final colors = CrowdFansTheme.of(context);
    return Column(
      children: [
        InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 14),
            child: Row(
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
                Icon(Icons.chevron_right, color: colors.textTertiary),
              ],
            ),
          ),
        ),
        if (showDivider)
          Divider(height: 1, thickness: 0.5, color: colors.border),
      ],
    );
  }
}
