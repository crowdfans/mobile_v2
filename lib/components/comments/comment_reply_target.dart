import 'package:crowdfans/services/comment_service.dart';

/// CF-69 (Instagram): respostas aninhadas não criam cadeia — o parent da API
/// é sempre o comentário raiz da thread.
CommentItem commentInstagramReplyParent({
  required CommentItem threadRoot,
}) {
  return threadRoot;
}

/// Id enviado em `parentCommentId` ao criar resposta (null = comentário raiz).
String? commentApiParentId({
  required CommentItem? replyToRoot,
}) {
  final id = replyToRoot?.id.trim() ?? '';
  return id.isEmpty ? null : id;
}

/// Texto ou GIF — whitespace não conta (submit bloqueado + alerta na tela).
bool commentCanSubmit({required String draft, String? gifUrl}) {
  final gif = (gifUrl ?? '').trim();
  return draft.trim().isNotEmpty || gif.isNotEmpty;
}

/// Após cancelar resposta: limpa mention/draft/GIF (não deixa rascunho órfão).
({String draft, String? gifUrl}) commentCancelReplyComposerState() {
  return (draft: '', gifUrl: null);
}
