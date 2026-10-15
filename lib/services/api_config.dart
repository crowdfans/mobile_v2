import 'package:crowdfans/services/env_service.dart';
import 'package:flutter/foundation.dart';

/// API de produção no Cloud Run (projeto `crowdfans-prod`, região
/// `southamerica-east1`, serviço `crowdfans-server`).
const kCrowdFansProdApi =
    'https://crowdfans-server-peefddw6nq-rj.a.run.app';

String _cleanUrl(String value) => value.replaceAll(RegExp(r'/$'), '');

bool _isForbiddenApiHost(String url) {
  final lower = url.toLowerCase();
  return lower.contains('ondigitalocean.app') ||
      lower.contains('digitaloceanspaces.com') ||
      lower.contains('crowdfans-app-dev') ||
      lower.contains('crowdfans-dev-3zqbt') ||
      lower.contains('crowdfans-app-prod');
}

/// Resolve a base da API.
///
/// No **web**, ignora `.env`/dart-define e usa sempre [kCrowdFansProdApi]
/// (Firebase Hosting ignora `**/.*`, então o `.env` do bundle não sobe).
/// `API_MODE=local` continua em localhost (no Android, `10.0.2.2`).
String apiBaseUrl() {
  if (kIsWeb) {
    return kCrowdFansProdApi;
  }

  const fromDefine = String.fromEnvironment('API_BASE_URL');
  final forced = _cleanUrl(
    fromDefine.isNotEmpty ? fromDefine : EnvService.get('API_BASE_URL'),
  );
  if (forced.isNotEmpty) {
    return _ensureProd(_rewriteLocalhost(forced));
  }

  final mode = EnvService.get('API_MODE', 'gcp').toLowerCase();

  if (mode == 'local') {
    final local = _cleanUrl(
      EnvService.get('API_LOCAL_BASE_URL', 'http://localhost:8080'),
    );
    final resolved = _rewriteLocalhost(local);
    if (_isForbiddenApiHost(resolved)) {
      return _rewriteLocalhost('http://localhost:8080');
    }
    return resolved;
  }

  return _ensureProd(
    _cleanUrl(EnvService.get('API_PROD_BASE_URL', kCrowdFansProdApi)),
  );
}

/// Snapshot para debug na tela de login / erros de rede.
({String baseUrl, String mode}) apiConfigDebug() {
  return (
    baseUrl: apiBaseUrl(),
    mode: kIsWeb
        ? 'gcp'
        : EnvService.get('API_MODE', 'gcp').toLowerCase(),
  );
}

String _ensureProd(String baseUrl) {
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
