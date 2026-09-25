import 'package:crowdfans/components/profile/artist_profile_cover_cta.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('CF-185: estados do CTA do cover seguem prints', () {
    expect(
      artistProfileCoverCtaKind(following: false, subscribed: false),
      ArtistProfileCoverCtaKind.follow,
    );
    expect(
      artistProfileCoverCtaKind(following: true, subscribed: false),
      ArtistProfileCoverCtaKind.membershipSubscribe,
    );
    expect(
      artistProfileCoverCtaKind(following: false, subscribed: true),
      ArtistProfileCoverCtaKind.membershipActive,
    );
  });
}
