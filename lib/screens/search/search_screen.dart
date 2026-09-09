import 'dart:async';

import 'package:crowdfans/components/input/app_text_field.dart';
import 'package:crowdfans/components/search/search_artist_options_sheet.dart';
import 'package:crowdfans/components/search/search_artist_rank_row.dart';
import 'package:crowdfans/components/search/search_discovery_tile.dart';
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
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    handleLoadTop();
  }

  @override
  void dispose() {
    _debounce?.cancel();
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
    _query = query;
    _debounce?.cancel();
    if (query.trim().isEmpty) {
      setState(() {
        _results = [];
        _error = null;
      });
      return;
    }
    _debounce = Timer(const Duration(milliseconds: 350), () {
      handleSearch(query);
    });
  }

  Future<void> handleSearch(String query) async {
    if (query.trim().isEmpty) {
      setState(() => _results = []);
      return;
    }
    setState(() => _loading = true);
    try {
      final data = await SearchService.searchArtists(query, limit: 30);
      if (!mounted || _query.trim() != query.trim()) {
        return;
      }
      setState(() {
        _results = data.artists;
        _error = null;
        _loading = false;
      });
    } catch (_) {
      if (!mounted || _query.trim() != query.trim()) {
        return;
      }
      setState(() {
        _loading = false;
        _error = 'Não foi possível buscar artistas.';
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
                  child: AppTextField(
                    hint: 'Buscar artista',
                    onChanged: handleQueryChanged,
                  ),
                ),
                if (!searching) ...[
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
                if (!searching)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                    child: Row(
                      children: [
                        SearchDiscoveryTile(
                          title: 'Top 100\nEngajados',
                          accent: AppPalette.purple100,
                          onPressed: () => handleOpenRanking('engaged'),
                        ),
                        const SizedBox(width: 10),
                        SearchDiscoveryTile(
                          title: 'Top 500\nAtivos',
                          accent: AppPalette.blue50,
                          onPressed: () => handleOpenRanking('active'),
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
                if (searching)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                    child: Text(
                      'Resultados',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: colors.textPrimary,
                      ),
                    ),
                  ),
                Expanded(
                  child: _loading
                      ? const Center(child: CircularProgressIndicator())
                      : RefreshIndicator(
                          onRefresh: handleRefresh,
                          child: list.isEmpty
                              ? ListView(
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.only(top: 40),
                                      child: Text(
                                        searching
                                            ? 'Nenhum artista encontrado.'
                                            : 'Nada no ranking ainda.',
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
                                  itemCount: list.length,
                                  itemBuilder: (context, index) {
                                    final artist = list[index];
                                    return SearchArtistRankRow(
                                      artist: artist,
                                      position: searching
                                          ? null
                                          : (artist.rank ?? index + 1),
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
