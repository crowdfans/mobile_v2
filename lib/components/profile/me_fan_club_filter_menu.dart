import 'package:crowdfans/constants/theme.dart';
import 'package:crowdfans/models/fan_profile.dart';
import 'package:flutter/material.dart';

/// Lista de opções do filtro por fã-clube no Meu Perfil.
class MeFanClubFilterMenu extends StatelessWidget {
  const MeFanClubFilterMenu({
    super.key,
    required this.artists,
    required this.selectedId,
    required this.onSelect,
    required this.onClear,
  });

  final List<FollowedArtist> artists;
  final String? selectedId;
  final ValueChanged<FollowedArtist> onSelect;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    final colors = CrowdFansTheme.of(context);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          InkWell(
            key: const Key('me-fan-club-filter-all'),
            onTap: onClear,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              child: Text(
                'Todos os fã-clubes',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: selectedId == null
                      ? FontWeight.w700
                      : FontWeight.w500,
                  color: colors.textPrimary,
                ),
              ),
            ),
          ),
          for (final artist in artists) ...[
            Divider(height: 1, thickness: 0.5, color: colors.border),
            InkWell(
              key: Key('me-fan-club-filter-${artist.id}'),
              onTap: () => onSelect(artist),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 12,
                ),
                child: Text(
                  artist.label.trim().isEmpty ? 'Artista' : artist.label.trim(),
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: selectedId == artist.id
                        ? FontWeight.w700
                        : FontWeight.w500,
                    color: colors.textPrimary,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
