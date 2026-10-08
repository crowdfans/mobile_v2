import 'package:crowdfans/services/cutover_flags.dart';
import 'package:crowdfans/services/env_service.dart';
import 'package:flutter/foundation.dart';

/// API DigitalOcean viva (linha `prod` / flavor `digitalocean`).
/// Nunca usar crowdfans-app-dev* nem crowdfans-app-prod (DNS morto).
const kCrowdFansDoProdApi =
    'https://crowdfans-server-prod-h9qb6.ondigitalocean.app';

/// Default Cloud Run **staging** na linha GCP (`release/0.2` / flavor `gcp`).
///
/// Hostname provisório alinhado ao serviço `crowdfans-server-staging`
/// (Cloud Build). Substituir pela URL real via `API_GCP_BASE_URL` /
/// `API_GCP_STAGING_BASE_URL` assim que o deploy existir (pós CF-286).
const kCrowdFansGcpStagingApi =
    'https://crowdfans-server-staging.southamerica-east1.run.app';

/// Default Cloud Run **prod** GCP (cutover). Override com `API_GCP_PROD_BASE_URL`.
const kCrowdFansGcpProdApi =
    'https://crowdfans-server-prod.southamerica-east1.run.app';

/// Flavors / backends: `gcp` | `digitalocean` | `local`.
///
/// Ordem: `--dart-define=APP_FLAVOR=…` → `API_MODE` no `.env` → default
/// da linha (`gcp` em `release/0.2`).
const kDefaultAppFlavor = 'gcp';

String _cleanUrl(String value) => value.replaceAll(RegExp(r'/$'), '');

bool _isForbiddenApiHost(String url) {
  final lower = url.toLowerCase();
  return lower.contains('crowdfans-app-dev') ||
      lower.contains('crowdfans-dev-3zqbt') ||
      lower.contains('crowdfans-app-prod');
}

String _env(String key, [String fallback = '']) {
  if (kIsWeb) {
    return fallback;
  }
  return EnvService.get(key, fallback);
}

/// Flavor ativo (`gcp`, `digitalocean`, `local`, …).
String appFlavor() {
  const fromDefine = String.fromEnvironment('APP_FLAVOR');
  if (fromDefine.trim().isNotEmpty) {
    return fromDefine.trim().toLowerCase();
  }
  final fromEnv = _env('APP_FLAVOR').trim();
  if (fromEnv.isNotEmpty) {
    return fromEnv.toLowerCase();
  }
  return kDefaultAppFlavor;
}

/// Modo de API efetivo (alias de [appFlavor] + `API_MODE` + cutover flags).
String apiMode() {
  final cutover = CutoverFlags.apiBackendOverride();
  if (cutover != null) {
    return cutover;
  }
  const fromDefine = String.fromEnvironment('API_MODE');
  if (fromDefine.trim().isNotEmpty) {
    return _normalizeMode(fromDefine);
  }
  final fromEnv = _env('API_MODE').trim();
  if (fromEnv.isNotEmpty) {
    return _normalizeMode(fromEnv);
  }
  return _normalizeMode(appFlavor());
}

String _normalizeMode(String raw) {
  final mode = raw.trim().toLowerCase();
  switch (mode) {
    case 'do':
    case 'digital_ocean':
    case 'prod': // legado DO
      return 'digitalocean';
    case 'gcp_staging':
    case 'staging':
      return 'gcp';
    case 'gcp_prod':
      return 'gcp_prod';
    default:
      return mode;
  }
}

