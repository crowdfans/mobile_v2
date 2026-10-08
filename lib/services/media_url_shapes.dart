import 'package:crowdfans/services/api_config.dart';
import 'package:crowdfans/services/cutover_flags.dart';
import 'package:crowdfans/services/env_service.dart';

/// Formas de URL de mídia: GCS (linha `release/0.2` / flavor `gcp`) vs Spaces (DO).
///
/// Alinhado ao server `ObjectStore` / `GCSStore.PublicURL`:
/// `https://storage.googleapis.com/{bucket}/{objectKey}`
/// Signed PUT: query `X-Goog-*` no host storage.googleapis.com.
/// Sem live bucket — só reconhecimento de shape (CF-339).

/// Bucket GCS placeholder (staging) até TF/CF-286.
const kCrowdFansGcsMediaBucketStub = 'crowdfans-media-gcp';

/// Base pública default GCS (path-style).
String kCrowdFansGcsPublicBaseDefault([String bucket = kCrowdFansGcsMediaBucketStub]) =>
    'https://storage.googleapis.com/$bucket';

/// Hosts DO Spaces — proibidos no flavor `gcp` (greenfield).
bool isSpacesMediaUrl(String url) {
  final lower = url.trim().toLowerCase();
  return lower.contains('digitaloceanspaces.com') ||
      lower.contains('cdn.digitaloceanspaces.com');
}

/// URL pública GCS path-style ou virtual-hosted.
bool isGcsPublicUrl(String url) {
  final uri = Uri.tryParse(url.trim());
  if (uri == null || !uri.hasScheme) {
    return false;
  }
  final host = uri.host.toLowerCase();
  if (host == 'storage.googleapis.com' || host == 'storage.cloud.google.com') {
    // path: /{bucket}/{object...}
    return uri.pathSegments.length >= 2;
  }
  // virtual-hosted: {bucket}.storage.googleapis.com/{object}
  if (host.endsWith('.storage.googleapis.com') &&
      uri.pathSegments.isNotEmpty) {
    return true;
  }
  // CDN / base custom (MEDIA_GCS_PUBLIC_BASE_URL)
  final custom = mediaGcsPublicBaseOverride();
  if (custom != null && custom.isNotEmpty) {
    return url.trim().toLowerCase().startsWith(custom.toLowerCase());
  }
  return false;
}

/// Signed PUT/GET GCS (V4) — query com `X-Goog-Algorithm` / `X-Goog-Signature`.
bool isGcsSignedUploadUrl(String url) {
  final uri = Uri.tryParse(url.trim());
  if (uri == null || !uri.hasScheme) {
    return false;
  }
  final host = uri.host.toLowerCase();
  final gcsHost = host == 'storage.googleapis.com' ||
      host == 'storage.cloud.google.com' ||
      host.endsWith('.storage.googleapis.com');
  if (!gcsHost) {
    return false;
  }
  final params = uri.queryParameters.map(
    (k, v) => MapEntry(k.toLowerCase(), v),
  );
  return params.containsKey('x-goog-algorithm') ||
      params.containsKey('x-goog-signature') ||
      params.containsKey('x-goog-credential');
}

String mediaGcsBucket() {
  const fromDefine = String.fromEnvironment('MEDIA_GCS_BUCKET');
  if (fromDefine.trim().isNotEmpty) {
    return fromDefine.trim();
  }
  final fromEnv = EnvService.get(
    'MEDIA_GCS_BUCKET',
    kCrowdFansGcsMediaBucketStub,
  ).trim();
  return fromEnv.isEmpty ? kCrowdFansGcsMediaBucketStub : fromEnv;
}

/// Override opcional (CDN). Vazio → path-style `storage.googleapis.com/{bucket}`.
String? mediaGcsPublicBaseOverride() {
  const fromDefine = String.fromEnvironment('MEDIA_GCS_PUBLIC_BASE_URL');
  if (fromDefine.trim().isNotEmpty) {
    return fromDefine.trim().replaceAll(RegExp(r'/$'), '');
  }
  final fromEnv = EnvService.get('MEDIA_GCS_PUBLIC_BASE_URL').trim();
  if (fromEnv.isEmpty) {
    return null;
  }
  return fromEnv.replaceAll(RegExp(r'/$'), '');
}

/// Base pública configurável (`MEDIA_GCS_PUBLIC_BASE_URL` / dart-define).
String mediaGcsPublicBaseUrl() {
  return mediaGcsPublicBaseOverride() ??
      kCrowdFansGcsPublicBaseDefault(mediaGcsBucket());
}

/// Flavor gcp (e local na linha 0.2) → só GCS; digitalocean → Spaces ok.
/// Cutover [CutoverFlags.mediaBackendOverride] / kill-switch pode forçar Spaces.
bool mediaBackendExpectsGcs() {
  final override = CutoverFlags.mediaBackendOverride();
  if (override == 'spaces') {
    return false;
  }
  if (override == 'gcs') {
    return true;
  }
  final flavor = appFlavor();
  return flavor == 'gcp' || flavor == 'local' || flavor == 'gcp_prod';
}

/// URL pública aceitável para o flavor ativo.
bool isAllowedPublicMediaUrl(String url) {
  final trimmed = url.trim();
  if (trimmed.isEmpty) {
    return false;
  }
  if (!RegExp(r'^https?:\/\/', caseSensitive: false).hasMatch(trimmed)) {
    return false;
  }
  if (mediaBackendExpectsGcs()) {
    if (isSpacesMediaUrl(trimmed)) {
      return false;
    }
    return isGcsPublicUrl(trimmed);
  }
  // Flavor digitalocean: Spaces ou GCS (transição).
  return isSpacesMediaUrl(trimmed) || isGcsPublicUrl(trimmed);
}

/// Upload URL aceitável no flavor ativo.
bool isAllowedUploadUrl(String url) {
  final trimmed = url.trim();
  if (trimmed.isEmpty) {
    return false;
  }
  if (mediaBackendExpectsGcs()) {
    if (isSpacesMediaUrl(trimmed)) {
      return false;
    }
    return isGcsSignedUploadUrl(trimmed) || isGcsPublicUrl(trimmed);
  }
  return trimmed.startsWith('http');
}

/// Monta public URL GCS de exemplo (stubs/testes; sem rede).
String buildGcsPublicObjectUrl(String objectKey, {String? bucket}) {
  final key = objectKey.replaceFirst(RegExp(r'^/+'), '');
  final base = bucket != null && bucket.trim().isNotEmpty
      ? (mediaGcsPublicBaseOverride() ??
          kCrowdFansGcsPublicBaseDefault(bucket.trim()))
      : mediaGcsPublicBaseUrl();
  return '$base/$key';
}
