import 'package:crowdfans/components/profile/artist_profile_public_cover.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('CTA do cover é Seguir/Seguindo — nunca Membership/Jam Coins', () {
    expect(
      ArtistProfilePublicCover.followCtaLabel(following: false, busy: false),
      '+ Seguir',
    );
    expect(
      ArtistProfilePublicCover.followCtaLabel(following: true, busy: false),
      'Seguindo',
    );
    expect(
      ArtistProfilePublicCover.followCtaLabel(following: false, busy: true),
      'Aguarde...',
    );
    expect(
      ArtistProfilePublicCover.followCtaLabel(following: true, busy: false),
      isNot(contains('Membership')),
    );
  });
}
