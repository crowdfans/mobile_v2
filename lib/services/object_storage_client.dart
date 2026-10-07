import 'dart:typed_data';

import 'package:crowdfans/api/api_error.dart';
import 'package:crowdfans/services/media_url_shapes.dart';
import 'package:http/http.dart' as http;

/// Cliente de object store (GCS signed PUT na linha `release/0.2`).
///
/// **Não** usa [HttpService] / Bearer Firebase — signed URLs GCS quebram se
/// mandarmos `Authorization` ou headers fora do `X-Goog-SignedHeaders`
/// (tipicamente só `content-type` + `host`).
///
/// CF-358 · ver `docs/STORAGE_AUTH_CLIENTS.md`.
abstract final class ObjectStorageClient {
  /// Headers seguros para PUT/POST signed (GCS ou Spaces).
  ///
  /// - Sempre define `Content-Type` = [contentType] (deve bater com o presign).
  /// - Remove `Authorization` / `Bearer`.
  /// - No flavor gcp: remove `x-amz-*` (Spaces).
  static Map<String, String> headersForSignedUpload({
    required Map<String, String> fromServer,
    required String contentType,
  }) {
    final headers = <String, String>{
      for (final e in fromServer.entries) e.key: e.value,
      'Content-Type': contentType,
    };
    headers.removeWhere((key, _) {
      final k = key.toLowerCase();
      return k == 'authorization' || k.startsWith('proxy-');
    });
    if (mediaBackendExpectsGcs()) {
      headers.removeWhere((key, _) => key.toLowerCase().startsWith('x-amz-'));
    }
    return headers;
  }

  /// PUT/POST bytes na [uploadUrl] signed. Retorna status HTTP.
  static Future<int> putSignedBytes({
    required String uploadUrl,
    required String method,
    required Map<String, String> headers,
    required Uint8List bytes,
    Duration timeout = const Duration(seconds: 60),
  }) async {
    if (!isAllowedUploadUrl(uploadUrl)) {
      throw ApiError(
        mediaBackendExpectsGcs()
            ? 'URL de upload não é signed GCS (X-Goog-*).'
            : 'URL de upload inválida.',
        0,
      );
    }
    if (bytes.isEmpty) {
      throw ApiError('Payload de upload vazio.', 0);
    }

    final uri = Uri.parse(uploadUrl);
    final verb = method.trim().toUpperCase();
    try {
      final response = await (verb == 'POST'
              ? http.post(uri, headers: headers, body: bytes)
              : http.put(uri, headers: headers, body: bytes))
          .timeout(timeout);
      return response.statusCode;
    } catch (error) {
      if (error is ApiError) {
        rethrow;
      }
      throw ApiError('Falha de rede ao enviar a imagem.', 0);
    }
  }
}
