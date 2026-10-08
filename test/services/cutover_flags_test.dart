import 'package:crowdfans/services/api_config.dart';
import 'package:crowdfans/services/cutover_flags.dart';
import 'package:crowdfans/services/media_url_shapes.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  setUp(() {
    CutoverFlags.resetRemoteValues();
    dotenv.loadFromString(envString: 'APP_FLAVOR=gcp\n', isOptional: true);
  });

  tearDown(() {
    CutoverFlags.resetRemoteValues();
    dotenv.loadFromString(envString: '', isOptional: true);
  });

  group('GREEN — defaults flavor + kill-switch rollback', () {
    test('sem flags: API Cloud Run staging e mídia GCS', () {
      expect(apiMode(), 'gcp');
      expect(apiBaseUrl(), kCrowdFansGcpStagingApi);
      expect(mediaBackendExpectsGcs(), isTrue);
      expect(CutoverFlags.forceDigitalOcean(), isFalse);
      expect(apiConfigDebug().cutoverForceDo, isFalse);
    });

    test('kill-switch RC força API DigitalOcean e Spaces', () {
      CutoverFlags.applyRemoteValues({
        CutoverFlags.keyForceDigitalOcean: 'true',
      });
      expect(CutoverFlags.forceDigitalOcean(), isTrue);
      expect(apiMode(), 'digitalocean');
      expect(apiBaseUrl(), kCrowdFansDoProdApi);
      expect(mediaBackendExpectsGcs(), isFalse);
      expect(apiConfigDebug().cutoverForceDo, isTrue);
    });

    test('cf_api_backend=gcp_prod aponta Cloud Run prod', () {
      CutoverFlags.applyRemoteValues({
        CutoverFlags.keyApiBackend: 'gcp_prod',
      });
      expect(apiMode(), 'gcp_prod');
      expect(apiBaseUrl(), kCrowdFansGcpProdApi);
      expect(mediaBackendExpectsGcs(), isTrue);
    });
  });

  group('RED — URL morta / kill-switch ignora override GCP', () {
    test('cf_api_base_url com host morto cai no fallback do mode', () {
      CutoverFlags.applyRemoteValues({
        CutoverFlags.keyApiBaseUrl:
            'https://crowdfans-app-prod.ondigitalocean.app',
      });
      expect(apiBaseUrl(), kCrowdFansGcpStagingApi);
    });

    test('kill-switch ignora cf_api_base_url Cloud Run', () {
      CutoverFlags.applyRemoteValues({
        CutoverFlags.keyForceDigitalOcean: '1',
        CutoverFlags.keyApiBaseUrl: kCrowdFansGcpStagingApi,
        CutoverFlags.keyApiBackend: 'gcp',
      });
      expect(apiBaseUrl(), kCrowdFansDoProdApi);
      expect(apiMode(), 'digitalocean');
    });
  });

  group('EDGE — media override / env alias / empty RC', () {
    test('cf_media_backend=spaces no flavor gcp permite Spaces shape', () {
      CutoverFlags.applyRemoteValues({
        CutoverFlags.keyMediaBackend: 'spaces',
      });
      expect(mediaBackendExpectsGcs(), isFalse);
      expect(
        isAllowedPublicMediaUrl(
          'https://crowdfans.nyc3.digitaloceanspaces.com/users/u1/a.jpg',
        ),
        isTrue,
      );
    });

    test('CF_CUTOVER_FORCE_DIGITALOCEAN via .env', () {
      dotenv.loadFromString(
        envString: 'APP_FLAVOR=gcp\nCF_CUTOVER_FORCE_DIGITALOCEAN=yes\n',
        isOptional: true,
      );
      expect(CutoverFlags.forceDigitalOcean(), isTrue);
      expect(apiBaseUrl(), contains('ondigitalocean.app'));
    });

    test('applyRemoteValues vazio restaura defaults do flavor', () {
      CutoverFlags.applyRemoteValues({
        CutoverFlags.keyForceDigitalOcean: 'true',
      });
      expect(apiBaseUrl(), kCrowdFansDoProdApi);
      CutoverFlags.applyRemoteValues({});
      expect(apiBaseUrl(), kCrowdFansGcpStagingApi);
      expect(mediaBackendExpectsGcs(), isTrue);
    });
  });
}
