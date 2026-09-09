import 'package:crowdfans/components/search/search_artist_options_sheet.dart';
import 'package:crowdfans/components/search/search_artist_rank_row.dart';
import 'package:crowdfans/components/search/search_rank_sort_chip.dart';
import 'package:crowdfans/components/toolbar/toolbar_back_button.dart';
import 'package:crowdfans/constants/pages.dart';
import 'package:crowdfans/constants/theme.dart';
import 'package:crowdfans/services/search_service.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

String _rankingLead(String kind) {
  return switch (kind) {
    'active' => 'Top 500',
    'engaged' => 'Top 100',
    _ => 'Top 500',
  };
}

String _rankingSubtitle(String kind) {
  return switch (kind) {
    'active' => 'Atividade e interações nas últimas 24 horas',
    'engaged' => 'Artistas com mais posts nas últimas 24 horas',
    _ => 'Artistas com mais seguidores / assinantes',
  };
}

int _rankingLimit(String kind) => kind == 'engaged' ? 100 : 500;

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
    try {
      final data = await SearchService.rankArtists(
        _kind,
        limit: _rankingLimit(_kind),
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
                          child: RichText(
                            textAlign: TextAlign.center,
                            text: TextSpan(
                              children: [
                                TextSpan(
                                  text: _rankingLead(_kind),
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w800,
                                    color: colors.textPrimary,
                                  ),
                                ),
                                TextSpan(
                                  text: ' · Brasil',
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
                    'Ordenar postagens por:',
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
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                  child: Text(
                    _rankingSubtitle(_kind),
                    style: TextStyle(fontSize: 12, color: colors.textTertiary),
                  ),
                ),
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
                                      onPressed: () => context.push(
                                        Pages.artistProfile.replaceAll(
                                          ':artistId',
                                          artist.id,
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
          SearchArtistOptionsSheet(
            visible: _selected != null,
            artist: _selected,
            onClose: () => setState(() => _selected = null),
          ),
        ],
      ),
    );
  }
}
