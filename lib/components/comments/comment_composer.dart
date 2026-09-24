import 'package:crowdfans/components/input/app_text_field.dart';
import 'package:crowdfans/constants/theme.dart';
import 'package:flutter/material.dart';

/// Compositor compacto: avatar + campo + ícone GIF + enviar (CF-174).
class CommentComposer extends StatelessWidget {
  const CommentComposer({
    super.key,
    required this.draft,
    required this.replyAuthor,
    required this.editing,
    required this.selectedGifUrl,
    required this.submitting,
    required this.onDraftChanged,
    required this.onCancelEdit,
    required this.onCancelReply,
    required this.onRemoveGif,
    required this.onPickGif,
    required this.onSubmit,
    this.avatarUrl,
  });

  final String draft;
  final String? replyAuthor;
  final bool editing;
  final String? selectedGifUrl;
  final bool submitting;
  final ValueChanged<String> onDraftChanged;
  final VoidCallback onCancelEdit;
  final VoidCallback onCancelReply;
  final VoidCallback onRemoveGif;
  final VoidCallback onPickGif;
  final VoidCallback onSubmit;
  final String? avatarUrl;

  @override
  Widget build(BuildContext context) {
    final colors = CrowdFansTheme.of(context);
    final canSubmit =
        !submitting &&
        (draft.trim().isNotEmpty || (selectedGifUrl ?? '').isNotEmpty);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: colors.surface,
        border: Border(top: BorderSide(color: colors.border)),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 10, 8, 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (editing)
              TextButton(
                onPressed: onCancelEdit,
                child: Text(
                  'Cancelar edição',
                  style: TextStyle(color: colors.textSecondary),
                ),
              ),
            if (replyAuthor != null)
              TextButton(
                onPressed: onCancelReply,
                child: Text(
                  'Cancelar resposta a $replyAuthor',
                  style: TextStyle(color: colors.textSecondary),
                ),
              ),
            if (selectedGifUrl != null && selectedGifUrl!.isNotEmpty) ...[
              Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      selectedGifUrl!,
                      width: 56,
                      height: 56,
                      fit: BoxFit.cover,
                    ),
                  ),
                  TextButton(
                    onPressed: onRemoveGif,
                    child: Text(
                      'Remover GIF',
                      style: TextStyle(color: colors.danger),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
            ],
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                CircleAvatar(
                  radius: 18,
                  backgroundColor: colors.surfaceAlt,
                  backgroundImage:
                      (avatarUrl ?? '').startsWith('http')
                      ? NetworkImage(avatarUrl!)
                      : null,
                  child: (avatarUrl ?? '').startsWith('http')
                      ? null
                      : Icon(Icons.person, size: 18, color: colors.textTertiary),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: KeyedSubtree(
                    key: const Key('comment-composer'),
                    child: AppTextField(
                      key: ValueKey(
                        'comment-${editing ? 'edit' : replyAuthor ?? 'new'}',
                      ),
                      hint: replyAuthor != null
                          ? 'Responder a $replyAuthor'
                          : 'Adicione um comentário...',
                      maxLines: 2,
                      initialValue: draft,
                      onChanged: onDraftChanged,
                    ),
                  ),
                ),
                IconButton(
                  key: const Key('comment-gif'),
                  onPressed: onPickGif,
                  tooltip: 'GIF',
                  icon: Icon(Icons.gif_box_outlined, color: colors.primary),
                ),
                IconButton(
                  key: const Key('comment-submit'),
                  onPressed: canSubmit ? onSubmit : null,
                  tooltip: editing ? 'Salvar' : 'Publicar',
                  icon: Icon(
                    Icons.send_rounded,
                    color: canSubmit ? colors.primary : colors.textTertiary,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
