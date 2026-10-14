import 'dart:typed_data';

import 'package:crowdfans/api/api_error.dart';
import 'package:crowdfans/api/api_urls.dart';
import 'package:crowdfans/services/http_service.dart';
import 'package:crowdfans/services/media_url_shapes.dart';
import 'package:crowdfans/services/object_storage_client.dart';

/// Pasta de mídia no object store (`users/{uid}/{kind}/` — GCS na linha 0.2).
enum MediaKind { avatar, post, fanClub, fanLetter }

/// Limites CF-446 / CF-447 (bytes) — espelho do server.
const int kMaxAvatarBytes = 5_242_880; // 5 MiB
const int kMaxMediaBytes = 15_728_640; // 15 MiB (post / fan-club / fan-letter)

/// Content-Types de imagem aceitos no contrato GCS (CF-446).
const Set<String> kAllowedImageContentTypes = {
  'image/jpeg',
  'image/jpg',
  'image/png',
  'image/webp',
  'image/gif',
};

extension MediaKindApi on MediaKind {
  /// Valor enviado em `POST /api/v1/me/media/uploads`.
  String get apiValue {
    return switch (this) {
      MediaKind.avatar => 'avatar',
      MediaKind.post => 'post',
      MediaKind.fanClub => 'fan-club',
      MediaKind.fanLetter => 'fan-letter',
    };
  }

  /// Tamanho máximo do kind (bytes).
  int get maxBytes {
    return switch (this) {
      MediaKind.avatar => kMaxAvatarBytes,
      MediaKind.post || MediaKind.fanClub || MediaKind.fanLetter => kMaxMediaBytes,
    };
  }
}

class MediaPresignPayload {
  const MediaPresignPayload({
    required this.uploadUrl,
    required this.method,
    required this.headers,
    required this.publicUrl,
    this.objectKey = '',
    this.expiresIn = 0,
  });

  final String uploadUrl;
  final String method;
  final Map<String, String> headers;
  final String publicUrl;
  final String objectKey;
  final int expiresIn;

  factory MediaPresignPayload.fromJson(Object? json) {
    final map = (json as Map?)?.cast<String, dynamic>() ?? {};
    final rawHeaders = map['headers'] as Map? ?? {};
    return MediaPresignPayload(
      uploadUrl: map['uploadUrl'] as String? ?? '',
      method: (map['method'] as String? ?? 'PUT').toUpperCase(),
      headers: {
        for (final entry in rawHeaders.entries)
          entry.key.toString(): entry.value.toString(),
      },
      publicUrl: map['publicUrl'] as String? ?? '',
      objectKey: map['objectKey'] as String? ?? '',
      expiresIn: (map['expiresIn'] as num?)?.toInt() ?? 0,
    );
  }
}

/// Upload de imagem via presign API + [ObjectStorageClient] (GCS signed PUT).
///
/// Flavor **gcp** (`release/0.2`): URLs GCS / signed `X-Goog-*` — sem Spaces.
/// Auth Firebase só na chamada `POST /me/media/uploads` ([HttpService]);
/// o PUT ao bucket **não** leva Bearer (CF-358).
///
/// Alinhado a CF-446: `contentLength` opcional, allowlist de imagem,
/// `x-goog-content-length-range` reenviado no PUT.
abstract final class MediaService {
  /// URL já pública (http/https) — não precisa de upload.
  static bool isRemoteMediaUrl(String uri) {
    return RegExp(r'^https?:\/\/', caseSensitive: false).hasMatch(uri.trim());
  }

  /// Content-Type de imagem permitido pelo contrato de upload (CF-446).
  static bool isAllowedImageContentType(String contentType) {
    final normalized = contentType.trim().toLowerCase();
    if (normalized == 'image/jpg') {
      return true;
    }
    return kAllowedImageContentTypes.contains(normalized);
  }

  /// Infere Content-Type a partir do mime do picker ou da extensão.
  ///
  /// No flavor GCS o contrato de upload é só imagem (CF-446): não infere `video/*`
  /// a partir da extensão — cai em `image/jpeg` e a allowlist rejeita se for vídeo.
  static String inferContentType(String uri, [String? mimeType]) {
    final explicit = mimeType?.trim().toLowerCase();
    if (explicit != null && explicit.isNotEmpty) {
      if (explicit == 'image/jpg') {
        return 'image/jpeg';
      }
      if (explicit.startsWith('image/')) {
        return explicit;
      }
      if (explicit.startsWith('video/') && !mediaBackendExpectsGcs()) {
        return explicit;
      }
    }
    final path = uri.trim().toLowerCase().split('?').first;
    if (path.endsWith('.png')) {
      return 'image/png';
    }
    if (path.endsWith('.webp')) {
      return 'image/webp';
    }
    if (path.endsWith('.gif')) {
      return 'image/gif';
    }
    if (!mediaBackendExpectsGcs() &&
        (path.endsWith('.mp4') ||
            path.endsWith('.mov') ||
            path.endsWith('.m4v'))) {
      return 'video/mp4';
    }
    return 'image/jpeg';
  }

