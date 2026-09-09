import 'package:crowdfans/components/post/post_avatar.dart';
import 'package:crowdfans/constants/theme.dart';
import 'package:flutter/material.dart';

/// Barra inferior: destinatário + Jam Coins + enviar (mock Superfã).
class FanLetterRecipientBar extends StatelessWidget {
  const FanLetterRecipientBar({
    super.key,
    required this.artistName,
    required this.avatarUrl,
    required this.onRecipientTap,
    required this.onSend,
    this.jamCoinsBalance,
    this.jamCoinsCost,
    this.isMember = false,
    this.sending = false,
  });

  final String artistName;
  final String? avatarUrl;
  final VoidCallback onRecipientTap;
  final VoidCallback onSend;
  final int? jamCoinsBalance;
  final int? jamCoinsCost;
  final bool isMember;
  final bool sending;

  @override
  Widget build(BuildContext context) {
    final colors = CrowdFansTheme.of(context);
    final name = artistName.trim().isEmpty ? 'Artista' : artistName.trim();
    final amount = isMember
        ? jamCoinsBalance
        : (jamCoinsCost ?? jamCoinsBalance);
    final showCoins = amount != null;
    return Row(
      children: [
        Expanded(
          child: Material(
            color: colors.surface,
            borderRadius: BorderRadius.circular(999),
            elevation: 2,
            shadowColor: Colors.black26,
            child: InkWell(
              borderRadius: BorderRadius.circular(999),
              onTap: onRecipientTap,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(8, 8, 14, 8),
                child: Row(
                  children: [
                    PostAvatar(url: avatarUrl ?? '', size: 36),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: colors.textPrimary,
                        ),
                      ),
                    ),
                    if (showCoins) ...[
                      const SizedBox(width: 6),
                      const Icon(
                        Icons.monetization_on,
                        size: 18,
                        color: Color(0xFFEAB308),
                      ),
                      const SizedBox(width: 2),
                      Text(
                        '$amount',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: colors.textPrimary,
                        ),
                      ),
                    ],
                    const SizedBox(width: 4),
                    Icon(
                      Icons.keyboard_arrow_down_rounded,
                      color: colors.textSecondary,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Material(
          color: const Color(0xFF1E293B),
          shape: const CircleBorder(),
          child: InkWell(
            customBorder: const CircleBorder(),
            onTap: sending ? null : onSend,
            child: SizedBox(
              width: 52,
              height: 52,
              child: sending
                  ? const Padding(
                      padding: EdgeInsets.all(14),
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(Icons.send_rounded, color: Colors.white),
            ),
          ),
        ),
      ],
    );
  }
}
