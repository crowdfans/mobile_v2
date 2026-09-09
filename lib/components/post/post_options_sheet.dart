import 'package:crowdfans/components/post/post_options_share_action.dart';
import 'package:crowdfans/components/post/post_options_shortcut_card.dart';
import 'package:crowdfans/components/post/post_sheet_list_item.dart';
import 'package:crowdfans/components/ui/bottom_sheet_shell.dart';
import 'package:crowdfans/constants/pages.dart';
import 'package:crowdfans/constants/theme.dart';
import 'package:crowdfans/models/feed_post.dart';
import 'package:crowdfans/models/home_feed.dart';
import 'package:crowdfans/services/follow_service.dart';
import 'package:crowdfans/services/post_share_service.dart';
import 'package:crowdfans/services/saved_post_service.dart';
import 'package:crowdfans/services/sidebar_artists_store.dart';
import 'package:crowdfans/utils/app_alert.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Opções do post (três pontinhos) — layout dos prints CF-68.
class PostOptionsSheet extends StatefulWidget {
  const PostOptionsSheet({
    super.key,
    required this.visible,
    required this.post,
    required this.onClose,
    this.onUnfollowed,
  });

  final bool visible;
  final FeedPost? post;
  final VoidCallback onClose;
  final ValueChanged<String>? onUnfollowed;

  @override
  State<PostOptionsSheet> createState() => _PostOptionsSheetState();
}

class _PostOptionsSheetState extends State<PostOptionsSheet> {
  var _favorite = false;

  String get _artistId => widget.post?.artistId?.trim() ?? '';

  HomeFollowedArtist? get _sidebarArtist {
    final post = widget.post;
    if (post == null || _artistId.isEmpty) {
      return null;
    }
    return HomeFollowedArtist(
      id: _artistId,
      username: post.handle.replaceFirst(RegExp(r'^@'), ''),
      avatarUrl: post.avatarUri,
    );
  }

