import 'package:crowdfans/services/env_service.dart';
import 'package:crowdfans/services/firebase_service.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/foundation.dart';

/// Feature flags de cutover GCP ↔ DigitalOcean (dual-run).
///
/// Chaves alinhadas ao Firebase Remote Config (mesmos nomes).
/// Hydrate: RC live (quando apiKey ≠ stub) → `--dart-define` → `.env` →
/// [applyRemoteValues] — ver `docs/REMOTE_CONFIG_CUTOVER.md` (CF-359).
///
/// **Defaults seguros:** sem override → comportamento do flavor atual
/// (`gcp` na linha `release/0.2`). Kill-switch força rollback para API DO.
abstract final class CutoverFlags {
  /// Kill-switch: força API DigitalOcean (+ mídia Spaces).
  static const keyForceDigitalOcean = 'cf_cutover_force_digitalocean';

  /// Override de backend API: `gcp` | `gcp_prod` | `digitalocean` | vazio.
  static const keyApiBackend = 'cf_api_backend';

  /// Override de mídia: `gcs` | `spaces` | vazio.
  static const keyMediaBackend = 'cf_media_backend';

  /// URL absoluta opcional (após safe-host). Vazio = resolver por mode/flavor.
  static const keyApiBaseUrl = 'cf_api_base_url';

  /// Defaults in-app / template Firebase (neutros — não forçam DO).
  static const Map<String, Object> inAppDefaults = {
    keyForceDigitalOcean: false,
    keyApiBackend: '',
    keyMediaBackend: '',
    keyApiBaseUrl: '',
  };

  /// Valores vindos do Remote Config (ou testes).
  static final Map<String, String> _remote = {};

  /// Override de fetch para unit tests (não chama Firebase).
  @visibleForTesting
  static Future<Map<String, String>?> Function()? debugFetchOverride;

  /// Injeta mapa RC (Firebase ou fixture). Não faz fetch de rede.
  static void applyRemoteValues(Map<String, String> values) {
    _remote
      ..clear()
      ..addAll({
        for (final e in values.entries)
          if (e.key.trim().isNotEmpty) e.key.trim(): e.value.trim(),
      });
  }

  /// Limpa overlays RC (unit tests).
  static void resetRemoteValues() {
    _remote.clear();
  }

  /// Pós-[FirebaseService.initialize]: fetch RC se keys reais; senão no-op.
  ///
  /// Fail-open: erro de rede/RC não derruba o app — mantém env/dart-define.
  static Future<void> bootstrap() async {
    if (debugFetchOverride != null) {
      final values = await debugFetchOverride!();
      if (values != null) {
        applyRemoteValues(values);
      }
      return;
    }

    if (FirebaseService.usingStubOptions) {
      // Stubs REPLACE_ME_* — fetch live falharia; env/dart-define bastam.
      return;
    }

    try {
      final values = await _fetchLiveRemoteConfig();
      if (values != null) {
        applyRemoteValues(values);
      }
    } catch (error, stack) {
      if (kDebugMode) {
        debugPrint(
          '[CutoverFlags] Remote Config indisponível (fail-open): $error\n$stack',
        );
      }
    }
  }

  /// Lê parâmetros cutover do Firebase Remote Config e devolve mapa string.
  static Future<Map<String, String>?> _fetchLiveRemoteConfig() async {
    final remoteConfig = FirebaseRemoteConfig.instance;
    await remoteConfig.setConfigSettings(
      RemoteConfigSettings(
        fetchTimeout: const Duration(seconds: 10),
        // Debug: fetch rápido; release: 1h (próximo cold start).
        minimumFetchInterval:
            kDebugMode ? Duration.zero : const Duration(hours: 1),
      ),
    );
    await remoteConfig.setDefaults(inAppDefaults);
    await remoteConfig.fetchAndActivate();

    final forceDo = remoteConfig.getBool(keyForceDigitalOcean);
    return {
      keyForceDigitalOcean: forceDo ? 'true' : 'false',
      keyApiBackend: remoteConfig.getString(keyApiBackend),
      keyMediaBackend: remoteConfig.getString(keyMediaBackend),
      keyApiBaseUrl: remoteConfig.getString(keyApiBaseUrl),
    };
  }

