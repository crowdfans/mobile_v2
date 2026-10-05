import 'package:crowdfans/components/post/post_avatar.dart';
import 'package:crowdfans/constants/theme.dart';
import 'package:crowdfans/services/fan_club_service.dart';
import 'package:crowdfans/services/profile_service.dart';
import 'package:flutter/material.dart';

/// Prévia de moderador (CF-223/225): avatar, nome e handle `fan/…`.
///
/// Nome pode quebrar em várias linhas (nomes longos); handle em uma linha.
/// Sem InkWell — a linha não finge ação se não há navegação.
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
    final semanticsLabel = handle.isEmpty
        ? moderator.displayName
        : '${moderator.displayName}, $handle';
    return Semantics(
      container: true,
      label: semanticsLabel,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            PostAvatar(url: moderator.photoUrl, size: 48),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    moderator.displayName,
                    softWrap: true,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      height: 1.25,
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
      ),
    );
  }
}
