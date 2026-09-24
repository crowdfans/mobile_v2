import 'package:shared_preferences/shared_preferences.dart';

const _artistAlertsKey = 'notifications.artistAlertsEnabled';

/// Preferências locais “Por artista” (alertas on/off por id).
abstract final class NotificationArtistAlertsStore {
  static Future<Map<String, bool>> load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getStringList(_artistAlertsKey) ?? const [];
      final out = <String, bool>{};
      for (final entry in raw) {
        final parts = entry.split('=');
        if (parts.length != 2 || parts[0].isEmpty) {
          continue;
        }
        out[parts[0]] = parts[1] == '1';
      }
      return out;
    } catch (_) {
      return {};
    }
  }

  static Future<void> save(Map<String, bool> values) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList(_artistAlertsKey, [
        for (final e in values.entries) '${e.key}=${e.value ? '1' : '0'}',
      ]);
    } catch (_) {}
  }

  static Future<bool> isEnabled(String artistId, {bool fallback = true}) async {
    final all = await load();
    return all[artistId] ?? fallback;
  }

  static Future<void> setEnabled(String artistId, bool enabled) async {
    final next = await load();
    next[artistId] = enabled;
    await save(next);
  }
}
