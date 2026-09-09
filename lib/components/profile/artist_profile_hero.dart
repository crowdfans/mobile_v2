import 'package:crowdfans/components/post/post_avatar.dart';
import 'package:crowdfans/constants/theme.dart';
import 'package:flutter/material.dart';

/// Hero do perfil público do artista (avatar, nome, rank, meta).
class ArtistProfileHero extends StatelessWidget {
  const ArtistProfileHero({
    super.key,
    required this.displayName,
    required this.handle,
    required this.avatarUrl,
    required this.meta,
    this.rank,
  });

  final String displayName;
  final String handle;
  final String avatarUrl;
  final String meta;
  final int? rank;

  @override
  Widget build(BuildContext context) {
    final colors = CrowdFansTheme.of(context);
    return Row(
      children: [
        PostAvatar(url: avatarUrl, size: 80),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Flexible(
                    child: Text(
                      displayName,
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: colors.textPrimary,
                      ),
                    ),
                  ),
                  if (rank != null) ...[
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: colors.surfaceAlt,
                        borderRadius: BorderRadius.circular(999),
                        border: Border.all(color: colors.border),
                      ),
                      child: Text(
                        '#$rank',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                          color: colors.primary,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
              Text(
                handle,
                style: TextStyle(fontSize: 14, color: colors.textSecondary),
              ),
              if (meta.isNotEmpty) ...[
                const SizedBox(height: 4),
                Text(
                  meta,
                  style: TextStyle(fontSize: 13, color: colors.textTertiary),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}
