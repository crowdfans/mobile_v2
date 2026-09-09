import 'package:crowdfans/components/profile/artist_me_tab_item.dart';
import 'package:crowdfans/constants/theme.dart';
import 'package:flutter/material.dart';

/// Barra de tabs Feed | Sobre | Exclusivo | Fã Clube | Cartas.
class ArtistMeTabBar extends StatelessWidget {
  const ArtistMeTabBar({
    super.key,
    required this.selectedId,
    required this.onSelected,
  });

  final String selectedId;
  final ValueChanged<String> onSelected;

  static const tabs = <(String, String)>[
    ('feed', 'Feed'),
    ('sobre', 'Sobre'),
    ('exclusivo', 'Exclusivo'),
    ('fanclub', 'Fã Clube'),
    ('cartas', 'Cartas'),
  ];

  @override
  Widget build(BuildContext context) {
    final colors = CrowdFansTheme.of(context);
    return ColoredBox(
      color: colors.background,
      child: SizedBox(
        height: 48,
        child: ListView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 8),
          children: [
            for (final entry in tabs)
              ArtistMeTabItem(
                label: entry.$2,
                selected: selectedId == entry.$1,
                onPressed: () => onSelected(entry.$1),
              ),
          ],
        ),
      ),
    );
  }
}
