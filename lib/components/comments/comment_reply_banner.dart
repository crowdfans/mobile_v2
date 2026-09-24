import 'package:crowdfans/constants/theme.dart';
import 'package:flutter/material.dart';

/// Faixa "Respondendo a …" com cancelar acessível (CF-196).
class CommentReplyBanner extends StatelessWidget {
  const CommentReplyBanner({
    super.key,
    required this.author,
    this.handle,
    required this.onCancel,
  });

  final String author;
  final String? handle;
  final VoidCallback onCancel;

  String get label {
    final h = (handle ?? '').trim();
    if (h.isEmpty) {
      return 'Respondendo a $author';
    }
    final normalized = h.startsWith('fan/') || h.startsWith('@') ? h : 'fan/$h';
    return 'Respondendo a $author ($normalized)';
  }

  @override
  Widget build(BuildContext context) {
    final colors = CrowdFansTheme.of(context);
    return Semantics(
      liveRegion: true,
      label: label,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: colors.surfaceAlt,
          border: Border(bottom: BorderSide(color: colors.border)),
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 8, 4, 8),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: colors.textSecondary,
                  ),
                ),
              ),
              Semantics(
                button: true,
                label: 'Cancelar resposta',
                child: IconButton(
                  onPressed: onCancel,
                  tooltip: 'Cancelar resposta',
                  icon: Icon(Icons.close, size: 20, color: colors.textSecondary),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
