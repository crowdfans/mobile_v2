import 'package:crowdfans/constants/theme.dart';
import 'package:flutter/material.dart';

/// Contexto do post no topo da tela de comentários (Home e fã-clube).
class CommentPostContextHeader extends StatelessWidget {
  const CommentPostContextHeader({
    super.key,
    required this.author,
    this.handle,
    this.text,
    this.clubName,
  });

  final String author;
  final String? handle;
  final String? text;
  final String? clubName;

  @override
  Widget build(BuildContext context) {
    final colors = CrowdFansTheme.of(context);
    final club = (clubName ?? '').trim();
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (club.isNotEmpty) ...[
            Semantics(
              label: 'Contexto do fã-clube $club',
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: colors.surfaceAlt,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  child: Text(
                    'Fã-clube · $club',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: colors.textSecondary,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),
          ],
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
