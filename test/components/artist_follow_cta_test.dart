import 'package:crowdfans/components/profile/artist_profile_cover_cta.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('CF-185: cover CTA Seguir / Membership♪ / Membership✓', () {
    expect(
      artistProfileCoverCtaKind(following: false, subscribed: false),
      ArtistProfileCoverCtaKind.follow,
    );
    expect(
      artistProfileCoverCtaKind(following: true, subscribed: false),
      ArtistProfileCoverCtaKind.membershipSubscribe,
    );
    expect(
      artistProfileCoverCtaKind(following: true, subscribed: true),
      ArtistProfileCoverCtaKind.membershipActive,
    );
    expect(
      artistProfileCoverCtaKind(following: false, subscribed: true),
      ArtistProfileCoverCtaKind.membershipActive,
    );
  });
}
