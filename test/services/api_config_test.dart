import 'package:crowdfans/services/api_config.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  setUp(() {
    dotenv.loadFromString(envString: '', isOptional: true);
  });

  tearDown(() {
    dotenv.loadFromString(envString: '', isOptional: true);
  });

  group('defaults release/0.2 (gcp)', () {
    test('appFlavor default é gcp', () {
      expect(appFlavor(), 'gcp');
    });

    test('apiMode default é gcp', () {
      expect(apiMode(), 'gcp');
    });

    test('apiBaseUrl aponta Cloud Run staging (não DO)', () {
      final url = apiBaseUrl();
      expect(url, kCrowdFansGcpStagingApi);
      expect(url.contains('ondigitalocean.app'), isFalse);
      expect(url.contains('crowdfans-app-dev'), isFalse);
      expect(url.contains('crowdfans-app-prod'), isFalse);
    });
  });

  group('digitalocean via .env', () {
    test('API_MODE=digitalocean usa server-prod DO', () {
      dotenv.loadFromString(
        envString:
            'API_MODE=digitalocean\n'
            'API_DIGITALOCEAN_BASE_URL=$kCrowdFansDoProdApi\n',
      );
      expect(apiMode(), 'digitalocean');
      expect(apiBaseUrl(), kCrowdFansDoProdApi);
    });
  });

  group('gcp overrides', () {
    test('API_GCP_BASE_URL sobrescreve staging', () {
      dotenv.loadFromString(
        envString:
            'API_MODE=gcp\n'
            'API_GCP_BASE_URL=https://my-staging.example.run.app\n',
      );
      expect(apiBaseUrl(), 'https://my-staging.example.run.app');
    });

    test('API_MODE=gcp_prod usa prod GCP', () {
      dotenv.loadFromString(
        envString:
            'API_MODE=gcp_prod\n'
            'API_GCP_PROD_BASE_URL=https://my-prod.example.run.app\n',
      );
      expect(apiMode(), 'gcp_prod');
      expect(apiBaseUrl(), 'https://my-prod.example.run.app');
    });
  });

  group('hosts mortos', () {
    test('API_BASE_URL morto cai no fallback do modo gcp', () {
      dotenv.loadFromString(
        envString:
            'API_MODE=gcp\n'
            'API_BASE_URL=https://crowdfans-app-prod.ondigitalocean.app\n',
      );
      expect(apiBaseUrl(), kCrowdFansGcpStagingApi);
    });

    test('API_DIGITALOCEAN morto cai no DO vivo', () {
      dotenv.loadFromString(
        envString:
            'API_MODE=digitalocean\n'
            'API_DIGITALOCEAN_BASE_URL=https://crowdfans-app-dev-3zqbt.ondigitalocean.app\n',
      );
      expect(apiBaseUrl(), kCrowdFansDoProdApi);
    });
  });

  group('aliases', () {
    test('prod → digitalocean', () {
      dotenv.loadFromString(envString: 'API_MODE=prod\n');
      expect(apiMode(), 'digitalocean');
    });

    test('staging → gcp', () {
      dotenv.loadFromString(envString: 'API_MODE=staging\n');
      expect(apiMode(), 'gcp');
    });
  });

  test('apiConfigDebug inclui flavor', () {
    final debug = apiConfigDebug();
    expect(debug.flavor, 'gcp');
    expect(debug.mode, 'gcp');
    expect(debug.baseUrl, isNotEmpty);
  });
}
