import 'package:crowdfans/components/post/post_avatar.dart';
import 'package:crowdfans/constants/theme.dart';
import 'package:flutter/material.dart';

/// Resumo do artista no gerenciar membership (CF-205).
class MembershipManageArtistSummary extends StatelessWidget {
  const MembershipManageArtistSummary({
    super.key,
    required this.artistName,
    required this.pricePerMonth,
    this.artistHandle,
    this.artistAvatarUrl,
  });

  final String artistName;
  final int pricePerMonth;
  final String? artistHandle;
  final String? artistAvatarUrl;

  String get handleLabel {
    final raw = (artistHandle ?? '').trim();
    if (raw.isEmpty) {
      return '';
    }
    return raw.startsWith('@') ? raw : '@$raw';
  }

  @override
  Widget build(BuildContext context) {
    final colors = CrowdFansTheme.of(context);
    final handle = handleLabel;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colors.border),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            PostAvatar(url: artistAvatarUrl ?? '', size: 48),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    artistName,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      color: colors.textPrimary,
                    ),
                  ),
                  if (handle.isNotEmpty)
                    Text(
                      handle,
                      style: TextStyle(
                        fontSize: 12,
                        color: colors.textSecondary,
                      ),
                    ),
                ],
              ),
            ),
            Image.asset(
              'assets/images/jam-coin.png',
              width: 18,
              height: 18,
              excludeFromSemantics: true,
              errorBuilder: (_, _, _) => const Icon(
                Icons.monetization_on,
                size: 18,
                color: Color(0xFFF5C451),
              ),
            ),
            const SizedBox(width: 4),
            Text(
              '$pricePerMonth/mês',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w800,
                color: colors.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
