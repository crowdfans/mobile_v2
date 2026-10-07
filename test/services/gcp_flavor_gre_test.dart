import 'package:crowdfans/services/api_config.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_test/flutter_test.dart';

/// Stub GRE para `APP_FLAVOR=gcp` contra URLs Cloud Run placeholder.
///
/// Cloud Run ainda não está live (CF-286+) — estes testes validam o
/// **wiring** (flavor → URL), não HTTP real. Suite live = CF-362.
void main() {
  setUp(() {
    dotenv.loadFromString(envString: '', isOptional: true);
  });

  tearDown(() {
    dotenv.loadFromString(envString: '', isOptional: true);
  });

  group('GREEN — flavor gcp resolve Cloud Run staging placeholder', () {
    test('default sem .env → gcp + kCrowdFansGcpStagingApi', () {
      expect(appFlavor(), 'gcp');
      expect(apiMode(), 'gcp');
      expect(apiBaseUrl(), kCrowdFansGcpStagingApi);
      expect(apiBaseUrl(), contains('.run.app'));
      expect(apiBaseUrl(), contains('southamerica-east1'));
    });

    test('API_MODE=gcp + API_GCP_* do config/gcp.json shape', () {
      dotenv.loadFromString(
        envString:
            'APP_FLAVOR=gcp\n'
            'API_MODE=gcp\n'
            'API_GCP_BASE_URL=https://crowdfans-server-staging.southamerica-east1.run.app\n'
            'API_GCP_STAGING_BASE_URL=https://crowdfans-server-staging.southamerica-east1.run.app\n',
      );
      final debug = apiConfigDebug();
      expect(debug.flavor, 'gcp');
      expect(debug.mode, 'gcp');
      expect(debug.baseUrl, kCrowdFansGcpStagingApi);
      expect(debug.baseUrl.contains('ondigitalocean'), isFalse);
    });

    test('override staging custom ainda é .run.app', () {
      dotenv.loadFromString(
        envString:
            'API_MODE=gcp\n'
            'API_GCP_BASE_URL=https://crowdfans-server-staging-abc123.southamerica-east1.run.app\n',
      );
      expect(apiBaseUrl(), endsWith('.run.app'));
      expect(apiBaseUrl().contains('ondigitalocean'), isFalse);
    });
  });

  group('RED — inválido / bloqueado / negado', () {
    test('host DO morto crowdfans-app-prod → fallback gcp staging', () {
      dotenv.loadFromString(
        envString:
            'API_MODE=gcp\n'
            'API_BASE_URL=https://crowdfans-app-prod.ondigitalocean.app\n',
      );
      expect(apiBaseUrl(), kCrowdFansGcpStagingApi);
      expect(apiBaseUrl().contains('crowdfans-app-prod'), isFalse);
    });

    test('host DO morto crowdfans-app-dev* → fallback gcp staging', () {
      dotenv.loadFromString(
        envString:
            'API_MODE=gcp\n'
            'API_BASE_URL=https://crowdfans-app-dev-3zqbt.ondigitalocean.app\n',
      );
      expect(apiBaseUrl(), kCrowdFansGcpStagingApi);
    });

    test('API_GCP_BASE_URL vazio → não cai em DO; usa placeholder gcp', () {
      dotenv.loadFromString(
        envString:
            'API_MODE=gcp\n'
            'API_GCP_BASE_URL=\n'
            'API_DIGITALOCEAN_BASE_URL=$kCrowdFansDoProdApi\n',
      );
      expect(apiBaseUrl(), kCrowdFansGcpStagingApi);
      expect(apiBaseUrl(), isNot(kCrowdFansDoProdApi));
    });

    test('gcp_prod com URL morta → fallback kCrowdFansGcpProdApi', () {
      dotenv.loadFromString(
        envString:
            'API_MODE=gcp_prod\n'
            'API_GCP_PROD_BASE_URL=https://crowdfans-app-prod.ondigitalocean.app\n',
      );
      expect(apiMode(), 'gcp_prod');
      expect(apiBaseUrl(), kCrowdFansGcpProdApi);
    });
  });

  group('EDGE — borda / zero / rede / teclado-prep', () {
    test('trailing slash na URL é normalizado', () {
      dotenv.loadFromString(
        envString:
            'API_MODE=gcp\n'
            'API_GCP_BASE_URL=https://crowdfans-server-staging.southamerica-east1.run.app/\n',
      );
      expect(apiBaseUrl().endsWith('/'), isFalse);
      expect(apiBaseUrl(), kCrowdFansGcpStagingApi);
    });

    test('API_MODE=local aponta loopback (não Cloud Run)', () {
      dotenv.loadFromString(
        envString:
            'APP_FLAVOR=local\n'
            'API_MODE=local\n'
            'API_LOCAL_BASE_URL=http://127.0.0.1:8080\n',
      );
      expect(apiMode(), 'local');
      final url = apiBaseUrl();
      // Android test VM reescreve para 10.0.2.2; desktop mantém 127.0.0.1.
      expect(
        url.contains('127.0.0.1') || url.contains('10.0.2.2'),
        isTrue,
      );
      expect(url.contains('.run.app'), isFalse);
    });

    test('apiConfigDebug expõe flavor/mode/base para erros de rede', () {
      dotenv.loadFromString(
        envString: 'APP_FLAVOR=gcp\nAPI_MODE=gcp\n',
      );
      final debug = apiConfigDebug();
      expect(debug.flavor, 'gcp');
      expect(debug.mode, 'gcp');
      expect(debug.baseUrl, isNotEmpty);
      // Mensagem de login/rede usa mode+baseUrl (mapLoginError).
      expect('${debug.mode}:${debug.baseUrl}', contains('gcp'));
      expect('${debug.mode}:${debug.baseUrl}', contains('run.app'));
    });

    test('placeholder staging ≠ prod gcp', () {
      expect(kCrowdFansGcpStagingApi, isNot(kCrowdFansGcpProdApi));
      expect(kCrowdFansGcpStagingApi, contains('staging'));
      expect(kCrowdFansGcpProdApi, contains('prod'));
    });
  });
}
