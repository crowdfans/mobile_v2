import 'package:crowdfans/components/post/post_sheet_list_item.dart';
import 'package:crowdfans/components/ui/bottom_sheet_shell.dart';
import 'package:crowdfans/constants/theme.dart';
import 'package:flutter/material.dart';

/// Menu editar / deletar de um item em Meus posts.
class MyPostOptionsSheet extends StatelessWidget {
  const MyPostOptionsSheet({
    super.key,
    required this.visible,
    required this.onClose,
    required this.onEdit,
    required this.onDelete,
  });

  final bool visible;
  final VoidCallback onClose;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

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
            'Opções do post',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: colors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          PostSheetListItem(
            key: const Key('my-posts-edit'),
            label: 'Editar',
            onPressed: onEdit,
          ),
          PostSheetListItem(
            key: const Key('my-posts-delete'),
            label: 'Deletar',
            danger: true,
            onPressed: onDelete,
          ),
          PostSheetListItem(
            key: const Key('my-posts-menu-cancel'),
            label: 'Cancelar',
            onPressed: onClose,
          ),
        ],
      ),
    );
  }
}
