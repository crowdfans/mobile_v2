import 'package:crowdfans/components/search/search_artist_options_sheet.dart';
import 'package:crowdfans/components/search/search_artist_rank_row.dart';
import 'package:crowdfans/components/toolbar/text_toolbar.dart';
import 'package:crowdfans/components/toolbar/toolbar_back_button.dart';
import 'package:crowdfans/constants/pages.dart';
import 'package:crowdfans/constants/theme.dart';
import 'package:crowdfans/services/search_service.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

String _rankingTitle(String kind) {
  return switch (kind) {
    'active' => 'Top Ativos',
    'engaged' => 'Top Engajados',
    _ => 'Top Fã Clubes',
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

  @override
  Widget build(BuildContext context) {
    final colors = CrowdFansTheme.of(context);
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
                  child: TextToolbar(
                    title: _rankingTitle(_kind),
                    leading: ToolbarBackButton(onPressed: () => context.pop()),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                  child: Text(
                    _rankingSubtitle(_kind),
                    style: TextStyle(fontSize: 13, color: colors.textSecondary),
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
                          child: _artists.isEmpty
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
                                  itemCount: _artists.length,
                                  itemBuilder: (context, index) {
                                    final artist = _artists[index];
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
