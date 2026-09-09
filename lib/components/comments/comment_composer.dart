import 'package:crowdfans/components/buttons/app_button.dart';
import 'package:crowdfans/components/input/app_text_field.dart';
import 'package:crowdfans/constants/theme.dart';
import 'package:flutter/material.dart';

/// Compositor de comentário (texto, GIF, publicar).
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
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            KeyedSubtree(
              key: const Key('comment-composer'),
              child: AppTextField(
                key: ValueKey(
                  'comment-${editing ? 'edit' : replyAuthor ?? 'new'}',
                ),
                hint: replyAuthor != null
                    ? 'Responder a $replyAuthor'
                    : 'Escreva um comentário',
                maxLines: 3,
                initialValue: draft,
                onChanged: onDraftChanged,
              ),
            ),
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
              const SizedBox(height: 8),
              Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      selectedGifUrl!,
                      width: 72,
                      height: 72,
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
            ],
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: AppButton(
                    key: const Key('comment-gif'),
                    label: 'GIF',
                    variant: AppButtonVariant.outline,
                    onPressed: onPickGif,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  flex: 2,
                  child: AppButton(
                    key: const Key('comment-submit'),
                    label: submitting
                        ? (editing ? 'Salvando...' : 'Publicando...')
                        : (editing ? 'Salvar' : 'Publicar'),
                    disabled: !canSubmit,
                    onPressed: onSubmit,
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
