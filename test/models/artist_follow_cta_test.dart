import 'package:crowdfans/components/profile/artist_profile_public_cover.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('CTA de follow não usa rótulo de membership', () {
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
      ArtistProfilePublicCover.followCtaLabel(following: true, busy: false)
          .toLowerCase(),
      isNot(contains('assin')),
    );
  });
}
