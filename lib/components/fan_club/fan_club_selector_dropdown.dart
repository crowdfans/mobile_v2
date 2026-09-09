import 'package:crowdfans/components/fan_club/fan_club_compose_artist.dart';
import 'package:crowdfans/components/fan_club/fan_club_selector_option_row.dart';
import 'package:crowdfans/constants/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// Lista pesquisável de fã clubes sob o seletor do composer.
class FanClubSelectorDropdown extends StatefulWidget {
  const FanClubSelectorDropdown({
    super.key,
    required this.artists,
    required this.selectedId,
    required this.onSelect,
  });

  final List<FanClubComposeArtist> artists;
  final String? selectedId;
  final ValueChanged<FanClubComposeArtist> onSelect;

  @override
  State<FanClubSelectorDropdown> createState() =>
      _FanClubSelectorDropdownState();
}

class _FanClubSelectorDropdownState extends State<FanClubSelectorDropdown> {
  var _query = '';

  List<FanClubComposeArtist> get _filtered {
    final q = _query.trim().toLowerCase();
    if (q.isEmpty) {
      return widget.artists;
    }
    return [
      for (final artist in widget.artists)
        if (artist.name.toLowerCase().contains(q)) artist,
    ];
  }

  void handleQueryChange(String value) {
    setState(() => _query = value);
  }

  @override
  Widget build(BuildContext context) {
    final colors = CrowdFansTheme.of(context);
    final items = _filtered;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colors.border),
        boxShadow: [
          BoxShadow(
            color: colors.textPrimary.withValues(alpha: 0.08),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 10),
            child: Row(
              children: [
                SvgPicture.asset(
                  'assets/icons/General/search-sm.svg',
                  width: 18,
                  height: 18,
                  colorFilter: ColorFilter.mode(
                    colors.textTertiary,
                    BlendMode.srcIn,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: TextField(
                    key: const Key('novo-post-club-search'),
                    autofocus: true,
                    onChanged: handleQueryChange,
                    style: TextStyle(fontSize: 15, color: colors.textPrimary),
                    decoration: InputDecoration(
                      isDense: true,
                      border: InputBorder.none,
                      hintText: 'Procurar Fã Clube',
                      hintStyle: TextStyle(color: colors.textTertiary),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Divider(height: 1, thickness: 1, color: colors.border),
          ConstrainedBox(
            constraints: const BoxConstraints(maxHeight: 260),
            child: items.isEmpty
                ? Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text(
                      'Nenhum fã clube encontrado.',
                      style: TextStyle(color: colors.textSecondary),
                    ),
                  )
                : ListView.builder(
                    shrinkWrap: true,
                    itemCount: items.length,
                    itemBuilder: (context, index) {
                      final artist = items[index];
                      return FanClubSelectorOptionRow(
                        artist: artist,
                        selected: artist.id == widget.selectedId,
                        onPressed: () => widget.onSelect(artist),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
