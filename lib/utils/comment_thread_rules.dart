import 'package:crowdfans/services/comment_service.dart';

/// Regras de thread / ordenação dos comentários (CF-69).
///
/// Instagram: só responde o comentário raiz; respostas aninhadas ficam sob
/// o mesmo pai (sem cadeia tipo Twitter).
abstract final class CommentThreadRules {
  /// Pai enviado à API ao tocar Responder em [tapped] dentro da thread [root].
  static CommentItem replyParent({
    required CommentItem root,
    required CommentItem tapped,
  }) {
    // Sempre o raiz — mesmo se o usuário tocou numa resposta aninhada.
    return root;
  }

  /// Ordena a lista visível: Populares (votos↓, depois mais novos) ou Novos.
  static List<CommentItem> sorted(
    List<CommentItem> comments, {
    required bool popular,
  }) {
    final list = [...comments];
    if (popular) {
      list.sort((a, b) {
        final byVotes = b.votes.compareTo(a.votes);
        if (byVotes != 0) {
          return byVotes;
        }
        return a.minutesAgo.compareTo(b.minutesAgo);
      });
    } else {
      // Novos: menor minutesAgo primeiro (mais recente).
      list.sort((a, b) => a.minutesAgo.compareTo(b.minutesAgo));
    }
    return list;
  }

  /// Texto ou GIF — vazio/whitespace não publica (alerta na tela).
  static bool canSubmit({required String draft, String? gifUrl}) {
    final gif = (gifUrl ?? '').trim();
    return draft.trim().isNotEmpty || gif.isNotEmpty;
  }

  /// Prefill `fan/...` no compositor (print CF-69 / CF-196).
  static String mentionDraft(String? handle) {
    final raw = (handle ?? '').trim();
    if (raw.isEmpty) {
      return '';
    }
    if (raw.startsWith('fan/') || raw.startsWith('@')) {
      return '$raw ';
    }
    return 'fan/$raw ';
  }
}
