import 'package:crowdfans/services/env_service.dart';
import 'package:flutter/foundation.dart';

/// Única API DigitalOcean válida (responde de verdade).
/// Nunca usar crowdfans-app-dev* nem crowdfans-app-prod (DNS morto).
const kCrowdFansProdApi =
    'https://crowdfans-server-prod-h9qb6.ondigitalocean.app';

/// Placeholder Cloud Run staging (região SP).
///
/// CF-286 ainda bloqueia project/billing — sem URL real. Substituir em
/// `.env` / `--dart-define=API_GCP_STAGING_BASE_URL=…` quando o serviço
/// `crowdfans-server` staging existir. Marcador `REPLACE_ME` / `XXXX` = não
/// usar em builds que falham se a API não resolver DNS.
const kCrowdFansGcpStagingApiPlaceholder =
    'https://REPLACE_ME-crowdfans-server-staging-XXXX.southamerica-east1.run.app';

String _cleanUrl(String value) => value.replaceAll(RegExp(r'/$'), '');

bool _isForbiddenApiHost(String url) {
  final lower = url.toLowerCase();
  return lower.contains('crowdfans-app-dev') ||
      lower.contains('crowdfans-dev-3zqbt') ||
      lower.contains('crowdfans-app-prod');
}

bool _isUnresolvedPlaceholder(String url) {
  final lower = url.toLowerCase();
  return lower.contains('replace_me') ||
      lower.contains('-xxxx.') ||
      lower.contains('xxxx.');
}

/// Resolve a base da API.
///
/// Modos (`API_MODE`):
/// - `digitalocean` (default) — server-prod DO vivo
/// - `local` — localhost (ou DO se localhost for rejeitado no device)
/// - `gcp` / `gcp_staging` — Cloud Run staging ([kCrowdFansGcpStagingApiPlaceholder]
///   até preencher `API_GCP_STAGING_BASE_URL`)
///
/// No **web**, ignora `.env`/dart-define e usa sempre [kCrowdFansProdApi]
/// (Firebase Hosting ignora `**/.*`, então o `.env` do bundle não sobe).
String apiBaseUrl() {
  if (kIsWeb) {
    return kCrowdFansProdApi;
  }

  const fromDefine = String.fromEnvironment('API_BASE_URL');
  final forced = _cleanUrl(
    fromDefine.isNotEmpty ? fromDefine : EnvService.get('API_BASE_URL'),
  );
  if (forced.isNotEmpty) {
    return _ensureSafe(_rewriteLocalhost(forced));
  }

  final mode = EnvService.get('API_MODE', 'digitalocean').toLowerCase();

  final digitalOcean = _ensureSafe(
    _cleanUrl(
      EnvService.get(
        'API_DIGITALOCEAN_BASE_URL',
        EnvService.get('API_PROD_BASE_URL', kCrowdFansProdApi),
      ),
    ),
  );

  if (mode == 'local') {
    final local = _cleanUrl(
      EnvService.get('API_LOCAL_BASE_URL', 'http://localhost:8080'),
    );
    final resolved = _rewriteLocalhost(local);
    if (resolved.contains('localhost') || resolved.contains('127.0.0.1')) {
      return digitalOcean;
    }
    return resolved;
  }

  if (mode == 'gcp' || mode == 'gcp_staging') {
    return resolveGcpStagingApiBaseUrl(
      EnvService.get('API_GCP_STAGING_BASE_URL'),
      fallbackDigitalOcean: digitalOcean,
    );
  }

  return digitalOcean;
}

/// Resolve URL GCP staging a partir do env (testável sem dotenv).
///
/// Placeholder / vazio / host morto → [fallbackDigitalOcean] (não quebra build
/// até CF-286 liberar o serviço).
String resolveGcpStagingApiBaseUrl(
  String configured, {
  String fallbackDigitalOcean = kCrowdFansProdApi,
}) {
  final cleaned = _cleanUrl(
    configured.isNotEmpty ? configured : kCrowdFansGcpStagingApiPlaceholder,
  );
  if (cleaned.isEmpty ||
      _isForbiddenApiHost(cleaned) ||
      _isUnresolvedPlaceholder(cleaned)) {
    return _ensureSafe(fallbackDigitalOcean);
  }
  return cleaned;
}

/// Snapshot para debug na tela de login / erros de rede.
({String baseUrl, String mode}) apiConfigDebug() {
  return (
    baseUrl: apiBaseUrl(),
    mode: kIsWeb
        ? 'digitalocean'
        : EnvService.get('API_MODE', 'digitalocean').toLowerCase(),
  );
}

String _ensureSafe(String baseUrl) {
  if (baseUrl.isEmpty || _isForbiddenApiHost(baseUrl)) {
    return kCrowdFansProdApi;
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
