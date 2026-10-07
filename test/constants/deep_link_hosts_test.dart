import 'package:crowdfans/constants/deep_link_hosts.dart';
import 'package:crowdfans/constants/pages.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('DeepLinkHosts', () {
    test('green: inclui prod e placeholder staging GCP', () {
      expect(DeepLinkHosts.all, contains(DeepLinkHosts.prod));
      expect(DeepLinkHosts.all, contains(DeepLinkHosts.gcpStagingPlaceholder));
      expect(DeepLinkHosts.isKnown('crowdfans.app'), isTrue);
      expect(DeepLinkHosts.isKnown('staging.crowdfans.app'), isTrue);
    });

    test('red: host desconhecido', () {
      expect(DeepLinkHosts.isKnown('evil.example'), isFalse);
      expect(DeepLinkHosts.isKnown(null), isFalse);
      expect(DeepLinkHosts.isKnown(''), isFalse);
    });

    test('edge: case-insensitive', () {
      expect(DeepLinkHosts.isKnown('CrowdFans.APP'), isTrue);
    });
  });

  group('Pages.fromIncomingLocation HTTPS', () {
    test('green: https crowdfans.app/artists/:id', () {
      expect(
        Pages.fromIncomingLocation(
          'https://crowdfans.app/artists/artist-1',
        ),
        '/artists/artist-1',
      );
    });

    test('green: staging placeholder host', () {
      expect(
        Pages.fromIncomingLocation(
          'https://staging.crowdfans.app/artists/artist-1',
        ),
        '/artists/artist-1',
      );
    });

    test('red: mobile scheme ainda funciona', () {
      expect(
        Pages.fromIncomingLocation('mobile:///artists/artist-1'),
        '/artists/artist-1',
      );
    });

    test('edge: query string preservada em https', () {
      expect(
        Pages.fromIncomingLocation(
          'https://crowdfans.app/artists/artist-1?ref=share',
        ),
        '/artists/artist-1?ref=share',
      );
    });
  });
}
