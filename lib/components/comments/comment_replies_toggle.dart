import 'package:crowdfans/constants/theme.dart';
import 'package:flutter/material.dart';

/// Controle Ver/Ocultar respostas (fã-clube e Home) com contagem do backend.
class CommentRepliesToggle extends StatelessWidget {
  const CommentRepliesToggle({
    super.key,
    required this.replyCount,
    required this.expanded,
    required this.onToggle,
  });

  final int replyCount;
  final bool expanded;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    final colors = CrowdFansTheme.of(context);
    if (replyCount <= 0) {
      return const SizedBox.shrink();
    }
    final label = expanded
        ? 'Ocultar respostas'
        : replyCount == 1
        ? 'Ver 1 resposta'
        : 'Ver $replyCount respostas';
    return Padding(
      padding: const EdgeInsets.only(left: 48, bottom: 12, top: 2),
      child: Semantics(
        button: true,
        expanded: expanded,
        label: '$label. Comentário com $replyCount respostas.',
        child: InkWell(
          onTap: onToggle,
          borderRadius: BorderRadius.circular(8),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: colors.textSecondary,
                  ),
                ),
                const SizedBox(width: 4),
                Icon(
                  expanded
                      ? Icons.keyboard_arrow_up
                      : Icons.keyboard_arrow_down,
                  size: 18,
                  color: colors.textSecondary,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
