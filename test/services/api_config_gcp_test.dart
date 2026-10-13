import 'package:crowdfans/services/api_config.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('GCP Cloud Run constants', () {
    test('green: server URI canônica', () {
      expect(
        kCrowdFansGcpApi,
        'https://crowdfans-server-peefddw6nq-rj.a.run.app',
      );
      expect(kCrowdFansGcpStagingApi, kCrowdFansGcpApi);
      expect(kCrowdFansGcpProdApi, kCrowdFansGcpApi);
    });

    test('green: financial URI canônica', () {
      expect(
        kCrowdFansGcpFinancialApi,
        'https://crowdfans-financial-peefddw6nq-rj.a.run.app',
      );
    });

    test('red: hosts DO mortos continuam proibidos no resolver', () {
      // apiBaseUrl com force via API_BASE_URL é coberto em gcp_flavor_gre_test.
      expect(kCrowdFansGcpApi.contains('crowdfans-app-'), isFalse);
      expect(kCrowdFansDoProdApi.contains('crowdfans-app-'), isFalse);
    });
  });
}