  static String _raw(String key) {
    final remote = _remote[key];
    if (remote != null && remote.isNotEmpty) {
      return remote;
    }
    final fromDefine = _fromDefine(key);
    if (fromDefine.isNotEmpty) {
      return fromDefine;
    }
    if (kIsWeb) {
      return '';
    }
    final envKey = switch (key) {
      keyForceDigitalOcean => 'CF_CUTOVER_FORCE_DIGITALOCEAN',
      keyApiBackend => 'CF_API_BACKEND',
      keyMediaBackend => 'CF_MEDIA_BACKEND',
      keyApiBaseUrl => 'CF_API_BASE_URL',
      _ => key.toUpperCase(),
    };
    final fromEnv = EnvService.get(envKey).trim();
    if (fromEnv.isNotEmpty) {
      return fromEnv;
    }
    return EnvService.get(key).trim();
  }

  static String _fromDefine(String key) {
    // fromEnvironment exige literal; espelha as chaves RC.
    switch (key) {
      case keyForceDigitalOcean:
        return const String.fromEnvironment(
          'cf_cutover_force_digitalocean',
        ).trim();
      case keyApiBackend:
        return const String.fromEnvironment('cf_api_backend').trim();
      case keyMediaBackend:
        return const String.fromEnvironment('cf_media_backend').trim();
      case keyApiBaseUrl:
        return const String.fromEnvironment('cf_api_base_url').trim();
      default:
        return '';
    }
  }

  static bool _asBool(String raw) {
    final v = raw.trim().toLowerCase();
    return v == '1' || v == 'true' || v == 'yes' || v == 'on';
  }

  /// Kill-switch de rollback URL → DigitalOcean.
  static bool forceDigitalOcean() => _asBool(_raw(keyForceDigitalOcean));

  /// Override de mode API ou null (flavor/API_MODE decide).
  static String? apiBackendOverride() {
    if (forceDigitalOcean()) {
      return 'digitalocean';
    }
    final raw = _raw(keyApiBackend).toLowerCase();
    if (raw.isEmpty) {
      return null;
    }
    return switch (raw) {
      'do' || 'digital_ocean' => 'digitalocean',
      // `prod` = Make/API GCP prod (mesmo host Cloud Run hoje); DO = kill-switch.
      'gcp_prod' || 'prod' => 'gcp_prod',
      'gcp_staging' || 'staging' => 'gcp',
      'gcp' || 'digitalocean' || 'local' => raw,
      _ => null,
    };
  }

  /// Override mídia: `gcs` | `spaces` | null.
  static String? mediaBackendOverride() {
    if (forceDigitalOcean()) {
      return 'spaces';
    }
    final raw = _raw(keyMediaBackend).toLowerCase();
    if (raw.isEmpty) {
      return null;
    }
    if (raw == 'gcs' || raw == 'gcp' || raw == 'cloud_storage') {
      return 'gcs';
    }
    if (raw == 'spaces' || raw == 'do' || raw == 'digitalocean') {
      return 'spaces';
    }
    return null;
  }

  /// URL forçada pelo RC/env (ignorada se kill-switch DO estiver ativo).
  static String? apiBaseUrlOverride() {
    if (forceDigitalOcean()) {
      return null;
    }
    final raw = _raw(keyApiBaseUrl);
    if (raw.isEmpty) {
      return null;
    }
    return raw.replaceAll(RegExp(r'/$'), '');
  }

  static ({
    bool forceDo,
    String? apiBackend,
    String? mediaBackend,
    String? apiBaseUrl,
  })
  debugSnapshot() {
    return (
      forceDo: forceDigitalOcean(),
      apiBackend: apiBackendOverride(),
      mediaBackend: mediaBackendOverride(),
      apiBaseUrl: apiBaseUrlOverride(),
    );
  }
}
