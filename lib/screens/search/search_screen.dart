import 'package:crowdfans/components/input/app_text_field.dart';
import 'package:crowdfans/components/post/post_avatar.dart';
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
  var _artists = <ArtistSearchItem>[];
  var _loading = true;
  String? _error;
  final _kind = 'fan-clubs';

  @override
  void initState() {
    super.initState();
    handleLoadRanking();
  }

  Future<void> handleLoadRanking() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final data = await SearchService.rankArtists(_kind);
      setState(() => _artists = data.artists);
    } catch (_) {
      setState(() => _error = 'Não foi possível carregar o ranking.');
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  Future<void> handleSearch(String query) async {
    if (query.trim().isEmpty) {
      await handleLoadRanking();
      return;
    }
    setState(() => _loading = true);
    try {
      final data = await SearchService.searchArtists(query);
      setState(() {
        _artists = data.artists;
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

  @override
  Widget build(BuildContext context) {
    final colors = CrowdFansTheme.of(context);
    return Scaffold(
      backgroundColor: colors.background,
      body: SafeArea(
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
                    onChanged: (value) {
                      handleSearch(value);
                    },
                  ),
                ],
              ),
            ),
            if (_error != null)
              Padding(
                padding: const EdgeInsets.all(16),
                child: Text(_error!, style: TextStyle(color: colors.danger)),
              ),
            Expanded(
              child: _loading
                  ? const Center(child: CircularProgressIndicator())
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: _artists.length,
                      itemBuilder: (context, index) {
                        final artist = _artists[index];
                        return ListTile(
                          leading: PostAvatar(url: artist.avatarUri, size: 48),
                          title: Text(artist.name),
                          subtitle: Text(
                            artist.membersLabel.isEmpty
                                ? artist.handle
                                : artist.membersLabel,
                          ),
                          onTap: () => context.push(
                            Pages.artistProfile.replaceAll(
                              ':artistId',
                              artist.id,
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
