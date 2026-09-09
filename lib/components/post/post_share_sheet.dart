import 'package:crowdfans/components/post/post_share_action_tile.dart';
import 'package:crowdfans/components/ui/bottom_sheet_shell.dart';
import 'package:crowdfans/constants/theme.dart';
import 'package:crowdfans/models/feed_post.dart';
import 'package:crowdfans/services/post_share_service.dart';
import 'package:crowdfans/utils/app_alert.dart';
import 'package:flutter/material.dart';

/// Compartilhar post: grade Copiar/WhatsApp/Stories + compartilhar nativo.
class PostShareSheet extends StatelessWidget {
  const PostShareSheet({
    super.key,
    required this.visible,
    required this.post,
    required this.onClose,
  });

  final bool visible;
  final FeedPost? post;
  final VoidCallback onClose;

  Future<void> handleCopyLink(BuildContext context) async {
    final current = post;
    if (current == null) {
      return;
    }
    try {
      await PostShareService.copyLink(current);
      onClose();
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
    final current = post;
    if (current == null) {
      return;
    }
    try {
      await PostShareService.shareWhatsApp(current);
    } finally {
      onClose();
    }
  }

  Future<void> handleStories() async {
    final current = post;
    if (current == null) {
      return;
    }
    try {
      await PostShareService.shareStories(current);
    } finally {
      onClose();
    }
  }

  Future<void> handleShareMore() async {
    final current = post;
    if (current == null) {
      return;
    }
    try {
      await PostShareService.shareFeedPost(current);
    } finally {
      onClose();
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = CrowdFansTheme.of(context);
    return BottomSheetShell(
      visible: visible,
      onClose: onClose,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: PostShareActionTile(
                  label: 'Copiar Link',
                  icon: Icons.link_rounded,
                  iconColor: colors.primary,
                  labelColor: colors.primary,
                  onPressed: () => handleCopyLink(context),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: PostShareActionTile(
                  label: 'WhatsApp',
                  icon: Icons.chat_rounded,
                  iconColor: const Color(0xFF25D366),
                  onPressed: handleWhatsApp,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: PostShareActionTile(
                  label: 'Stories',
                  icon: Icons.camera_alt_outlined,
                  onPressed: handleStories,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Material(
            color: colors.surfaceAlt,
            borderRadius: BorderRadius.circular(14),
            child: InkWell(
              onTap: handleShareMore,
              borderRadius: BorderRadius.circular(14),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                child: Row(
                  children: [
                    Icon(Icons.reply_rounded, color: colors.textPrimary),
                    const SizedBox(width: 10),
                    Text(
                      'Compartilhar para...',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: colors.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
