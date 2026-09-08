import 'package:crowdfans/components/input/app_text_field.dart';
import 'package:crowdfans/components/search/search_artist_options_sheet.dart';
import 'package:crowdfans/components/search/search_artist_rank_row.dart';
import 'package:crowdfans/components/search/search_ranking_card.dart';
import 'package:crowdfans/constants/pages.dart';
import 'package:crowdfans/constants/theme.dart';
import 'package:crowdfans/services/search_service.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Explorar / busca de artistas.
class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  var _topArtists = <ArtistSearchItem>[];
  var _results = <ArtistSearchItem>[];
  var _query = '';
  var _loading = true;
  String? _error;
  ArtistSearchItem? _selected;

  @override
  void initState() {
    super.initState();
    handleLoadTop();
  }

  Future<void> handleLoadTop() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final data = await SearchService.rankArtists('fan-clubs', limit: 3);
      setState(() => _topArtists = data.artists);
    } catch (_) {
      setState(() => _error = 'Não foi possível carregar o ranking.');
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  Future<void> handleSearch(String query) async {
    _query = query;
    if (query.trim().isEmpty) {
      setState(() => _results = []);
      return;
    }
    setState(() => _loading = true);
    try {
      final data = await SearchService.searchArtists(query);
      setState(() {
        _results = data.artists;
        _error = null;
      });
    } catch (_) {
      setState(() => _error = 'Não foi possível buscar artistas.');
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  void handleOpenRanking(String kind) {
    context.push('${Pages.searchRanking}?kind=$kind');
  }

  @override
  Widget build(BuildContext context) {
    final colors = CrowdFansTheme.of(context);
    final searching = _query.trim().isNotEmpty;
    final list = searching ? _results : _topArtists;
    return Scaffold(
      backgroundColor: colors.background,
      body: Stack(
        children: [
          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Explorar',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w800,
                          color: colors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 12),
                      AppTextField(
                        hint: 'Buscar artistas',
                        onChanged: handleSearch,
                      ),
                    ],
                  ),
                ),
                if (!searching)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                    child: Row(
                      children: [
                        SearchRankingCard(
                          title: 'Top Fã Clubes',
                          subtitle: 'Mais seguidores',
                          onPressed: () => handleOpenRanking('fan-clubs'),
                        ),
                        const SizedBox(width: 8),
                        SearchRankingCard(
                          title: 'Top Ativos',
                          subtitle: 'Atividade nas últimas 24h',
                          onPressed: () => handleOpenRanking('active'),
                        ),
                        const SizedBox(width: 8),
                        SearchRankingCard(
                          title: 'Top Engajados',
                          subtitle: 'Posts recentes',
                          onPressed: () => handleOpenRanking('engaged'),
                        ),
                      ],
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
                      : ListView.builder(
                          padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                          itemCount: list.length,
                          itemBuilder: (context, index) {
                            final artist = list[index];
                            return SearchArtistRankRow(
                              artist: artist,
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