  @override
  void didUpdateWidget(covariant PostOptionsSheet oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.visible &&
        (!oldWidget.visible || oldWidget.post?.id != widget.post?.id)) {
      handleLoadFavorite();
    }
  }

  Future<void> handleLoadFavorite() async {
    if (_artistId.isEmpty) {
      setState(() => _favorite = false);
      return;
    }
    final ids = await SidebarArtistsStore.loadFavoriteIds();
    if (!mounted) {
      return;
    }
    setState(() => _favorite = ids.contains(_artistId));
  }

  void handleOpenFanClub(BuildContext context) {
    widget.onClose();
    if (_artistId.isEmpty) {
      return;
    }
    context.push(
      Pages.fanClubCommunityOf(
        _artistId,
        name: widget.post?.author,
        avatarUrl: widget.post?.avatarUri,
      ),
    );
  }

  Future<void> handleOpenArtist(BuildContext context) async {
    widget.onClose();
    if (_artistId.isEmpty) {
      return;
    }
    final artist = _sidebarArtist;
    if (artist != null) {
      await SidebarArtistsStore.recordVisit(artist);
    }
    if (context.mounted) {
      context.push(Pages.artistProfile.replaceAll(':artistId', _artistId));
    }
  }

  Future<void> handleSave(BuildContext context) async {
    final current = widget.post;
    if (current == null) {
      return;
    }
    try {
      await SavedPostService.savePost(current.id);
      widget.onClose();
      if (context.mounted) {
        await AppAlert.show(context, title: 'Memórias', message: 'Post salvo.');
      }
    } catch (error) {
      if (context.mounted) {
        await AppAlert.show(
          context,
          title: 'Memórias',
          message: error.toString(),
        );
      }
    }
  }

  Future<void> handleCopy(BuildContext context) async {
    final current = widget.post;
    if (current == null) {
      return;
    }
    try {
      await PostShareService.copyLink(current);
      widget.onClose();
      if (context.mounted) {
        await AppAlert.show(context, title: 'Link', message: 'Link copiado.');
      }
    } catch (_) {
      if (context.mounted) {
        await AppAlert.show(
          context,
          title: 'Link',
          message: 'Não foi possível copiar o link.',
        );
      }
    }
  }

  Future<void> handleWhatsApp() async {
    final current = widget.post;
    if (current == null) {
      return;
    }
    try {
      await PostShareService.shareWhatsApp(current);
    } finally {
      widget.onClose();
    }
  }

  Future<void> handleStories() async {
    final current = widget.post;
    if (current == null) {
      return;
    }
    try {
      await PostShareService.shareStories(current);
    } finally {
      widget.onClose();
    }
  }

  Future<void> handleUnfollow(BuildContext context) async {
    if (_artistId.isEmpty) {
      return;
    }
    final ok = await AppAlert.confirm(
      context,
      title: 'Deixar de seguir',
      message: 'Você deixará de ver posts deste artista no feed.',
      confirmLabel: 'Deixar de seguir',
    );
    if (!ok) {
      return;
    }
    try {
      await FollowService.unfollowArtist(_artistId);
      widget.onUnfollowed?.call(_artistId);
      widget.onClose();
    } catch (error) {
      if (context.mounted) {
        await AppAlert.show(
          context,
          title: 'Seguir',
          message: error.toString(),
        );
      }
    }
  }

  Future<void> handleToggleFavorite() async {
    if (_artistId.isEmpty) {
      return;
    }
    final next = await SidebarArtistsStore.toggleFavorite(_artistId);
    if (!mounted) {
      return;
    }
    setState(() => _favorite = next.contains(_artistId));
  }

  void handleReport(BuildContext context) {
    final current = widget.post;
    widget.onClose();
    if (current == null) {
      return;
    }
    context.push(
      '${Pages.report}?context=post&targetId=${Uri.encodeComponent(current.id)}'
      '&displayName=${Uri.encodeComponent(current.author)}',
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = CrowdFansTheme.of(context);
    return BottomSheetShell(
      visible: widget.visible,
      onClose: widget.onClose,
      child: Column(
        children: [
          Row(
            children: [
              PostOptionsShortcutCard(
                label: 'Ver Fã Clube',
                icon: Icons.campaign_outlined,
                backgroundColor: AppPalette.purple100,
                onPressed: () => handleOpenFanClub(context),
              ),
              const SizedBox(width: 10),
              PostOptionsShortcutCard(
                label: 'Salvar nas Memórias',
                icon: Icons.bookmark_outline,
                backgroundColor: AppPalette.yellow400,
                iconColor: AppPalette.platinum900,
                onPressed: () {
                  handleSave(context);
                },
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              PostOptionsShareAction(
                label: 'Copiar',
                icon: Icons.link,
                onPressed: () {
                  handleCopy(context);
                },
              ),
              PostOptionsShareAction(
                label: 'WhatsApp',
                icon: Icons.chat,
                iconColor: const Color(0xFF25D366),
                onPressed: handleWhatsApp,
              ),
              PostOptionsShareAction(
                label: 'Stories',
                icon: Icons.auto_awesome,
                onPressed: handleStories,
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: ColoredBox(
              color: colors.surfaceAlt,
              child: Column(
                children: [
                  PostSheetListItem(
                    label: 'Deixar de seguir',
                    onPressed: () {
                      handleUnfollow(context);
                    },
                  ),
                  PostSheetListItem(
                    label: 'Sobre',
                    onPressed: () {
                      handleOpenArtist(context);
                    },
                    showDivider: true,
                  ),
                  PostSheetListItem(
                    label: _favorite ? 'Remover dos favoritos' : 'Favoritar',
                    onPressed: handleToggleFavorite,
                    showDivider: true,
                  ),
                  PostSheetListItem(
                    label: 'Reportar',
                    onPressed: () => handleReport(context),
                    showDivider: true,
                    danger: true,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
