import 'package:crowdfans/components/sidebar/sidebar_artist_row.dart';
import 'package:crowdfans/constants/theme.dart';
import 'package:crowdfans/mocks/cf_temp_mocks.dart';
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
    this.useFixturesOverride,
  });

  final bool visible;
  final List<HomeFollowedArtist> artists;
  final VoidCallback onClose;
  final ValueChanged<HomeFollowedArtist> onPressArtist;

  /// Quando true, renderiza só o painel (sem overlay) — o pai anima o push.
  final bool asDrawerPanel;

  /// Test-only: força liga/desliga dos fixtures CF-191.
  final bool? useFixturesOverride;

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
  var _shouldRender = false;

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
      _shouldRender = true;
      _controller.value = 1;
    }
  }

  @override
  void didUpdateWidget(covariant SidebarMenu oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.visible && !oldWidget.visible) {
      handleLoadStore();
      if (widget.asDrawerPanel) {
        return;
      }
      setState(() => _shouldRender = true);
      _controller.forward(from: 0);
      return;
    }
    if (widget.visible == oldWidget.visible) {
      return;
    }
    if (widget.asDrawerPanel) {
      return;
    }
    if (widget.visible) {
      setState(() => _shouldRender = true);
      _controller.forward(from: 0);
    } else {
      _controller.reverse().whenComplete(() {
        if (!mounted || widget.visible) {
          return;
        }
        setState(() => _shouldRender = false);
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  bool get useFixtures {
    if (widget.useFixturesOverride != null) {
      return widget.useFixturesOverride!;
    }
    return kUseCfTempMocks && CfTempMocks.useFavoriteArtistsFixtures;
  }

  Future<void> handleLoadStore() async {
    if (useFixtures) {
      if (!mounted) {
        return;
      }
      setState(() {
        _favoriteIds = {...CfTempMocks.sidebarFavoriteIds()};
        _recent = CfTempMocks.sidebarRecentArtists();
        _ready = true;
      });
      return;
    }
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
    if (useFixtures) {
      if (!mounted) {
        return;
      }
      setState(() {
        final next = {..._favoriteIds};
        if (next.contains(artistId)) {
          next.remove(artistId);
        } else {
          next.add(artistId);
        }
        _favoriteIds = next;
      });
      return;
    }
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

  List<HomeFollowedArtist> resolveSourceArtists() {
    if (useFixtures) {
      return CfTempMocks.sidebarFollowedArtists();
    }
    return widget.artists;
  }

  List<HomeFollowedArtist> resolveFavorites(List<HomeFollowedArtist> artists) {
    final byId = <String, HomeFollowedArtist>{
      for (final artist in artists) artist.id: artist,
      for (final artist in _recent) artist.id: artist,
    };
    return [
      for (final id in _favoriteIds)
        if (byId[id] != null) byId[id]!,
    ];
  }

  Widget buildPanel(BuildContext context) {
    final colors = CrowdFansTheme.of(context);
    final artists = resolveSourceArtists();
    final favorites = resolveFavorites(artists);
    final favoriteIdSet = {for (final a in favorites) a.id};
    final others = [
      for (final artist in artists)
        if (!favoriteIdSet.contains(artist.id)) artist,
    ];
    final suppressRecentEmpty = useFixtures && _recent.isEmpty;
    return Material(
      color: colors.surfaceAlt,
      clipBehavior: Clip.hardEdge,
      child: SafeArea(
        child: SizedBox(
          width: MediaQuery.sizeOf(context).width * 0.78,
          height: double.infinity,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(24, 12, 24, 34),
            children: [
              Align(
                alignment: Alignment.centerRight,
                child: IconButton(
                  key: const Key('sidebar-close'),
                  onPressed: widget.onClose,
                  tooltip: 'Fechar menu',
                  icon: Icon(Icons.close, color: colors.textPrimary),
                ),
              ),
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
              if (_ready && _recent.isNotEmpty)
                for (final artist in _recent)
                  SidebarArtistRow(
                    artist: artist,
                    isFavorite: _favoriteIds.contains(artist.id),
                    onPressed: () => handlePressArtist(artist),
                    onToggleFavorite: () => handleToggleFavorite(artist.id),
                  )
              else if (_ready && !suppressRecentEmpty)
                Text(
                  'Nenhum artista visitado recentemente.',
                  style: TextStyle(fontSize: 14, color: colors.textTertiary),
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
              if (artists.isEmpty)
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
    if (!_shouldRender) {
      return const SizedBox.shrink();
    }
    final colors = CrowdFansTheme.of(context);
    // SizedBox.expand: a barreira cobre a tela inteira (pai = Stack).
    // Sem isso o Stack encolhia ao painel e o tap fora nunca chamava onClose.
    return SizedBox.expand(
      child: AnimatedBuilder(
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
            fit: StackFit.expand,
            children: [
              Positioned.fill(
                child: GestureDetector(
                  key: const Key('sidebar-barrier'),
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
      ),
    );
  }
}
