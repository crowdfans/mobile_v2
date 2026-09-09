import 'package:crowdfans/components/post/post_avatar.dart';
import 'package:crowdfans/constants/theme.dart';
import 'package:crowdfans/services/fan_club_service.dart';
import 'package:flutter/material.dart';

/// Linha de moderador (avatar, nome, papel).
class FanClubModeratorRow extends StatelessWidget {
  const FanClubModeratorRow({
    super.key,
    required this.moderator,
    this.onRemove,
  });

  final FanClubModerator moderator;
  final VoidCallback? onRemove;

  @override
  Widget build(BuildContext context) {
    final colors = CrowdFansTheme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          PostAvatar(url: moderator.photoUrl, size: 44),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  moderator.displayName,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: colors.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${moderator.isOwner ? 'Dono' : 'Moderador'}${moderator.handle.isEmpty ? '' : ' · ${moderator.handle}'}',
                  style: TextStyle(fontSize: 12, color: colors.textTertiary),
                ),
              ],
            ),
          ),
          if (onRemove != null)
            TextButton(
              onPressed: onRemove,
              child: Text('Remover', style: TextStyle(color: colors.danger)),
            ),
        ],
      ),
    );
  }
}
