import 'package:crowdfans/screens/comments/comments_screen.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('CommentsScreen expõe postShares e null vira 0 no header', () {
    const withShares = CommentsScreen(postId: 'p1', postShares: 12);
    expect(withShares.postShares, 12);
    expect(withShares.postShares ?? 0, 12);

    const withoutShares = CommentsScreen(postId: 'p1');
    expect(withoutShares.postShares, isNull);
    expect(withoutShares.postShares ?? 0, 0);
  });
}
