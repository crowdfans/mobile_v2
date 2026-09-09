import 'package:crowdfans/constants/theme.dart';
import 'package:flutter/material.dart';

/// Card de saldo do artista (para usar / para resgatar).
class ArtistJamCoinsBalanceCard extends StatelessWidget {
  const ArtistJamCoinsBalanceCard({
    super.key,
    required this.label,
    required this.balance,
    required this.helperText,
    required this.actionLabel,
    required this.onAction,
    this.secondaryValue,
  });

  final String label;
  final String balance;
  final String helperText;
  final String actionLabel;
  final VoidCallback onAction;
  final String? secondaryValue;

  @override
  Widget build(BuildContext context) {
    final colors = CrowdFansTheme.of(context);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: colors.border),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.toll, size: 28, color: AppPalette.yellow600),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    label,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: colors.textPrimary,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              balance,
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.w900,
                color: colors.textPrimary,
              ),
            ),
            if (secondaryValue != null) ...[
              const SizedBox(height: 2),
              Text(
                secondaryValue!,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: colors.primary,
                ),
              ),
            ],
            const SizedBox(height: 8),
            Text(
              helperText,
              style: TextStyle(
                fontSize: 12,
                height: 1.35,
                color: colors.textSecondary,
              ),
            ),
            const SizedBox(height: 14),
            SizedBox(
              width: double.infinity,
              child: Material(
                color: colors.textPrimary,
                borderRadius: BorderRadius.circular(999),
                child: InkWell(
                  onTap: onAction,
                  borderRadius: BorderRadius.circular(999),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    child: Center(
                      child: Text(
                        actionLabel,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                          color: colors.background,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