  /// Resolve URI local (bytes) para URL pública; http(s) permitido passa direto.
  static Future<String?> resolveMediaUrl({
    required String uri,
    required MediaKind kind,
    String? mimeType,
    Uint8List? bytes,
  }) async {
    final trimmed = uri.trim();
    if (trimmed.isEmpty) {
      return null;
    }
    if (isRemoteMediaUrl(trimmed) && bytes == null) {
      if (!isAllowedPublicMediaUrl(trimmed)) {
        throw ApiError(
          mediaBackendExpectsGcs()
              ? 'URL de mídia inválida para GCS (Spaces/DO não são aceitos neste flavor).'
              : 'URL de mídia inválida.',
          0,
        );
      }
      return trimmed;
    }
    if (bytes == null || bytes.isEmpty) {
      throw ApiError('Não foi possível ler a imagem selecionada.', 0);
    }
    return uploadBytes(
      bytes: bytes,
      kind: kind,
      contentType: inferContentType(trimmed, mimeType),
    );
  }

  /// Presign na API (Bearer) + PUT signed no object store (sem Bearer).
  ///
  /// Envia `contentLength` (CF-446) para o server rejeitar cedo (`payload_too_large`).
  static Future<String> uploadBytes({
    required Uint8List bytes,
    required MediaKind kind,
    required String contentType,
  }) async {
    if (bytes.isEmpty) {
      throw ApiError('A imagem selecionada está vazia.', 0);
    }
    final normalizedType = contentType.trim().toLowerCase() == 'image/jpg'
        ? 'image/jpeg'
        : contentType.trim();
    if (mediaBackendExpectsGcs() &&
        !isAllowedImageContentType(normalizedType)) {
      throw ApiError(
        'Tipo de mídia não suportado no upload GCS ($normalizedType). Use JPEG, PNG, WebP ou GIF.',
        0,
      );
    }
    if (bytes.length > kind.maxBytes) {
      throw ApiError(
        'Imagem acima do limite (${kind.maxBytes} bytes) para ${kind.apiValue}.',
        0,
      );
    }

    final presign = await HttpService.request<MediaPresignPayload>(
      ApiUrls.meMediaUploads,
      method: Method.post,
      body: {
        'kind': kind.apiValue,
        'contentType': normalizedType,
        'contentLength': bytes.length,
      },
      parse: MediaPresignPayload.fromJson,
    );
    _assertPresignShapes(presign);

    final headers = ObjectStorageClient.headersForSignedUpload(
      fromServer: presign.headers,
      contentType: normalizedType,
    );
    final status = await ObjectStorageClient.putSignedBytes(
      uploadUrl: presign.uploadUrl,
      method: presign.method,
      headers: headers,
      bytes: bytes,
    );
    if (status < 200 || status >= 300) {
      final backend =
          mediaBackendExpectsGcs() ? 'Cloud Storage' : 'armazenamento';
      throw ApiError(
        'Falha ao enviar a imagem para o $backend ($status).',
        status,
      );
    }
    return presign.publicUrl;
  }

  static void _assertPresignShapes(MediaPresignPayload presign) {
    if (presign.uploadUrl.isEmpty || presign.publicUrl.isEmpty) {
      throw ApiError('O servidor não devolveu URL de upload.', 0);
    }
    if (!isAllowedUploadUrl(presign.uploadUrl)) {
      throw ApiError(
        mediaBackendExpectsGcs()
            ? 'URL de upload não é signed GCS (X-Goog-*). Spaces/DO bloqueado no flavor gcp.'
            : 'URL de upload inválida.',
        0,
      );
    }
    if (!isAllowedPublicMediaUrl(presign.publicUrl)) {
      throw ApiError(
        mediaBackendExpectsGcs()
            ? 'publicUrl não tem shape GCS (storage.googleapis.com/…).'
            : 'publicUrl inválida.',
        0,
      );
    }
  }
}
