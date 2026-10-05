import 'package:crowdfans/utils/exclusive_content_access.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('CF-184: bloqueado não lista posts sob o teaser', () {
    expect(
      artistExclusiveShowsTeaserOnly(
        subscriptionResolved: true,
        subscribed: false,
      ),
      isTrue,
    );
    expect(
      artistExclusiveShowsTeaserOnly(
        subscriptionResolved: true,
        subscribed: true,
      ),
      isFalse,
    );
  });
}
