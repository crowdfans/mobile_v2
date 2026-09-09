import 'package:crowdfans/services/env_service.dart';
import 'package:flutter/foundation.dart';

/// API DigitalOcean de produção (única base remota válida).
/// `crowdfans-app-prod` / `crowdfans-app-dev*` não resolvem DNS — não usar.
const _defaultProdApi =
    'https://crowdfans-server-prod-h9qb6.ondigitalocean.app';

String _cleanUrl(String value) => value.replaceAll(RegExp(r'/$'), '');

bool _isForbiddenApiHost(String url) {
  final lower = url.toLowerCase();
  return lower.contains('crowdfans-app-dev') ||
      lower.contains('crowdfans-dev-3zqbt') ||
      lower.contains('crowdfans-app-prod');
}

/// Resolve a base da API. DigitalOcean = sempre server-prod.
String apiBaseUrl() {
  const fromDefine = String.fromEnvironment('API_BASE_URL');
  final forced = _cleanUrl(
    fromDefine.isNotEmpty ? fromDefine : EnvService.get('API_BASE_URL'),
  );
  if (forced.isNotEmpty) {
    return _ensureProd(_rewriteLocalhost(forced));
  }

  final mode = EnvService.get('API_MODE', 'digitalocean').toLowerCase();

  final digitalOcean = _ensureProd(
    _cleanUrl(
      EnvService.get(
        'API_DIGITALOCEAN_BASE_URL',
        EnvService.get('API_PROD_BASE_URL', _defaultProdApi),
      ),
    ),
  );

  if (mode == 'local') {
    final local = _cleanUrl(
      EnvService.get('API_LOCAL_BASE_URL', 'http://localhost:8080'),
    );
    final resolved = _rewriteLocalhost(local);
    if (!kIsWeb &&
        (resolved.contains('localhost') || resolved.contains('127.0.0.1'))) {
      return digitalOcean;
    }
    return resolved;
  }

  return digitalOcean;
}

/// Snapshot para debug na tela de login.
({String baseUrl, String mode}) apiConfigDebug() {
  return (
    baseUrl: apiBaseUrl(),
    mode: EnvService.get('API_MODE', 'digitalocean').toLowerCase(),
  );
}

String _ensureProd(String baseUrl) {
  if (baseUrl.isEmpty || _isForbiddenApiHost(baseUrl)) {
    return _defaultProdApi;
  }
  return baseUrl;
}

String _rewriteLocalhost(String baseUrl) {
  if (!baseUrl.contains('localhost') && !baseUrl.contains('127.0.0.1')) {
    return baseUrl;
  }
  if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
    return baseUrl
        .replaceAll('localhost', '10.0.2.2')
        .replaceAll('127.0.0.1', '10.0.2.2');
  }
  return baseUrl;
}
