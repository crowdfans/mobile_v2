import 'package:crowdfans/components/sidebar/sidebar_artist_row.dart';
import 'package:crowdfans/constants/theme.dart';
import 'package:crowdfans/models/home_feed.dart';
import 'package:crowdfans/services/sidebar_artists_store.dart';
import 'package:flutter/material.dart';

/// Menu lateral com favoritos, visitados recentemente e artistas seguidos.
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
  var _recent = <HomeFollowedArtist>[];
  var _ready = false;

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
    handleLoadStore();
    if (widget.visible) {
      _controller.value = 1;
    }
  }

  @override
  void didUpdateWidget(covariant SidebarMenu oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.visible && !oldWidget.visible) {
      handleLoadStore();
      _controller.forward();
      return;
    }
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

  Future<void> handleLoadStore() async {
    final ids = await SidebarArtistsStore.loadFavoriteIds();
    final recent = await SidebarArtistsStore.loadRecent();
    if (!mounted) {
      return;
    }
    setState(() {
      _favoriteIds = ids;
      _recent = recent;
      _ready = true;
    });
  }

  Future<void> handleToggleFavorite(String artistId) async {
    final next = await SidebarArtistsStore.toggleFavorite(artistId);
    if (!mounted) {
      return;
    }
    setState(() => _favoriteIds = next);
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
                        Text(
                          'Visitado recentemente',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: colors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 16),
                        if (!_ready || _recent.isEmpty)
                          Text(
                            'Nenhum artista visitado recentemente.',
                            style: TextStyle(
                              fontSize: 14,
                              color: colors.textTertiary,
                            ),
                          )
                        else
                          for (final artist in _recent)
                            SidebarArtistRow(
                              artist: artist,
                              isFavorite: _favoriteIds.contains(artist.id),
                              onPressed: () => handlePressArtist(artist),
                              onToggleFavorite: () =>
                                  handleToggleFavorite(artist.id),
                            ),
                        const SizedBox(height: 30),
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
