import 'package:crowdfans/components/sidebar/sidebar_artist_row.dart';
import 'package:crowdfans/constants/theme.dart';
import 'package:crowdfans/models/home_feed.dart';
import 'package:crowdfans/services/sidebar_artists_store.dart';
import 'package:flutter/material.dart';

/// Menu lateral com Visitados, Favoritos e Seus Artistas (empurra o feed).
class SidebarMenu extends StatefulWidget {
  const SidebarMenu({
    super.key,
    required this.visible,
    required this.artists,
    required this.onClose,
    required this.onPressArtist,
    this.asDrawerPanel = false,
  });

  final bool visible;
  final List<HomeFollowedArtist> artists;
  final VoidCallback onClose;
  final ValueChanged<HomeFollowedArtist> onPressArtist;

  /// Quando true, renderiza só o painel (sem overlay) — o pai anima o push.
  final bool asDrawerPanel;

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
      duration: const Duration(milliseconds: 260),
    );
    _slide = Tween<Offset>(
      begin: const Offset(-1, 0),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));
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
      if (!widget.asDrawerPanel) {
        _controller.forward();
      }
      return;
    }
    if (widget.visible == oldWidget.visible) {
      return;
    }
    if (widget.asDrawerPanel) {
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

  List<HomeFollowedArtist> resolveFavorites() {
    final byId = <String, HomeFollowedArtist>{
      for (final artist in widget.artists) artist.id: artist,
      for (final artist in _recent) artist.id: artist,
    };
    return [
      for (final id in _favoriteIds)
        if (byId[id] != null) byId[id]!,
    ];
  }

  Widget buildPanel(BuildContext context) {
    final colors = CrowdFansTheme.of(context);
    final favorites = resolveFavorites();
    final favoriteIdSet = {for (final a in favorites) a.id};
    final others = [
      for (final artist in widget.artists)
        if (!favoriteIdSet.contains(artist.id)) artist,
    ];
    return Material(
      color: colors.surfaceAlt,
      child: SafeArea(
        child: SizedBox(
          width: MediaQuery.sizeOf(context).width * 0.78,
          height: double.infinity,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 34),
            children: [
              Semantics(
                header: true,
                child: Text(
                  'Visitado recentemente',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: colors.textPrimary,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              if (!_ready || _recent.isEmpty)
                Text(
                  'Nenhum artista visitado recentemente.',
                  style: TextStyle(fontSize: 14, color: colors.textTertiary),
                )
              else
                for (final artist in _recent)
                  SidebarArtistRow(
                    artist: artist,
                    isFavorite: _favoriteIds.contains(artist.id),
                    onPressed: () => handlePressArtist(artist),
                    onToggleFavorite: () => handleToggleFavorite(artist.id),
                  ),
              const SizedBox(height: 28),
              Semantics(
                header: true,
                child: Text(
                  'Favoritos',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: colors.textPrimary,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              if (favorites.isEmpty)
                Text(
                  'Nenhum favorito ainda. Toque na estrela para destacar.',
                  style: TextStyle(fontSize: 14, color: colors.textTertiary),
                )
              else
                for (final artist in favorites)
                  SidebarArtistRow(
                    artist: artist,
                    isFavorite: true,
                    onPressed: () => handlePressArtist(artist),
                    onToggleFavorite: () => handleToggleFavorite(artist.id),
                  ),
              const SizedBox(height: 28),
              Semantics(
                header: true,
                child: Text(
                  'Seus Artistas',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: colors.textPrimary,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              if (widget.artists.isEmpty)
                Text(
                  'Nenhum artista seguido ainda.',
                  style: TextStyle(fontSize: 14, color: colors.textTertiary),
                )
              else if (others.isEmpty)
                Text(
                  'Todos os artistas seguidos estão em Favoritos.',
                  style: TextStyle(fontSize: 14, color: colors.textTertiary),
                )
              else
                for (final artist in others)
                  SidebarArtistRow(
                    artist: artist,
                    isFavorite: false,
                    onPressed: () => handlePressArtist(artist),
                    onToggleFavorite: () => handleToggleFavorite(artist.id),
                  ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (widget.asDrawerPanel) {
      return buildPanel(context);
    }
    final colors = CrowdFansTheme.of(context);
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
                behavior: HitTestBehavior.opaque,
                child: ColoredBox(color: colors.overlay),
              ),
            ),
            Align(
              alignment: Alignment.centerLeft,
              child: SlideTransition(
                position: _slide,
                child: buildPanel(context),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
