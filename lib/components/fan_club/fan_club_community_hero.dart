import 'package:crowdfans/components/buttons/app_button.dart';
import 'package:crowdfans/components/post/post_avatar.dart';
import 'package:crowdfans/constants/theme.dart';
import 'package:crowdfans/services/fan_club_service.dart';
import 'package:flutter/material.dart';

/// Cabeçalho da comunidade do artista.
class FanClubCommunityHero extends StatelessWidget {
  const FanClubCommunityHero({
    super.key,
    required this.club,
    required this.following,
    required this.onToggleFollow,
    required this.onCompose,
    required this.onAbout,
    required this.onRules,
    this.avatarUrl = '',
  });

  final ArtistFanClub club;
  final bool following;
  final VoidCallback onToggleFollow;
  final VoidCallback onCompose;
  final VoidCallback onAbout;
  final VoidCallback onRules;
  final String avatarUrl;

  @override
  Widget build(BuildContext context) {
    final colors = CrowdFansTheme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              PostAvatar(url: avatarUrl, size: 72),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      club.artistName.isEmpty ? club.name : club.artistName,
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: colors.textPrimary,
                      ),
                    ),
                    Text(
                      '${club.memberCount} membros',
                      style: TextStyle(
                        fontSize: 13,
                        color: colors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (club.description.isNotEmpty) ...[
            const SizedBox(height: 12),
            Text(
              club.description,
              style: TextStyle(fontSize: 14, color: colors.textSecondary),
            ),
          ],
          const SizedBox(height: 12),
          AppButton(
            label: following ? 'Seguindo' : 'Seguir',
            variant: following
                ? AppButtonVariant.outline
                : AppButtonVariant.primary,
            onPressed: onToggleFollow,
          ),
          const SizedBox(height: 8),
          AppButton(
            label: 'Publicar no clube',
            variant: AppButtonVariant.outline,
            onPressed: onCompose,
          ),
          const SizedBox(height: 8),
          AppButton(
            label: 'Sobre o Fã Clube',
            variant: AppButtonVariant.outline,
            onPressed: onAbout,
          ),
          const SizedBox(height: 8),
          AppButton(
            label: 'Regras do Fã Clube',
            variant: AppButtonVariant.outline,
            onPressed: onRules,
          ),
        ],
      ),
    );
  }
}
