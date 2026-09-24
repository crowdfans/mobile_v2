import 'package:crowdfans/components/post/post_avatar.dart';
import 'package:crowdfans/constants/theme.dart';
import 'package:flutter/material.dart';

/// Cabeçalho compacto do fã-clube na aba do perfil do artista.
class ArtistProfileFanClubHeader extends StatelessWidget {
  const ArtistProfileFanClubHeader({
    super.key,
    required this.artistName,
    required this.avatarUrl,
    this.memberCount,
  });

  final String artistName;
  final String avatarUrl;
  final int? memberCount;

  @override
  Widget build(BuildContext context) {
    final colors = CrowdFansTheme.of(context);
    final name = artistName.trim().isEmpty ? 'Artista' : artistName.trim();
    final members = memberCount;
    final membersLabel = members == null
        ? null
        : members <= 0
        ? 'Sem membros ainda'
        : members == 1
        ? '1 membro'
        : '$members membros';
    return Semantics(
      header: true,
      label: '$name Fã Clube${membersLabel == null ? '' : ', $membersLabel'}',
      child: Row(
        children: [
          PostAvatar(url: avatarUrl, size: 40),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                RichText(
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: name,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: colors.textPrimary,
                        ),
                      ),
                      TextSpan(
                        text: ' Fã Clube',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: colors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                if (membersLabel != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    membersLabel,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
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
