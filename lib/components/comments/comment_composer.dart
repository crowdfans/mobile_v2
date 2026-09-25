import 'package:crowdfans/components/comments/comment_reply_banner.dart';
import 'package:crowdfans/constants/theme.dart';
import 'package:flutter/material.dart';

/// Compositor fixo — avatar + campo arredondado + emoji/enviar (CF-174 / CF-194).
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
    this.replyHandle,
    this.avatarUrl,
  });

  final String draft;
  final String? replyAuthor;
  final String? replyHandle;
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
    final keyboardInset = MediaQuery.viewInsetsOf(context).bottom;
    final safeBottom = MediaQuery.paddingOf(context).bottom;
    final bottomPad = keyboardInset > 0 ? keyboardInset : safeBottom;

    return AnimatedPadding(
      duration: const Duration(milliseconds: 180),
      curve: Curves.easeOut,
      padding: EdgeInsets.only(bottom: bottomPad),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: colors.surface,
          border: Border(top: BorderSide(color: colors.border)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (editing)
              Align(
                alignment: Alignment.centerLeft,
                child: TextButton(
                  onPressed: onCancelEdit,
                  child: Text(
                    'Cancelar edição',
                    style: TextStyle(color: colors.textSecondary),
                  ),
                ),
              ),
            if (replyAuthor != null)
              CommentReplyBanner(
                author: replyAuthor!,
                handle: replyHandle,
                onCancel: onCancelReply,
              ),
            if (selectedGifUrl != null && selectedGifUrl!.isNotEmpty)
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 8, 8, 0),
                child: Row(
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
              ),
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Semantics(
                    label: 'Seu avatar',
                    child: CircleAvatar(
                      radius: 18,
                      backgroundColor: colors.surfaceAlt,
                      backgroundImage: (avatarUrl ?? '').startsWith('http')
                          ? NetworkImage(avatarUrl!)
                          : null,
                      child: (avatarUrl ?? '').startsWith('http')
                          ? null
                          : Icon(
                              Icons.person,
                              size: 18,
                              color: colors.textTertiary,
                            ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: KeyedSubtree(
                      key: const Key('comment-composer'),
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          color: colors.inputBackground,
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(color: colors.border),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                key: ValueKey(
                                  'comment-${editing ? 'edit' : replyAuthor ?? 'new'}',
                                ),
                                initialValue: draft,
                                onChanged: onDraftChanged,
                                maxLines: 2,
                                minLines: 1,
                                autocorrect: false,
                                decoration: InputDecoration(
                                  hintText: replyAuthor != null
                                      ? 'Responder a $replyAuthor'
                                      : 'Adicione um comentário...',
                                  hintStyle: TextStyle(
                                    color: colors.textTertiary,
                                    fontSize: 14,
                                  ),
                                  border: InputBorder.none,
                                  isDense: true,
                                  contentPadding: const EdgeInsets.fromLTRB(
                                    16,
                                    12,
                                    8,
                                    12,
                                  ),
                                ),
                              ),
                            ),
                            // Print CF-69 p12/p13: rótulo GIF ao lado do campo.
                            Padding(
                              padding: const EdgeInsets.only(right: 8),
                              child: Material(
                                color: colors.surface,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  side: BorderSide(color: colors.border),
                                ),
                                child: InkWell(
                                  key: const Key('comment-gif'),
                                  onTap: onPickGif,
                                  borderRadius: BorderRadius.circular(8),
                                  child: const SizedBox(
                                    width: 36,
                                    height: 28,
                                    child: Center(
                                      child: Text(
                                        'GIF',
                                        style: TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.w800,
                                          letterSpacing: 0.2,
                                          color: Color(0xFF1C1C1E),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            // Print CF-196: enviar = círculo escuro com ↑
                            // (só com foco/rascunho/resposta — não no idle).
                            if (canSubmit || replyAuthor != null || editing)
                              Padding(
                                padding: const EdgeInsets.only(right: 6),
                                child: Semantics(
                                  button: true,
                                  enabled: canSubmit,
                                  label: editing
                                      ? 'Salvar comentário'
                                      : 'Publicar comentário',
                                  child: Material(
                                    color: canSubmit
                                        ? const Color(0xFF1C1C1E)
                                        : colors.surfaceAlt,
                                    shape: const CircleBorder(),
                                    child: InkWell(
                                      key: const Key('comment-submit'),
                                      onTap: canSubmit ? onSubmit : null,
                                      customBorder: const CircleBorder(),
                                      child: SizedBox(
                                        width: 34,
                                        height: 34,
                                        child: Icon(
                                          Icons.arrow_upward_rounded,
                                          size: 18,
                                          color: canSubmit
                                              ? Colors.white
                                              : colors.textTertiary,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
