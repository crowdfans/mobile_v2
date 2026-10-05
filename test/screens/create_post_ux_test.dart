import 'package:crowdfans/models/feed_post.dart';
import 'package:crowdfans/screens/post/create_post_screen.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('compose resolve tipo pelo conteúdo, sem menu texto/imagem', () {
    expect(resolveCreatePostType(hasMedia: false), PostType.text);
    expect(resolveCreatePostType(hasMedia: true), PostType.image);
  });

  test('canPublishCreatePost green/red/edge (CF-128)', () {
    expect(canPublishCreatePost(text: 'ok', hasMedia: false), isTrue);
    expect(canPublishCreatePost(text: '', hasMedia: false), isFalse);
    expect(canPublishCreatePost(text: 'a' * 281, hasMedia: false), isFalse);
    expect(canPublishCreatePost(text: '', hasMedia: true), isTrue);
  });
}
