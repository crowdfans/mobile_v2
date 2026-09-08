import 'package:crowdfans/components/post/post_options_shortcut_card.dart';
import 'package:crowdfans/components/post/post_sheet_list_item.dart';
import 'package:crowdfans/components/ui/bottom_sheet_shell.dart';
import 'package:crowdfans/constants/pages.dart';
import 'package:crowdfans/constants/theme.dart';
import 'package:crowdfans/models/feed_post.dart';
import 'package:crowdfans/services/hidden_post_service.dart';
import 'package:crowdfans/services/saved_post_service.dart';
import 'package:crowdfans/utils/app_alert.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Opções do post (três pontinhos).
class PostOptionsSheet extends StatelessWidget {
  const PostOptionsSheet({
    super.key,
    required this.visible,
    required this.post,
    required this.onClose,
    this.onPostHidden,
    this.onOpenShare,
  });

  final bool visible;
  final FeedPost? post;
  final VoidCallback onClose;
  final ValueChanged<String>? onPostHidden;
  final ValueChanged<FeedPost>? onOpenShare;

  String get _artistId => post?.artistId?.trim() ?? '';

  void handleOpenFanClub(BuildContext context) {
    onClose();
    if (post == null || _artistId.isEmpty) {
      return;
    }
    context.push(Pages.fanClubCommunity.replaceAll(':artistId', _artistId));
  }

  void handleOpenArtist(BuildContext context) {
    onClose();
    if (post == null || _artistId.isEmpty) {
      return;
    }
    context.push(Pages.artistProfile.replaceAll(':artistId', _artistId));
  }

  Future<void> handleSave(BuildContext context) async {
    final current = post;
    if (current == null) {
      return;
    }
    try {
      await SavedPostService.savePost(current.id);
      onClose();
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

  Future<void> handleHide(BuildContext context) async {
    final current = post;
    if (current == null) {
      return;
    }
    try {
      await HiddenPostService.hidePost(current.id);
      onPostHidden?.call(current.id);
      onClose();
    } catch (error) {
      if (context.mounted) {
        await AppAlert.show(
          context,
          title: 'Posts ocultos',
          message: error.toString(),
        );
      }
    }
  }

  void handleShare() {
    final current = post;
    if (current == null) {
      return;
    }
    onClose();
    onOpenShare?.call(current);
  }

  void handleReport(BuildContext context) {
    final current = post;
    onClose();
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
      visible: visible,
      onClose: onClose,
      child: Column(
        children: [
          Row(
            children: [
              PostOptionsShortcutCard(
                label: 'Ver fã clube do artista',
                onPressed: () => handleOpenFanClub(context),
              ),
              const SizedBox(width: 10),
              PostOptionsShortcutCard(
                label: 'Salvar post nas memórias',
                onPressed: () {
                  handleSave(context);
                },
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: ColoredBox(
              color: colors.surfaceAlt,
              child: Column(
                children: [
                  PostSheetListItem(
                    label: 'Compartilhar',
                    onPressed: handleShare,
                  ),
                  PostSheetListItem(
                    label: 'Sobre este artista',
                    onPressed: () => handleOpenArtist(context),
                    showDivider: true,
                  ),
                  PostSheetListItem(
                    label: 'Ocultar',
                    onPressed: () {
                      handleHide(context);
                    },
                    showDivider: true,
                  ),
                  PostSheetListItem(
                    label: 'Denunciar',
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
