import 'package:crowdfans/components/post/post_avatar.dart';
import 'package:crowdfans/constants/theme.dart';
import 'package:flutter/material.dart';

/// Cartão do artista na confirmação de membership (CF-207).
class MembershipActivationConfirmedCard extends StatelessWidget {
  const MembershipActivationConfirmedCard({
    super.key,
    required this.artistName,
    required this.pricePerMonth,
    this.artistHandle,
    this.artistAvatarUrl,
    this.periodLabel = '1 mês',
  });

  final String artistName;
  final int pricePerMonth;
  final String? artistHandle;
  final String? artistAvatarUrl;
  final String periodLabel;

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
    return Semantics(
      label: [
        'Membership de $artistName',
        if (handle.isNotEmpty) handle,
        '$pricePerMonth Jam Coins por mês',
        periodLabel,
      ].join('. '),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: colors.border),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                children: [
                  DecoratedBox(
                    decoration: BoxDecoration(
                      color: AppPalette.blue50,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Image.asset(
                        'assets/images/rock-hand.png',
                        width: 36,
                        height: 36,
                        excludeFromSemantics: true,
                        errorBuilder: (_, _, _) => Icon(
                          Icons.nightlife,
                          size: 36,
                          color: colors.primary,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    periodLabel,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: colors.textPrimary,
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        PostAvatar(url: artistAvatarUrl ?? '', size: 36),
                        const SizedBox(width: 10),
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
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Image.asset(
                          'assets/images/jam-coin.png',
                          width: 22,
                          height: 22,
                          excludeFromSemantics: true,
                          errorBuilder: (_, _, _) => const Icon(
                            Icons.monetization_on,
                            size: 22,
                            color: Color(0xFFF5C451),
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          '$pricePerMonth/mês',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w900,
                            color: colors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
