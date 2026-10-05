import 'package:url_launcher/url_launcher.dart';

/// Abre URL externa (Spotify / redes) sem inventar destino.
Future<void> openExternalProfileUrl(String raw) async {
  final value = raw.trim();
  if (value.isEmpty) {
    return;
  }
  final uri = Uri.tryParse(value);
  if (uri == null) {
    return;
  }
  if (!uri.hasScheme) {
    return;
  }
  await launchUrl(uri, mode: LaunchMode.externalApplication);
}

/// Monta URL Instagram a partir do handle (`@user` ou `user`).
String? instagramProfileUrl(String handle) {
  final cleaned = handle.trim().replaceFirst(RegExp(r'^@'), '');
  if (cleaned.isEmpty) {
    return null;
  }
  return 'https://instagram.com/$cleaned';
}

/// Monta URL YouTube a partir do handle / canal.
String? youtubeProfileUrl(String handle) {
  final cleaned = handle.trim().replaceFirst(RegExp(r'^@'), '');
  if (cleaned.isEmpty) {
    return null;
  }
  if (cleaned.startsWith('http://') || cleaned.startsWith('https://')) {
    return cleaned;
  }
  return 'https://youtube.com/@$cleaned';
}

/// Rótulo de ouvintes / gênero na aba Sobre — sem inventar valor.
String artistSobreMetricLabel(String? value) {
  final trimmed = (value ?? '').trim();
  if (trimmed.isEmpty) {
    return 'Não informado';
  }
  return trimmed;
}
