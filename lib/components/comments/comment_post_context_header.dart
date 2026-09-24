import 'package:crowdfans/constants/theme.dart';
import 'package:flutter/material.dart';

/// Contexto do post no topo da tela de comentários (CF-174).
class CommentPostContextHeader extends StatelessWidget {
  const CommentPostContextHeader({
    super.key,
    required this.author,
    this.handle,
    this.text,
  });

  final String author;
  final String? handle;
  final String? text;

  @override
  Widget build(BuildContext context) {
    final colors = CrowdFansTheme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            author,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: colors.textPrimary,
            ),
          ),
          if ((handle ?? '').trim().isNotEmpty)
            Text(
              handle!,
              style: TextStyle(fontSize: 13, color: colors.textTertiary),
            ),
          if ((text ?? '').trim().isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              text!,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 14,
                height: 1.35,
                color: colors.textSecondary,
              ),
            ),
          ],
          const SizedBox(height: 8),
          Text(
            'Comentários',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: colors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}