/// Resolve a base da API.
///
/// No **web**, não há `.env` no Hosting — usa dart-define / defaults do flavor.
/// Cutover (CF-359): kill-switch DO → [kCrowdFansDoProdApi]; ver [CutoverFlags].
String apiBaseUrl() {
  // Kill-switch tem prioridade sobre API_BASE_URL / RC URL (rollback seguro).
  if (CutoverFlags.forceDigitalOcean()) {
    return _digitalOceanUrl();
  }

  const fromDefine = String.fromEnvironment('API_BASE_URL');
  final forced = _cleanUrl(
    fromDefine.isNotEmpty ? fromDefine : _env('API_BASE_URL'),
  );
  if (forced.isNotEmpty) {
    return _ensureSafe(_rewriteLocalhost(forced), fallback: _fallbackForMode());
  }

  final cutoverUrl = CutoverFlags.apiBaseUrlOverride();
  if (cutoverUrl != null && cutoverUrl.isNotEmpty) {
    return _ensureSafe(
      _rewriteLocalhost(cutoverUrl),
      fallback: _fallbackForMode(),
    );
  }

  final mode = apiMode();

  if (mode == 'local') {
    const localDefine = String.fromEnvironment('API_LOCAL_BASE_URL');
    final local = _cleanUrl(
      localDefine.isNotEmpty
          ? localDefine
          : _env('API_LOCAL_BASE_URL', 'http://localhost:8080'),
    );
    return _rewriteLocalhost(local);
  }

  if (mode == 'digitalocean') {
    return _digitalOceanUrl();
  }

  if (mode == 'gcp_prod') {
    return _gcpProdUrl();
  }

  // Default GCP staging (linha release/0.2).
  return _gcpStagingUrl();
}

String _digitalOceanUrl() {
  const fromDefine = String.fromEnvironment('API_DIGITALOCEAN_BASE_URL');
  final fromEnv = _cleanUrl(
    fromDefine.isNotEmpty
        ? fromDefine
        : _env(
            'API_DIGITALOCEAN_BASE_URL',
            _env('API_PROD_BASE_URL', kCrowdFansDoProdApi),
          ),
  );
  return _ensureSafe(fromEnv, fallback: kCrowdFansDoProdApi);
}

String _gcpStagingUrl() {
  const baseDefine = String.fromEnvironment('API_GCP_BASE_URL');
  const stagingDefine = String.fromEnvironment('API_GCP_STAGING_BASE_URL');
  final fromDefine = baseDefine.isNotEmpty ? baseDefine : stagingDefine;
  final fromEnv = _cleanUrl(
    fromDefine.isNotEmpty
        ? fromDefine
        : _env(
            'API_GCP_BASE_URL',
            _env('API_GCP_STAGING_BASE_URL', kCrowdFansGcpStagingApi),
          ),
  );
  return _ensureSafe(fromEnv, fallback: kCrowdFansGcpStagingApi);
}

String _gcpProdUrl() {
  const fromDefine = String.fromEnvironment('API_GCP_PROD_BASE_URL');
  final fromEnv = _cleanUrl(
    fromDefine.isNotEmpty
        ? fromDefine
        : _env('API_GCP_PROD_BASE_URL', kCrowdFansGcpProdApi),
  );
  return _ensureSafe(fromEnv, fallback: kCrowdFansGcpProdApi);
}

String _fallbackForMode() {
  final mode = apiMode();
  if (mode == 'digitalocean') {
    return kCrowdFansDoProdApi;
  }
  if (mode == 'gcp_prod') {
    return kCrowdFansGcpProdApi;
  }
  return kCrowdFansGcpStagingApi;
}

/// Snapshot para debug na tela de login / erros de rede.
({String baseUrl, String mode, String flavor, bool cutoverForceDo})
apiConfigDebug() {
  return (
    baseUrl: apiBaseUrl(),
    mode: apiMode(),
    flavor: appFlavor(),
    cutoverForceDo: CutoverFlags.forceDigitalOcean(),
  );
}

String _ensureSafe(String baseUrl, {required String fallback}) {
  if (baseUrl.isEmpty || _isForbiddenApiHost(baseUrl)) {
    return fallback;
  }
  return baseUrl;
}

String _rewriteLocalhost(String baseUrl) {
  if (!baseUrl.contains('localhost') && !baseUrl.contains('127.0.0.1')) {
    return baseUrl;
  }
  if (defaultTargetPlatform == TargetPlatform.android) {
    return baseUrl
        .replaceAll('localhost', '10.0.2.2')
        .replaceAll('127.0.0.1', '10.0.2.2');
  }
  return baseUrl;
}
