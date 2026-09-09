import 'package:crowdfans/components/post/post_avatar.dart';
import 'package:crowdfans/constants/theme.dart';
import 'package:crowdfans/services/fan_club_viewer_service.dart';
import 'package:flutter/material.dart';

/// Linha de clube que o viewer pode moderar.
class FanClubModerationCommunityRow extends StatelessWidget {
  const FanClubModerationCommunityRow({
    super.key,
    required this.community,
    required this.onTap,
  });

  final FanClubModerationCommunity community;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = CrowdFansTheme.of(context);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: colors.border),
        ),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              PostAvatar(url: community.artistPhotoUrl, size: 48),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      community.artistName,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: colors.textPrimary,
                      ),
                    ),
                    Text(
                      '${community.memberCount} membros · ${community.pendingAppealsCount} apelações · ${community.activeStrikesCount} strikes · ${community.expulsionsCount} expulsões',
                      style: TextStyle(
                        fontSize: 12,
                        height: 17 / 12,
                        color: colors.textSecondary,
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
