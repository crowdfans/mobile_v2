import 'dart:async';

import 'package:crowdfans/components/search/search_artist_options_sheet.dart';
import 'package:crowdfans/components/search/search_artist_rank_row.dart';
import 'package:crowdfans/components/search/search_artist_result_row.dart';
import 'package:crowdfans/components/search/search_artists_chrome.dart';
import 'package:crowdfans/components/search/search_discovery_tile.dart';
import 'package:crowdfans/components/search/search_query_field.dart';
import 'package:crowdfans/constants/pages.dart';
import 'package:crowdfans/constants/theme.dart';
import 'package:crowdfans/mocks/cf_temp_mocks.dart';
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
  final _queryController = TextEditingController();
  var _topArtists = <ArtistSearchItem>[];
  var _results = <ArtistSearchItem>[];
  var _query = '';
  var _loading = true;
  var _searchingBusy = false;
  String? _error;
  ArtistSearchItem? _selected;
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    handleLoadTop();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _queryController.dispose();
    super.dispose();
  }

  Future<void> handleLoadTop() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final data = await SearchService.rankArtists('fan-clubs', limit: 3);
      if (!mounted) {
        return;
      }
      setState(() {
        _topArtists = data.artists;
        _loading = false;
      });
    } catch (_) {
      if (!mounted) {
        return;
      }
      setState(() {
        _loading = false;
        _error = 'Não foi possível carregar o ranking.';
      });
    }
  }

  void handleQueryChanged(String query) {
    setState(() => _query = query);
    _debounce?.cancel();
    if (query.trim().isEmpty) {
      setState(() {
        _results = [];
        _error = null;
        _searchingBusy = false;
      });
      return;
    }
    setState(() => _searchingBusy = true);
    _debounce = Timer(const Duration(milliseconds: 350), () {
      handleSearch(query);
    });
  }

  void handleClearQuery() {
    _debounce?.cancel();
    _queryController.clear();
    setState(() {
      _query = '';
      _results = [];
      _error = null;
      _searchingBusy = false;
    });
  }

  /// Voltar do chrome de resultados: limpa a busca (aba Explorar).
  void handleBackFromSearch() {
    if (_query.trim().isNotEmpty) {
      handleClearQuery();
      return;
    }
    if (context.canPop()) {
      context.pop();
    }
  }

  Future<void> handleSearch(String query) async {
    if (query.trim().isEmpty) {
      setState(() {
        _results = [];
        _searchingBusy = false;
      });
      return;
    }
    setState(() {
      _searchingBusy = true;
      _error = null;
    });
    try {
      if (kUseCfTempMocks && CfTempMocks.useSearchArtistsFixtures) {
        final mocked = cfTempMockSearchArtists(query);
        if (mocked != null) {
          if (!mounted || _query.trim() != query.trim()) {
            return;
          }
          setState(() {
            _results = mocked;
            _error = null;
            _searchingBusy = false;
          });
          return;
        }
      }
      final data = await SearchService.searchArtists(query, limit: 30);
      if (!mounted || _query.trim() != query.trim()) {
        return;
      }
      var artists = data.artists;
      if (artists.isEmpty &&
          kUseCfTempMocks &&
          CfTempMocks.useSearchArtistsFixtures) {
        artists = cfTempMockSearchArtists(query) ?? artists;
      }
      setState(() {
        _results = artists;
        _error = null;
        _searchingBusy = false;
      });
    } catch (_) {
      if (!mounted || _query.trim() != query.trim()) {
        return;
      }
      final mocked = kUseCfTempMocks && CfTempMocks.useSearchArtistsFixtures
          ? cfTempMockSearchArtists(query)
          : null;
      setState(() {
        if (mocked != null) {
          _results = mocked;
          _error = null;
        } else {
          _error = 'Não foi possível buscar artistas.';
        }
        _searchingBusy = false;
      });
    }
  }

  Future<void> handleRefresh() async {
    if (_query.trim().isNotEmpty) {
      await handleSearch(_query);
      return;
    }
    await handleLoadTop();
  }

  void handleOpenRanking(String kind) {
    context.push('${Pages.searchRanking}?kind=$kind');
  }

  @override
  Widget build(BuildContext context) {
    final colors = CrowdFansTheme.of(context);
    final searching = _query.trim().isNotEmpty;
    final keyboard = MediaQuery.viewInsetsOf(context).bottom;
    final list = searching ? _results : _topArtists;
    final listBusy = searching ? _searchingBusy : _loading;

    return Scaffold(
      backgroundColor: searching ? colors.surfaceAlt : colors.background,
      resizeToAvoidBottomInset: true,
      body: Stack(
        children: [
          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (searching)
                  SearchArtistsChrome(
                    controller: _queryController,
                    onBack: handleBackFromSearch,
                    onChanged: handleQueryChanged,
                    showClear: true,
                    onClear: handleClearQuery,
                  )
                else ...[
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                    child: SearchQueryField(
                      controller: _queryController,
                      hint: 'Buscar artista',
                      onChanged: handleQueryChanged,
                      showClear: false,
                      onClear: handleClearQuery,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            'Top 500 Fã Clubes',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                              color: colors.textPrimary,
                            ),
                          ),
                        ),
                        TextButton(
                          onPressed: () => handleOpenRanking('fan-clubs'),
                          child: Text(
                            'ver todos',
                            style: TextStyle(
                              color: colors.primary,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                if (searching && !_searchingBusy && _error == null)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                    child: Text(
                      list.isEmpty
                          ? 'Nenhum resultado'
                          : '${list.length} resultado${list.length == 1 ? '' : 's'}',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: colors.textSecondary,
                      ),
                    ),
                  ),
                if (_error != null)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                    child: Text(
                      _error!,
                      style: TextStyle(color: colors.danger),
                    ),
                  ),
                Expanded(
                  child: listBusy
                      ? const Center(child: CircularProgressIndicator())
                      : RefreshIndicator(
                          onRefresh: handleRefresh,
                          child: list.isEmpty
                              ? ListView(
                                  padding: EdgeInsets.only(
                                    bottom: 24 + keyboard,
                                  ),
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.only(top: 40),
                                      child: Text(
                                        _error != null
                                            ? 'Tente novamente em instantes.'
                                            : searching
                                            ? 'Nenhum artista encontrado.'
                                            : 'Nada no ranking ainda.',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          color: colors.textSecondary,
                                        ),
                                      ),
                                    ),
                                    if (!searching) _discoveryRow(),
                                  ],
                                )
                              : ListView.builder(
                                  padding: EdgeInsets.fromLTRB(
                                    16,
                                    0,
                                    16,
                                    24 + keyboard,
                                  ),
                                  itemCount: list.length + (searching ? 0 : 1),
                                  itemBuilder: (context, index) {
                                    if (!searching && index == list.length) {
                                      return Padding(
                                        padding: const EdgeInsets.only(top: 8),
                                        child: _discoveryRow(),
                                      );
                                    }
                                    final artist = list[index];
                                    final openProfile = () => context.push(
                                      Pages.artistProfile.replaceAll(
                                        ':artistId',
                                        artist.id,
                                      ),
                                    );
                                    final openMore = () {
                                      setState(() => _selected = artist);
                                    };
                                    if (searching) {
                                      return SearchArtistResultRow(
                                        artist: artist,
                                        position: artist.rank,
                                        onPressed: openProfile,
                                        onPressMore: openMore,
                                      );
                                    }
                                    return SearchArtistRankRow(
                                      artist: artist,
                                      position: artist.rank ?? index + 1,
                                      onPressed: openProfile,
                                      onPressMore: openMore,
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

  Widget _discoveryRow() {
    return Row(
      children: [
        SearchDiscoveryTile(
          title: 'Top 100\nEngajados',
          imageAsset: 'assets/images/search/top_100_engajados.png',
          onPressed: () => handleOpenRanking('engaged'),
        ),
        const SizedBox(width: 10),
        SearchDiscoveryTile(
          title: 'Top 500\nAtivos',
          imageAsset: 'assets/images/search/top_500_ativos.png',
          onPressed: () => handleOpenRanking('active'),
        ),
      ],
    );
  }
}
