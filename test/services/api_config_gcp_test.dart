import 'package:crowdfans/services/api_config.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('resolveGcpStagingApiBaseUrl', () {
    test('green: URL Cloud Run real é aceita', () {
      const url =
          'https://crowdfans-server-staging-abc123-uc.a.run.app';
      expect(
        resolveGcpStagingApiBaseUrl(url),
        url,
      );
    });

    test('red: placeholder REPLACE_ME cai no fallback DO', () {
      expect(
        resolveGcpStagingApiBaseUrl(kCrowdFansGcpStagingApiPlaceholder),
        kCrowdFansProdApi,
      );
    });

    test('red: vazio usa placeholder e cai no fallback DO', () {
      expect(resolveGcpStagingApiBaseUrl(''), kCrowdFansProdApi);
    });

    test('red: host DO morto é rejeitado → fallback', () {
      expect(
        resolveGcpStagingApiBaseUrl(
          'https://crowdfans-app-prod.ondigitalocean.app',
        ),
        kCrowdFansProdApi,
      );
    });

    test('edge: trailing slash é removido', () {
      const url =
          'https://crowdfans-server-staging-abc123-uc.a.run.app';
      expect(
        resolveGcpStagingApiBaseUrl('$url/'),
        url,
      );
    });

    test('edge: fallback custom quando placeholder', () {
      expect(
        resolveGcpStagingApiBaseUrl(
          '',
          fallbackDigitalOcean: 'https://example.test',
        ),
        'https://example.test',
      );
    });
  });
}
