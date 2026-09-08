import 'dart:typed_data';

import 'package:crowdfans/api/api_error.dart';
import 'package:crowdfans/api/api_urls.dart';
import 'package:crowdfans/services/http_service.dart';
import 'package:http/http.dart' as http;

/// Pasta de mídia no Spaces (`users/{uid}/{kind}/`).
enum MediaKind { avatar, post, fanClub, fanLetter }

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
}

class _PresignPayload {
  const _PresignPayload({
    required this.uploadUrl,
    required this.method,
    required this.headers,
    required this.publicUrl,
  });

  final String uploadUrl;
  final String method;
  final Map<String, String> headers;
  final String publicUrl;

  factory _PresignPayload.fromJson(Object? json) {
    final map = (json as Map?)?.cast<String, dynamic>() ?? {};
    final rawHeaders = map['headers'] as Map? ?? {};
    return _PresignPayload(
      uploadUrl: map['uploadUrl'] as String? ?? '',
      method: (map['method'] as String? ?? 'PUT').toUpperCase(),
      headers: {
        for (final entry in rawHeaders.entries)
          entry.key.toString(): entry.value.toString(),
      },
      publicUrl: map['publicUrl'] as String? ?? '',
    );
  }
}

/// Upload de imagem via presign (`POST /api/v1/me/media/uploads` + PUT Spaces).
abstract final class MediaService {
  /// URL já pública (http/https) — não precisa de upload.
  static bool isRemoteMediaUrl(String uri) {
    return RegExp(r'^https?:\/\/', caseSensitive: false).hasMatch(uri.trim());
  }

  /// Infere Content-Type a partir do mime do picker ou da extensão.
  static String inferContentType(String uri, [String? mimeType]) {
    final explicit = mimeType?.trim().toLowerCase();
    if (explicit == 'image/jpeg' ||
        explicit == 'image/jpg' ||
        explicit == 'image/png' ||
        explicit == 'image/webp' ||
        explicit == 'image/gif') {
      return explicit == 'image/jpg' ? 'image/jpeg' : explicit!;
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
    return 'image/jpeg';
  }

  /// Resolve URI local (bytes) para URL pública; http(s) passa direto.
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

  /// Envia bytes ao Spaces via PUT presigned e devolve a URL pública.
  static Future<String> uploadBytes({
    required Uint8List bytes,
    required MediaKind kind,
    required String contentType,
  }) async {
    if (bytes.isEmpty) {
      throw ApiError('A imagem selecionada está vazia.', 0);
    }
    final presign = await HttpService.request<_PresignPayload>(
      ApiUrls.meMediaUploads,
      method: Method.post,
      body: {'kind': kind.apiValue, 'contentType': contentType},
      parse: _PresignPayload.fromJson,
    );
    if (presign.uploadUrl.isEmpty || presign.publicUrl.isEmpty) {
      throw ApiError('O servidor não devolveu URL de upload.', 0);
    }
    final headers = <String, String>{
      ...presign.headers,
      'Content-Type': contentType,
    };
    late http.Response uploaded;
    try {
      final uri = Uri.parse(presign.uploadUrl);
      uploaded =
          await (presign.method == 'POST'
                  ? http.post(uri, headers: headers, body: bytes)
                  : http.put(uri, headers: headers, body: bytes))
              .timeout(const Duration(seconds: 60));
    } catch (_) {
      throw ApiError('Falha de rede ao enviar a imagem.', 0);
    }
    if (uploaded.statusCode < 200 || uploaded.statusCode >= 300) {
      throw ApiError(
        'Falha ao enviar a imagem para o Spaces (${uploaded.statusCode}).',
        uploaded.statusCode,
      );
    }
    return presign.publicUrl;
  }
}
