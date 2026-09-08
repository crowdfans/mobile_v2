import 'dart:convert';

import 'package:crowdfans/api/api_error.dart';
import 'package:crowdfans/services/env_service.dart';
import 'package:http/http.dart' as http;

/// GIF da Tenor para o compositor de comentários.
class CommentGifItem {
  const CommentGifItem({
    required this.id,
    required this.previewUrl,
    required this.originalUrl,
  });

  final String id;
  final String previewUrl;
  final String originalUrl;
}

/// Busca GIFs na Tenor (featured ou search).
abstract final class CommentGifService {
  static const _clientKey = 'crowdfans-mobile';

  /// Featured quando [query] está vazio; senão search.
  static Future<List<CommentGifItem>> fetchCommentGifs([
    String query = '',
  ]) async {
    final tenorApiKey = EnvService.get('TENOR_API_KEY', 'LIVDSRZULELA');
    final encodedQuery = Uri.encodeQueryComponent(query.trim());
    final uri = query.trim().isEmpty
        ? Uri.parse(
            'https://tenor.googleapis.com/v2/featured?key=$tenorApiKey&limit=24&media_filter=minimal&contentfilter=medium&client_key=$_clientKey&locale=pt_BR',
          )
        : Uri.parse(
            'https://tenor.googleapis.com/v2/search?key=$tenorApiKey&q=$encodedQuery&limit=24&media_filter=minimal&contentfilter=medium&client_key=$_clientKey&locale=pt_BR',
          );
    late http.Response response;
    try {
      response = await http.get(uri).timeout(const Duration(seconds: 15));
    } catch (_) {
      throw ApiError('Falha ao carregar GIFs.', 0);
    }
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw ApiError('Falha ao carregar GIFs.', response.statusCode);
    }
    final payload = jsonDecode(response.body);
    final results = payload is Map
        ? payload['results'] as List? ?? const []
        : const [];
    final items = <CommentGifItem>[];
    for (final raw in results) {
      final item = raw as Map? ?? {};
      final formats = item['media_formats'] as Map? ?? {};
      final tiny = formats['tinygif'] as Map? ?? {};
      final gif = formats['gif'] as Map? ?? {};
      final previewUrl = tiny['url'] as String? ?? '';
      final originalUrl = gif['url'] as String? ?? previewUrl;
      final id = '${item['id'] ?? ''}';
      if (id.isEmpty || previewUrl.isEmpty || originalUrl.isEmpty) {
        continue;
      }
      items.add(
        CommentGifItem(
          id: id,
          previewUrl: previewUrl,
          originalUrl: originalUrl,
        ),
      );
    }
    return items;
  }
}
