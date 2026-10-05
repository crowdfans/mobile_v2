import 'package:crowdfans/mocks/cf_temp_mocks.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('CF-195 mock: print Home — Fê expandido, Nina recolhida, Vic', () {
    // Fixtures permanecem para asserts de print; flag demockada.
    expect(kUseCf195CommentMocks, isFalse);

    final comments = Cf195HomeCommentsMock.comments();
    expect(comments, hasLength(3));

    final c1 = comments[0];
    expect(c1.author, 'Fê Andrade');
    expect(c1.handle, 'fan/feandrade');
    expect(c1.minutesAgo, 180);
    expect(c1.votes, 229);
    expect(
      c1.text,
      'Quero mais posts de bastidor assim. Dá vontade de salvar tudo e mandar no grupo do fandom.',
    );
    expect(c1.replies, hasLength(1));
    expect(c1.replies.first.author, 'Rafa Nogueira');
    expect(c1.replies.first.minutesAgo, 120);
    expect(c1.replies.first.votes, 15);

    final c2 = comments[1];
    expect(c2.author, 'Nina Costa');
    expect(c2.handle, 'fan/ninacosta');
    expect(c2.minutesAgo, 180);
    expect(c2.votes, 212);
    expect(
      c2.text,
      'Cheguei pelo feed e fiquei pelos comentários. Era exatamente esse efeito que eu queria ver nos testes.',
    );
    expect(c2.replies, hasLength(2));

    final c3 = comments[2];
    expect(c3.author, 'Vic Melo');
    expect(c3.handle, 'fan/vicmelo');
    expect(c3.minutesAgo, 180);
    expect(c3.replies, isEmpty);

    final expanded = cf195InitialExpandedReplyIds(comments);
    expect(expanded, {'cf195-c1'});
    expect(expanded.contains('cf195-c2'), isFalse);
  });
}
