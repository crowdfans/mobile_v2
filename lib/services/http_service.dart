import 'dart:async';
import 'dart:convert';

import 'package:crowdfans/api/api_error.dart';
import 'package:crowdfans/services/api_config.dart';
import 'package:crowdfans/services/firebase_service.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

enum Method { get, post, put, patch, delete }

/// Cliente HTTP da API CrowdFans (envelope `{ success, message, data }`).
abstract final class HttpService {
  static Future<T> request<T>(
    String path, {
    Method method = Method.get,
    Object? body,
    bool requireAuth = true,
    Duration timeout = const Duration(seconds: 15),
    T Function(Object? json)? parse,
  }) async {
    final headers = <String, String>{'Content-Type': 'application/json'};
    if (requireAuth) {
      final token = await FirebaseService.currentIdToken();
      if (token == null) {
        throw ApiError('Sessão expirada. Faça login novamente.', 401);
      }
      headers['Authorization'] = 'Bearer $token';
    }

    final url = path.startsWith('http') ? path : '${apiBaseUrl()}$path';
    if (kDebugMode) {
      final debug = apiConfigDebug();
      debugPrint('[http] ${method.name.toUpperCase()} $url (api:${debug.mode})');
    }

    late http.Response response;
    try {
      final uri = Uri.parse(url);
      final encoded = body == null ? null : jsonEncode(body);
      response = await switch (method) {
        Method.get => http.get(uri, headers: headers),
        Method.post => http.post(uri, headers: headers, body: encoded),
        Method.put => http.put(uri, headers: headers, body: encoded),
        Method.patch => http.patch(uri, headers: headers, body: encoded),
        Method.delete => http.delete(uri, headers: headers, body: encoded),
      }.timeout(timeout);
    } on TimeoutException {
      throw ApiError('Tempo de resposta esgotado.', 408);
    } catch (error) {
      if (error is ApiError) {
        rethrow;
      }
      throw ApiError('Falha de rede ao falar com o servidor.', 0);
    }

    final payload = _parseEnvelope(response.body);
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw ApiError(
        payload['message'] as String? ?? 'Falha ao comunicar com o servidor.',
        response.statusCode,
      );
    }

    final data = payload['data'];
    if (parse != null) {
      return parse(data);
    }
    return data as T;
  }

  static Map<String, dynamic> _parseEnvelope(String body) {
    if (body.trim().isEmpty) {
      return {};
    }
    try {
      final decoded = jsonDecode(body);
      if (decoded is Map<String, dynamic>) {
        return decoded;
      }
      return {'data': decoded};
    } catch (_) {
      throw ApiError('O servidor retornou uma resposta inválida', 0);
    }
  }
}
