import 'package:crowdfans/components/fan_club/fan_club_post_list_action.dart';
import 'package:crowdfans/components/fan_club/fan_club_post_save_memory_button.dart';
import 'package:crowdfans/components/fan_club/fan_club_post_share_brand_tile.dart';
import 'package:crowdfans/components/post/post_share_action_tile.dart';
import 'package:crowdfans/components/ui/bottom_sheet_shell.dart';
import 'package:crowdfans/constants/pages.dart';
import 'package:crowdfans/constants/theme.dart';
import 'package:crowdfans/models/feed_post.dart';
import 'package:crowdfans/services/post_share_service.dart';
import 'package:crowdfans/services/saved_post_service.dart';
import 'package:crowdfans/services/sidebar_artists_store.dart';
import 'package:crowdfans/utils/app_alert.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Menu do post **dentro do fã-clube** (CF-227).
///
/// Sem ações de perfil de artista (seguir/sobre/abrir clube). Favoritar mira o
/// fã-clube, não o artista genérico do feed.
class FanClubPostOptionsSheet extends StatefulWidget {
  const FanClubPostOptionsSheet({
    super.key,
    required this.visible,
    required this.post,
    required this.artistId,
    required this.onClose,
    this.isFavorite = false,
    this.onFavoriteChanged,
  });

  final bool visible;
  final FeedPost? post;
  final String artistId;
  final VoidCallback onClose;
  final bool isFavorite;
  final ValueChanged<bool>? onFavoriteChanged;

  @override
  State<FanClubPostOptionsSheet> createState() =>
      _FanClubPostOptionsSheetState();
}

class _FanClubPostOptionsSheetState extends State<FanClubPostOptionsSheet> {
  late bool _favorite;

  @override
  void initState() {
    super.initState();
    _favorite = widget.isFavorite;
  }

  @override
  void didUpdateWidget(covariant FanClubPostOptionsSheet oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.visible &&
        (!oldWidget.visible ||
            oldWidget.post?.id != widget.post?.id ||
            oldWidget.isFavorite != widget.isFavorite)) {
      setState(() => _favorite = widget.isFavorite);
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

  Future<void> handleToggleFavorite() async {
    final id = widget.artistId.trim();
    if (id.isEmpty) {
      return;
    }
    final next = await SidebarArtistsStore.toggleFavorite(id);
    if (!mounted) {
      return;
    }
    final favorite = next.contains(id);
    setState(() => _favorite = favorite);
    widget.onFavoriteChanged?.call(favorite);
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
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            FanClubPostSaveMemoryButton(
              onPressed: () => handleSave(context),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: PostShareActionTile(
                    label: 'Copiar Link',
                    icon: Icons.link_rounded,
                    iconColor: colors.primary,
                    labelColor: colors.primary,
                    onPressed: () => handleCopy(context),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: FanClubPostShareBrandTile(
                    label: 'WhatsApp',
                    asset: 'assets/images/whatsApp.svg',
                    fallbackIcon: Icons.chat_rounded,
                    fallbackColor: const Color(0xFF25D366),
                    onPressed: handleWhatsApp,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: FanClubPostShareBrandTile(
                    label: 'Stories',
                    asset: 'assets/images/instagram.svg',
                    fallbackIcon: Icons.camera_alt_outlined,
                    onPressed: handleStories,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            FanClubPostListAction(
              label: _favorite
                  ? 'Remover Fã Clube dos favoritos'
                  : 'Favoritar Fã Clube',
              icon: _favorite ? Icons.star_rounded : Icons.star_border_rounded,
              onPressed: handleToggleFavorite,
            ),
            const SizedBox(height: 10),
            FanClubPostListAction(
              label: 'Reportar',
              svgAsset: 'assets/icons/Communication/message-alert-circle.svg',
              danger: true,
              onPressed: () => handleReport(context),
            ),
          ],
        ),
      ),
    );
  }
}
