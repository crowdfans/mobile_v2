import 'package:crowdfans/components/post/post_avatar.dart';
import 'package:crowdfans/components/profile/profile_stat_cell.dart';
import 'package:crowdfans/constants/theme.dart';
import 'package:crowdfans/models/profile.dart';
import 'package:flutter/material.dart';

/// Identidade + stats do perfil na aba Eu.
class ProfileIdentityBlock extends StatelessWidget {
  const ProfileIdentityBlock({super.key, required this.profile});

  final Profile profile;

  @override
  Widget build(BuildContext context) {
    final colors = CrowdFansTheme.of(context);
    final handle = profile.name.trim().isEmpty
        ? ''
        : '@${profile.name.replaceAll(RegExp(r'^@'), '')}';
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            PostAvatar(url: profile.photoUrl, size: 92),
            const SizedBox(width: 18),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    profile.displayName.isEmpty ? 'Eu' : profile.displayName,
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: colors.textPrimary,
                    ),
                  ),
                  if (handle.isNotEmpty)
                    Text(
                      handle,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: colors.textSecondary,
                      ),
                    ),
                  if (profile.isArtist)
                    Padding(
                      padding: const EdgeInsets.only(top: 6),
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          color: colors.surfaceAlt,
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 9,
                            vertical: 4,
                          ),
                          child: Text(
                            'Artista',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: colors.textPrimary,
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 22),
        DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: colors.border),
          ),
          child: Row(
            children: [
              ProfileStatCell(
                value: '${profile.stats.postsCount}',
                label: 'Posts',
              ),
              ProfileStatCell(
                value: '${profile.stats.cartasCount}',
                label: 'Cartas',
                divider: true,
              ),
              ProfileStatCell(
                value: '${profile.stats.artistasCount}',
                label: 'Artistas',
                divider: true,
              ),
            ],
          ),
        ),
        if (profile.description.trim().isNotEmpty) ...[
          const SizedBox(height: 18),
          Text(
            profile.description,
            style: TextStyle(
              fontSize: 14,
              height: 21 / 14,
              color: colors.textPrimary,
            ),
          ),
        ],
      ],
    );
  }
}
