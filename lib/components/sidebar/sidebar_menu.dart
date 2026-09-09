import 'package:crowdfans/components/sidebar/sidebar_artist_row.dart';
import 'package:crowdfans/constants/theme.dart';
import 'package:crowdfans/models/home_feed.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _favoriteArtistsStorageKey = 'sidebar.favoriteArtistIds';

/// Menu lateral com artistas seguidos (espelho do `SidebarMenuComponent`).
class SidebarMenu extends StatefulWidget {
  const SidebarMenu({
    super.key,
    required this.visible,
    required this.artists,
    required this.onClose,
    required this.onPressArtist,
  });

  final bool visible;
  final List<HomeFollowedArtist> artists;
  final VoidCallback onClose;
  final ValueChanged<HomeFollowedArtist> onPressArtist;

  @override
  State<SidebarMenu> createState() => _SidebarMenuState();
}

class _SidebarMenuState extends State<SidebarMenu>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<Offset> _slide;
  late final Animation<double> _fade;
  var _favoriteIds = <String>{};
  var _favoritesReady = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 220),
    );
    _slide = Tween<Offset>(
      begin: const Offset(-1, 0),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
    _fade = CurvedAnimation(parent: _controller, curve: Curves.easeOut);
    handleLoadFavorites();
    if (widget.visible) {
      _controller.value = 1;
    }
  }

  @override
  void didUpdateWidget(covariant SidebarMenu oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.visible == oldWidget.visible) {
      return;
    }
    if (widget.visible) {
      _controller.forward();
    } else {
      _controller.reverse();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> handleLoadFavorites() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getStringList(_favoriteArtistsStorageKey) ?? const [];
      if (!mounted) {
        return;
      }
      setState(() {
        _favoriteIds = raw.toSet();
        _favoritesReady = true;
      });
    } catch (_) {
      if (!mounted) {
        return;
      }
      setState(() => _favoritesReady = true);
    }
  }

  Future<void> handlePersistFavorites(Set<String> ids) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList(_favoriteArtistsStorageKey, ids.toList());
    } catch (_) {
      // Favoritos ainda valem na sessão se o disco falhar.
    }
  }

  void handleToggleFavorite(String artistId) {
    setState(() {
      final next = {..._favoriteIds};
      if (next.contains(artistId)) {
        next.remove(artistId);
      } else {
        next.add(artistId);
      }
      _favoriteIds = next;
    });
    if (_favoritesReady) {
      handlePersistFavorites(_favoriteIds);
    }
  }

  void handlePressArtist(HomeFollowedArtist artist) {
    widget.onPressArtist(artist);
    widget.onClose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = CrowdFansTheme.of(context);
    final favorites = [
      for (final artist in widget.artists)
        if (_favoriteIds.contains(artist.id)) artist,
    ];
    final others = [
      for (final artist in widget.artists)
        if (!_favoriteIds.contains(artist.id)) artist,
    ];
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return IgnorePointer(
          ignoring: !widget.visible && _controller.value == 0,
          child: child,
        );
      },
      child: FadeTransition(
        opacity: _fade,
        child: Stack(
          children: [
            Positioned.fill(
              child: GestureDetector(
                onTap: widget.onClose,
                child: ColoredBox(color: colors.overlay),
              ),
            ),
            Align(
              alignment: Alignment.centerLeft,
              child: SlideTransition(
                position: _slide,
                child: Material(
                  color: colors.surfaceAlt,
                  child: SizedBox(
                    width: MediaQuery.sizeOf(context).width * 0.74,
                    height: double.infinity,
                    child: ListView(
                      padding: const EdgeInsets.fromLTRB(30, 86, 30, 34),
                      children: [
                        if (favorites.isNotEmpty) ...[
                          Text(
                            'Favoritos',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: colors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 16),
                          for (final artist in favorites)
                            SidebarArtistRow(
                              artist: artist,
                              isFavorite: true,
                              onPressed: () => handlePressArtist(artist),
                              onToggleFavorite: () =>
                                  handleToggleFavorite(artist.id),
                            ),
                          const SizedBox(height: 30),
                        ],
                        Text(
                          'Seus Artistas',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: colors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 16),
                        if (widget.artists.isEmpty)
                          Text(
                            'Nenhum artista seguido ainda.',
                            style: TextStyle(
                              fontSize: 14,
                              color: colors.textTertiary,
                            ),
                          )
                        else
                          for (final artist in others)
                            SidebarArtistRow(
                              artist: artist,
                              isFavorite: false,
                              onPressed: () => handlePressArtist(artist),
                              onToggleFavorite: () =>
                                  handleToggleFavorite(artist.id),
                            ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
