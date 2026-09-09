import 'package:crowdfans/constants/theme.dart';
import 'package:flutter/material.dart';

/// Identidade do Fã Clube sob o cover: nome, membros, favorito, Ver mais / Regras.
class FanClubCommunityHero extends StatelessWidget {
  const FanClubCommunityHero({
    super.key,
    required this.artistName,
    required this.memberCount,
    required this.isFavorite,
    required this.onToggleFavorite,
    required this.onOpenArtist,
    required this.onAbout,
    required this.onRules,
  });

  final String artistName;
  final int memberCount;
  final bool isFavorite;
  final VoidCallback onToggleFavorite;
  final VoidCallback onOpenArtist;
  final VoidCallback onAbout;
  final VoidCallback onRules;

  static String formatMemberCount(int count) {
    return count.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (match) => '${match[1]}.',
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = CrowdFansTheme.of(context);
    final name = artistName.trim().isEmpty ? 'Artista' : artistName.trim();
    final members = formatMemberCount(memberCount);
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 8, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    InkWell(
                      onTap: onOpenArtist,
                      child: Row(
                        children: [
                          Flexible(
                            child: Text.rich(
                              TextSpan(
                                children: [
                                  TextSpan(
                                    text: name,
                                    style: TextStyle(
                                      fontSize: 28,
                                      fontWeight: FontWeight.w600,
                                      color: colors.textPrimary,
                                    ),
                                  ),
                                  TextSpan(
                                    text: ' Fã Clube',
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.w500,
                                      color: colors.textTertiary,
                                    ),
                                  ),
                                ],
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Icon(
                            Icons.chevron_right_rounded,
                            size: 22,
                            color: colors.textTertiary,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text.rich(
                      TextSpan(
                        children: [
                          TextSpan(
                            text: members,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: colors.textPrimary,
                            ),
                          ),
                          TextSpan(
                            text: ' membros',
                            style: TextStyle(
                              fontSize: 14,
                              color: colors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                key: const Key('fan-club-favorite'),
                onPressed: onToggleFavorite,
                tooltip: isFavorite ? 'Remover dos favoritos' : 'Favoritar',
                icon: Icon(
                  isFavorite ? Icons.star : Icons.star_border,
                  size: 28,
                  color: isFavorite
                      ? AppPalette.yellow500
                      : colors.textTertiary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              TextButton(
                key: const Key('fan-club-ver-mais'),
                onPressed: onAbout,
                style: TextButton.styleFrom(
                  foregroundColor: AppPalette.blue500,
                  padding: EdgeInsets.zero,
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: const Text(
                  'Ver mais',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                ),
              ),
              const SizedBox(width: 22),
              TextButton(
                key: const Key('fan-club-regras'),
                onPressed: onRules,
                style: TextButton.styleFrom(
                  foregroundColor: AppPalette.blue500,
                  padding: EdgeInsets.zero,
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: const Text(
                  'Regras',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
