import 'package:crowdfans/components/post/post_avatar.dart';
import 'package:crowdfans/constants/theme.dart';
import 'package:crowdfans/models/membership.dart';
import 'package:flutter/material.dart';

/// Cartão de membership ativa ou disponível.
class MembershipArtistCard extends StatelessWidget {
  const MembershipArtistCard({
    super.key,
    required this.item,
    this.onCancel,
    this.busy = false,
    this.catalog = false,
  });

  final MembershipCard item;
  final VoidCallback? onCancel;
  final bool busy;
  final bool catalog;

  @override
  Widget build(BuildContext context) {
    final colors = CrowdFansTheme.of(context);
    final price = item.price;
    final detail = price != null
        ? '${price.toString()} Jam Coins por mês'
        : catalog
        ? (item.availabilityLabel ?? 'Disponível')
        : (item.monthsLabel ?? 'Assinatura ativa');
    final status = catalog
        ? 'Disponível'
        : (item.statusLabel ?? item.status ?? 'Ativa');
    final statusColor = catalog ? colors.primaryStrong : AppPalette.green700;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colors.border),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                PostAvatar(url: item.artistAvatarUri ?? '', size: 54),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.displayName,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          color: colors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        detail,
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
                      status,
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        color: statusColor,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            if (onCancel != null) ...[
              const SizedBox(height: 12),
              TextButton(
                onPressed: busy ? null : onCancel,
                style: TextButton.styleFrom(
                  backgroundColor: colors.surfaceAlt,
                  foregroundColor: colors.danger,
                ),
                child: Text(
                  busy ? 'Cancelando...' : 'Cancelar assinatura',
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
