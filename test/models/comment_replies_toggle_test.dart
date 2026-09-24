import 'package:flutter_test/flutter_test.dart';

String commentRepliesToggleLabel({
  required int replyCount,
  required bool expanded,
}) {
  if (expanded) {
    return 'Ocultar respostas';
  }
  if (replyCount == 1) {
    return 'Ver 1 resposta';
  }
  return 'Ver $replyCount respostas';
}

void main() {
  test('rótulo usa contagem real do backend', () {
    expect(
      commentRepliesToggleLabel(replyCount: 2, expanded: false),
      'Ver 2 respostas',
    );
    expect(
      commentRepliesToggleLabel(replyCount: 1, expanded: false),
      'Ver 1 resposta',
    );
    expect(
      commentRepliesToggleLabel(replyCount: 3, expanded: true),
      'Ocultar respostas',
    );
  });
}
