import 'dart:convert';

import 'package:crowdfans/models/home_feed.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _favoritesKey = 'sidebar.favoriteArtistIds';
const _recentKey = 'sidebar.recentArtists';
const _recentLimit = 8;

/// Favoritos e visitados recentemente da sidebar da Home.
abstract final class SidebarArtistsStore {
  static Future<Set<String>> loadFavoriteIds() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return (prefs.getStringList(_favoritesKey) ?? const []).toSet();
    } catch (_) {
      return {};
    }
  }

  static Future<void> saveFavoriteIds(Set<String> ids) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList(_favoritesKey, ids.toList());
    } catch (_) {}
  }

  static Future<Set<String>> toggleFavorite(String artistId) async {
    final next = {...await loadFavoriteIds()};
    if (next.contains(artistId)) {
      next.remove(artistId);
    } else {
      next.add(artistId);
    }
    await saveFavoriteIds(next);
    return next;
  }

  static Future<List<HomeFollowedArtist>> loadRecent() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_recentKey);
      if (raw == null || raw.isEmpty) {
        return const [];
      }
      final decoded = jsonDecode(raw);
      if (decoded is! List) {
        return const [];
      }
      return [for (final item in decoded) HomeFollowedArtist.fromJson(item)];
    } catch (_) {
      return const [];
    }
  }

  static Future<void> recordVisit(HomeFollowedArtist artist) async {
    if (artist.id.trim().isEmpty) {
      return;
    }
    final current = await loadRecent();
    final next = [
      artist,
      for (final item in current)
        if (item.id != artist.id) item,
    ].take(_recentLimit).toList();
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(
        _recentKey,
        jsonEncode([for (final item in next) item.toJson()]),
      );
    } catch (_) {}
  }
}
