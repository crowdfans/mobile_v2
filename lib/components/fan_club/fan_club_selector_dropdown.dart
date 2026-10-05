import 'package:crowdfans/components/fan_club/fan_club_compose_artist.dart';
import 'package:crowdfans/components/fan_club/fan_club_selector_option_row.dart';
import 'package:crowdfans/constants/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// Altura útil da lista do seletor (CF-237) acima do teclado e da toolbar.
double fanClubSelectorListMaxHeight({
  required double screenHeight,
  required double keyboardInset,
  double chromeReserve = 200,
  double toolbarReserve = 56,
}) {
  final usable =
      screenHeight - keyboardInset - chromeReserve - toolbarReserve;
  return usable.clamp(120.0, 320.0).toDouble();
}

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
  final _queryController = TextEditingController();
  var _query = '';

  @override
  void dispose() {
    _queryController.dispose();
    super.dispose();
  }

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
    // Filtro síncrono: a consulta atual sempre substitui a anterior.
    setState(() => _query = value);
  }

  void handleClear() {
    _queryController.clear();
    setState(() => _query = '');
  }

  @override
  Widget build(BuildContext context) {
    final colors = CrowdFansTheme.of(context);
    final items = _filtered;
    final media = MediaQuery.of(context);
    final keyboard = media.viewInsets.bottom;
    final maxListHeight = fanClubSelectorListMaxHeight(
      screenHeight: media.size.height,
      keyboardInset: keyboard,
    );
    final resultLabel = items.isEmpty
        ? (_query.trim().isEmpty
              ? 'Nenhum fã clube disponível'
              : 'Nenhum fã clube encontrado')
        : '${items.length} fã ${items.length == 1 ? 'clube' : 'clubes'}';

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
            padding: const EdgeInsets.fromLTRB(14, 12, 8, 10),
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
                  child: Semantics(
                    label: 'Procurar fã clube',
                    textField: true,
                    child: TextField(
                      key: const Key('novo-post-club-search'),
                      controller: _queryController,
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
                ),
                if (_query.trim().isNotEmpty)
                  IconButton(
                    key: const Key('novo-post-club-search-clear'),
                    onPressed: handleClear,
                    tooltip: 'Limpar busca',
                    icon: Icon(
                      Icons.close,
                      size: 18,
                      color: colors.textSecondary,
                    ),
                  ),
              ],
            ),
          ),
          Divider(height: 1, thickness: 1, color: colors.border),
          Semantics(
            key: const Key('novo-post-club-results-status'),
            liveRegion: true,
            label: resultLabel,
            child: ConstrainedBox(
              constraints: BoxConstraints(maxHeight: maxListHeight),
              child: items.isEmpty
                  ? Padding(
                      padding: const EdgeInsets.all(16),
                      child: Text(
                        _query.trim().isEmpty
                            ? 'Nenhum fã clube disponível.'
                            : 'Nenhum fã clube encontrado.',
                        style: TextStyle(color: colors.textSecondary),
                      ),
                    )
                  : ListView.builder(
                      key: const Key('novo-post-club-results'),
                      shrinkWrap: true,
                      keyboardDismissBehavior:
                          ScrollViewKeyboardDismissBehavior.onDrag,
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
          ),
        ],
      ),
    );
  }
}
