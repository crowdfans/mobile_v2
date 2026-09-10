import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Preferência de tema.
///
/// O app CrowdFans é **somente light**; `system`/`dark` gravados em builds
/// antigas são migrados para [AppearanceThemePreference.light].
enum AppearanceThemePreference { system, light, dark }

/// Persistência do tema em `SharedPreferences`.
class AppearanceSettingsNotifier extends Notifier<AppearanceThemePreference> {
  static const _key = 'appearance-theme-preference';

  @override
  AppearanceThemePreference build() {
    Future<void>.microtask(_hydrate);
    return AppearanceThemePreference.light;
  }

  Future<void> _hydrate() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);
    // Força light mesmo se o usuário (ou default antigo "system") gravou dark.
    if (raw != AppearanceThemePreference.light.name) {
      await prefs.setString(_key, AppearanceThemePreference.light.name);
    }
    if (state != AppearanceThemePreference.light) {
      state = AppearanceThemePreference.light;
    }
  }

  /// Grava a preferência. Valores diferentes de light são ignorados.
  Future<void> setThemePreference(AppearanceThemePreference value) async {
    state = AppearanceThemePreference.light;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, AppearanceThemePreference.light.name);
  }
}

final appearanceSettingsProvider =
    NotifierProvider<AppearanceSettingsNotifier, AppearanceThemePreference>(
      AppearanceSettingsNotifier.new,
    );

/// Sempre [ThemeMode.light] — o app não segue o sistema nem dark.
ThemeMode appearanceThemeMode(AppearanceThemePreference preference) {
  return ThemeMode.light;
}
