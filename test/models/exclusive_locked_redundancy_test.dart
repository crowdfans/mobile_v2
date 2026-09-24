import 'package:flutter_test/flutter_test.dart';

/// Sem assinatura: só o teaser; posts exclusivos não acompanham o CTA.
bool showExclusiveLockedPosts({required bool subscribed}) => subscribed;

void main() {
  test('bloqueado não lista posts sob o teaser', () {
    expect(showExclusiveLockedPosts(subscribed: false), isFalse);
    expect(showExclusiveLockedPosts(subscribed: true), isTrue);
  });
}
