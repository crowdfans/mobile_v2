import 'package:crowdfans/constants/theme.dart';
import 'package:flutter/material.dart';

/// Atalho para CrowdFans Pro na tela de memberships.
class MembershipProTeaser extends StatelessWidget {
  const MembershipProTeaser({super.key, required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final colors = CrowdFansTheme.of(context);
    return Material(
      color: colors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: colors.border),
      ),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              DecoratedBox(
                decoration: BoxDecoration(
                  color: colors.surfaceAlt,
                  shape: BoxShape.circle,
                ),
                child: SizedBox(
                  width: 54,
                  height: 54,
                  child: Icon(
                    Icons.workspace_premium_outlined,
                    color: colors.primaryStrong,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'CrowdFans Pro',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: colors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Mensal, anual ou vitalício via RevenueCat.',
                      style: TextStyle(
                        fontSize: 12,
                        height: 1.4,
                        color: colors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              DecoratedBox(
                decoration: BoxDecoration(
                  color: colors.surfaceAlt,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 9,
                    vertical: 5,
                  ),
                  child: Text(
                    'Assinar',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      color: colors.primaryStrong,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
