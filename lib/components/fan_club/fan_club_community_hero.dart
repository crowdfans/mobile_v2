import 'package:crowdfans/constants/theme.dart';
import 'package:flutter/material.dart';

/// Identidade do Fã Clube sob o cover: nome, membros, favorito, Ver mais / Regras.
///
/// Print CF-222: `Enzo Lima` + `Fã Clube >` na mesma linha; estrela à direita;
/// `11.841 membros` abaixo; links azuis Ver mais / Regras.
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
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: InkWell(
                  onTap: onOpenArtist,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Flexible(
                        child: Text(
                          name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.w700,
                            height: 1.15,
                            color: colors.textPrimary,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Fã Clube',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: colors.textTertiary,
                        ),
                      ),
                      Icon(
                        Icons.chevron_right_rounded,
                        size: 20,
                        color: colors.textTertiary,
                      ),
                    ],
                  ),
                ),
              ),
              IconButton(
                key: const Key('fan-club-favorite'),
                onPressed: onToggleFavorite,
                tooltip: isFavorite ? 'Remover dos favoritos' : 'Favoritar',
                icon: Semantics(
                  label: isFavorite
                      ? 'Fã-clube favoritado'
                      : 'Favoritar fã-clube',
                  checked: isFavorite,
                  child: Icon(
                    isFavorite ? Icons.star : Icons.star_border,
                    size: 28,
                    color: isFavorite
                        ? AppPalette.yellow500
                        : colors.textTertiary,
                  ),
                ),
              ),
            ],
          ),
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
