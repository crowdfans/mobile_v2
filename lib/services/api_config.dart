import 'package:crowdfans/services/env_service.dart';
import 'package:flutter/foundation.dart';

const _defaultDevApi = 'https://crowdfans-app-dev-3zqbt.ondigitalocean.app';
const _defaultProdApi = 'https://crowdfans-app-prod.ondigitalocean.app';

String _cleanUrl(String value) => value.replaceAll(RegExp(r'/$'), '');

/// Resolve a base da API (mesmo critério do Expo `api-config.ts`).
String apiBaseUrl() {
  final forced = _cleanUrl(EnvService.get('API_BASE_URL'));
  if (forced.isNotEmpty) {
    return _rewriteLocalhost(forced);
  }

  final mode = EnvService.get('API_MODE', 'digitalocean').toLowerCase();
  final projectId = EnvService.get('FIREBASE_PROJECT_ID');
  final defaultDo = projectId == 'crowdfans-prod'
      ? _defaultProdApi
      : _defaultDevApi;

  final digitalOcean = _cleanUrl(
    EnvService.get('API_DIGITALOCEAN_BASE_URL', defaultDo),
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
