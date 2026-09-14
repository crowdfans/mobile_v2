import 'package:crowdfans/models/feed_post.dart';
import 'package:crowdfans/screens/post/create_post_screen.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('compose resolve tipo pelo conteúdo, sem menu texto/imagem', () {
    expect(resolveCreatePostType(hasMedia: false), PostType.text);
    expect(resolveCreatePostType(hasMedia: true), PostType.image);
  });
}
