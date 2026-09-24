import 'package:crowdfans/components/post/post_avatar.dart';
import 'package:crowdfans/constants/theme.dart';
import 'package:flutter/material.dart';

/// Resumo do artista e preço na revisão de assinatura (CF-206).
class MembershipSubscribeArtistSummary extends StatelessWidget {
  const MembershipSubscribeArtistSummary({
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
    return Semantics(
      label:
          '$artistName. ${handle.isNotEmpty ? '$handle. ' : ''}$pricePerMonth Jam Coins por mês.',
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: colors.border),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              PostAvatar(url: artistAvatarUrl ?? '', size: 56),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      artistName,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: colors.textPrimary,
                      ),
                    ),
                    if (handle.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        handle,
                        style: TextStyle(
                          fontSize: 13,
                          color: colors.textSecondary,
                        ),
                      ),
                    ],
                    const SizedBox(height: 6),
                    Text(
                      '$pricePerMonth Jam Coins / mês',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: colors.primary,
                      ),
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
