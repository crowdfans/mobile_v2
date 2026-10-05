import 'package:crowdfans/components/search/search_artist_rank_details_sheet.dart';
import 'package:crowdfans/components/search/search_artist_rank_row.dart';
import 'package:crowdfans/components/search/search_rank_sort_chip.dart';
import 'package:crowdfans/components/toolbar/toolbar_back_button.dart';
import 'package:crowdfans/constants/pages.dart';
import 'package:crowdfans/constants/theme.dart';
import 'package:crowdfans/services/search_service.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Chrome do ranking — critério alinhado ao backend
/// (`search_service.go`: engaged = interações 7d; active = posts 7d).
String rankingLeadForKind(String kind) {
  return switch (kind) {
    'active' => 'Top 500',
    'engaged' => 'Top 100',
    _ => 'Top 500',
  };
}

String rankingQualifierForKind(String kind) {
  return switch (kind) {
    'active' => 'Ativos',
    'engaged' => 'Engajados',
    _ => 'Brasil',
  };
}

String rankingSubtitleForKind(String kind) {
  return switch (kind) {
    'active' => 'Artistas com mais posts nos últimos 7 dias',
    'engaged' => 'Artistas com mais interações nos últimos 7 dias',
    _ => 'Artistas com mais seguidores / assinantes',
  };
}

String rankingMetricHintForKind(String kind) {
  return switch (kind) {
    'active' => 'posts (7d)',
    'engaged' => 'interações (7d)',
    _ => 'membros',
  };
}

/// CF-193: Engajados/Ativos ordenam por métrica, não por “postagens”.
/// CF-189 print Top 500 mantém o rótulo do mock.
String rankingSortLabelForKind(String kind) {
  return switch (kind) {
    'engaged' || 'active' => 'Ordenar por:',
    _ => 'Ordenar postagens por:',
  };
}

int rankingLimitForKind(String kind) => kind == 'engaged' ? 100 : 500;

/// Lista completa de ranking de artistas.
class SearchRankingScreen extends StatefulWidget {
  const SearchRankingScreen({super.key, required this.kind});

  final String kind;

  @override
  State<SearchRankingScreen> createState() => _SearchRankingScreenState();
}

class _SearchRankingScreenState extends State<SearchRankingScreen> {
  var _artists = <ArtistSearchItem>[];
  var _loading = true;
  var _ascending = true;
  String? _error;
  ArtistSearchItem? _selected;

  String get _kind {
    final raw = widget.kind;
    if (raw == 'active' || raw == 'engaged' || raw == 'fan-clubs') {
      return raw;
    }
    return 'fan-clubs';
  }

  @override
  void initState() {
    super.initState();
    handleLoad();
  }

  Future<void> handleLoad() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    // CF-189/CF-268: sempre API real (`…/search/artists/rankings`).
    // Fixtures TEMP removidas da UI — amostra só em testes.
    try {
      final data = await SearchService.rankArtists(
        _kind,
        limit: rankingLimitForKind(_kind),
      );
      setState(() => _artists = data.artists);
    } catch (_) {
      setState(() => _error = 'Não foi possível carregar o ranking.');
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  List<ArtistSearchItem> sortedArtists() {
    final list = [..._artists];
    list.sort((a, b) {
      final ra = a.rank ?? 0;
      final rb = b.rank ?? 0;
      return _ascending ? ra.compareTo(rb) : rb.compareTo(ra);
    });
    return list;
  }

  @override
  Widget build(BuildContext context) {
    final colors = CrowdFansTheme.of(context);
    final artists = sortedArtists();
    return Scaffold(
      backgroundColor: colors.background,
      body: Stack(
        children: [
          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: SizedBox(
                    height: 56,
                    child: Row(
                      children: [
                        ToolbarBackButton(onPressed: () => context.pop()),
                        Expanded(
                          child: Semantics(
                            header: true,
                            label:
                                '${rankingLeadForKind(_kind)} ${rankingQualifierForKind(_kind)}. ${rankingSubtitleForKind(_kind)}',
                            child: RichText(
                              textAlign: TextAlign.center,
                              text: TextSpan(
                                children: [
                                  TextSpan(
                                    text: rankingLeadForKind(_kind),
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w800,
                                      color: colors.textPrimary,
                                    ),
                                  ),
                                  TextSpan(
                                    text:
                                        ' · ${rankingQualifierForKind(_kind)}',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                      color: colors.textSecondary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        IconButton(
                          onPressed: () => context.push(Pages.explore),
                          tooltip: 'Buscar',
                          icon: Icon(Icons.search, color: colors.textPrimary),
                        ),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 4),
                  child: Text(
                    rankingSortLabelForKind(_kind),
                    style: TextStyle(
                      fontSize: 13,
                      color: colors.textSecondary,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                  child: Row(
                    children: [
                      SearchRankSortChip(
                        label: 'Crescente',
                        selected: _ascending,
                        onPressed: () => setState(() => _ascending = true),
                      ),
                      const SizedBox(width: 8),
                      SearchRankSortChip(
                        label: 'Decrescente',
                        selected: !_ascending,
                        onPressed: () => setState(() => _ascending = false),
                      ),
                    ],
                  ),
                ),
                // Print CF-189: sem linha explicativa sob os chips; métrica/
                // período ficam no Semantics do título e em cada linha.
                if (_error != null)
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text(
                      _error!,
                      style: TextStyle(color: colors.danger),
                    ),
                  ),
                Expanded(
                  child: _loading
                      ? const Center(child: CircularProgressIndicator())
                      : RefreshIndicator(
                          onRefresh: handleLoad,
                          child: artists.isEmpty
                              ? ListView(
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.only(top: 40),
                                      child: Text(
                                        'Nenhum artista neste ranking ainda.',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          color: colors.textSecondary,
                                        ),
                                      ),
                                    ),
                                  ],
                                )
                              : ListView.builder(
                                  padding: const EdgeInsets.fromLTRB(
                                    16,
                                    0,
                                    16,
                                    24,
                                  ),
                                  itemCount: artists.length,
                                  itemBuilder: (context, index) {
                                    final artist = artists[index];
                                    return SearchArtistRankRow(
                                      artist: artist,
                                      position: artist.rank ?? index + 1,
                                      metricHint:
                                          rankingMetricHintForKind(_kind),
                                      layout:
                                          SearchArtistRankRowLayout.rankLeading,
                                      onPressed: () => context.push(
                                        Pages.artistProfileOf(
                                          artist.id,
                                          name: artist.name,
                                          avatarUrl: artist.avatarUri,
                                        ),
                                      ),
                                      onPressMore: () {
                                        setState(() => _selected = artist);
                                      },
                                    );
                                  },
                                ),
                        ),
                ),
              ],
            ),
          ),
          SearchArtistRankDetailsSheet(
            visible: _selected != null,
            artist: _selected,
            onClose: () => setState(() => _selected = null),
          ),
        ],
      ),
    );
  }
}
