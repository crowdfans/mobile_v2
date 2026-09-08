import 'package:crowdfans/components/post/post_sheet_list_item.dart';
import 'package:crowdfans/components/ui/bottom_sheet_shell.dart';
import 'package:crowdfans/constants/theme.dart';
import 'package:crowdfans/models/feed_post.dart';
import 'package:crowdfans/services/post_share_service.dart';
import 'package:crowdfans/utils/app_alert.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Compartilhar post: copiar link ou share nativo.
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
      await Clipboard.setData(
        ClipboardData(text: 'https://crowdfans.app/posts/${current.id}'),
      );
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

  Future<void> handleShare() async {
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Compartilhar',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: colors.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: ColoredBox(
              color: colors.surfaceAlt,
              child: Column(
                children: [
                  PostSheetListItem(
                    label: 'Copiar link',
                    onPressed: () {
                      handleCopyLink(context);
                    },
                  ),
                  PostSheetListItem(
                    label: 'Mais opções',
                    onPressed: handleShare,
                    showDivider: true,
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
