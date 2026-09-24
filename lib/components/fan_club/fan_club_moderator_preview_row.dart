import 'package:crowdfans/components/post/post_avatar.dart';
import 'package:crowdfans/constants/theme.dart';
import 'package:crowdfans/services/fan_club_service.dart';
import 'package:crowdfans/services/profile_service.dart';
import 'package:flutter/material.dart';

/// Prévia de moderador no “Ver mais”: avatar, nome e handle `fan/…`.
class FanClubModeratorPreviewRow extends StatelessWidget {
  const FanClubModeratorPreviewRow({
    super.key,
    required this.moderator,
  });

  final FanClubModerator moderator;

  String get _handleLabel {
    final normalized = ProfileService.normalizeFanHandle(moderator.handle);
    if (normalized.isEmpty) {
      return '';
    }
    return normalized.startsWith('fan/') ? normalized : 'fan/$normalized';
  }

  @override
  Widget build(BuildContext context) {
    final colors = CrowdFansTheme.of(context);
    final handle = _handleLabel;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          PostAvatar(url: moderator.photoUrl, size: 48),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  moderator.displayName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: colors.textPrimary,
                  ),
                ),
                if (handle.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    handle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 13,
                      color: colors.textTertiary,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
