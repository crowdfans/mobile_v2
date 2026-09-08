import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Preferência de tema (espelho do `appearance-settings-store`).
enum AppearanceThemePreference { system, light, dark }

/// Persistência do tema em `SharedPreferences`.
class AppearanceSettingsNotifier extends Notifier<AppearanceThemePreference> {
  static const _key = 'appearance-theme-preference';

  @override
  AppearanceThemePreference build() {
    Future<void>.microtask(_hydrate);
    return AppearanceThemePreference.system;
  }

  Future<void> _hydrate() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);
    final parsed = switch (raw) {
      'light' => AppearanceThemePreference.light,
      'dark' => AppearanceThemePreference.dark,
      _ => AppearanceThemePreference.system,
    };
    if (parsed != state) {
      state = parsed;
    }
  }

  /// Grava a preferência e aplica no app.
  Future<void> setThemePreference(AppearanceThemePreference value) async {
    state = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, value.name);
  }
}

final appearanceSettingsProvider =
    NotifierProvider<AppearanceSettingsNotifier, AppearanceThemePreference>(
      AppearanceSettingsNotifier.new,
    );

/// [ThemeMode] correspondente à preferência.
ThemeMode appearanceThemeMode(AppearanceThemePreference preference) {
  return switch (preference) {
    AppearanceThemePreference.system => ThemeMode.system,
    AppearanceThemePreference.light => ThemeMode.light,
    AppearanceThemePreference.dark => ThemeMode.dark,
  };
}
