import 'package:crowdfans/constants/pages.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:patrol/patrol.dart';

import 'e2e_env.dart';

/// Auth + navegação UI para Patrol autenticado (CF-128/129/130).
///
/// Keys alinhadas às telas reais (`login-username`, `nav-home`, etc.).
abstract final class E2eAuth {
  static const _homeTimeout = Duration(seconds: 45);
  static const _stepTimeout = Duration(seconds: 20);

  /// Pumps curtos — onboarding com vídeo nunca “settla”.
  static Future<void> pumpFrames(
    PatrolIntegrationTester $, {
    int times = 2,
  }) async {
    for (var i = 0; i < times; i++) {
      await $.pump(const Duration(milliseconds: 700));
    }
  }

  /// Navega via GoRouter a partir de um contexto montado.
  static Future<void> go(
    PatrolIntegrationTester $,
    String location,
  ) async {
    final element = $.tester.element(find.byType(Scaffold).first);
    GoRouter.of(element).go(location);
    await pumpFrames($, times: 3);
  }

  static Future<void> push(
    PatrolIntegrationTester $,
    String location,
  ) async {
    final element = $.tester.element(find.byType(Scaffold).first);
    GoRouter.of(element).push(location);
    await pumpFrames($, times: 3);
  }

  /// Onboarding → login superfã.
  static Future<void> openFanLogin(PatrolIntegrationTester $) async {
    await $(const Key('onboarding-superfan')).tap();
    await pumpFrames($);
    await $(const Key('login-username')).waitUntilVisible(
      timeout: _stepTimeout,
    );
  }

  /// Onboarding → login artista.
  static Future<void> openArtistLogin(PatrolIntegrationTester $) async {
    await $(const Key('onboarding-artist')).tap();
    await pumpFrames($);
    await $(const Key('login-username')).waitUntilVisible(
      timeout: _stepTimeout,
    );
  }

  /// Preenche e-mail/senha e toca Entrar (sem assert de destino).
  static Future<void> submitCredentials(
    PatrolIntegrationTester $,
    E2eCredentials credentials,
  ) async {
    await $(const Key('login-username')).enterText(credentials.email);
    await $(const Key('login-password')).enterText(credentials.password);
    await $(const Key('login-submit')).tap();
    await pumpFrames($, times: 4);
  }

  /// Login superfã via UI; espera bottom nav Home.
  static Future<void> loginAsFan(
    PatrolIntegrationTester $, {
    E2eCredentials? credentials,
  }) async {
    final creds = credentials ?? E2eEnv.fan;
    if (creds == null) {
      throw StateError(
        'E2E_FAN_EMAIL e E2E_FAN_PASSWORD são obrigatórios.',
      );
    }
    if ($(const Key('login-username')).evaluate().isEmpty) {
      if ($(const Key('onboarding-superfan')).evaluate().isNotEmpty) {
        await openFanLogin($);
      } else {
        await go($, Pages.loginFan);
        await $(const Key('login-username')).waitUntilVisible(
          timeout: _stepTimeout,
        );
      }
    }
    await submitCredentials($, creds);
    await $(const Key('nav-home')).waitUntilVisible(timeout: _homeTimeout);
  }

  /// Login artista via UI; espera bottom nav Home.
  static Future<void> loginAsArtist(
    PatrolIntegrationTester $, {
    E2eCredentials? credentials,
  }) async {
    final creds = credentials ?? E2eEnv.artist;
    if (creds == null) {
      throw StateError(
        'E2E_ARTIST_EMAIL e E2E_ARTIST_PASSWORD são obrigatórios.',
      );
    }
    if ($(const Key('login-username')).evaluate().isEmpty) {
      if ($(const Key('onboarding-artist')).evaluate().isNotEmpty) {
        await openArtistLogin($);
      } else {
        await go($, Pages.loginArtist);
        await $(const Key('login-username')).waitUntilVisible(
          timeout: _stepTimeout,
        );
      }
    }
    await submitCredentials($, creds);
    await $(const Key('nav-home')).waitUntilVisible(timeout: _homeTimeout);
  }

  /// Perfil → Configurações → Sair da conta (confirma diálogo).
  static Future<void> logoutViaSettings(PatrolIntegrationTester $) async {
    // Rotas como Meus Posts ficam fora do shell — volta ao feed se preciso.
    if ($(const Key('nav-profile')).evaluate().isEmpty) {
      await go($, Pages.home);
      await $(const Key('nav-home')).waitUntilVisible(timeout: _homeTimeout);
    }
    await $(const Key('nav-profile')).tap();
    await pumpFrames($);

    final artistSettings = $(const Key('artist-me-settings'));
    final fanSettings = $(const Key('profile-settings'));
    if (artistSettings.evaluate().isNotEmpty) {
      await artistSettings.tap();
    } else {
      await fanSettings.waitUntilVisible(timeout: _stepTimeout);
      await fanSettings.tap();
    }
    await pumpFrames($);

    await $(const Key('settings-item-logout')).waitUntilVisible(
      timeout: _stepTimeout,
    );
    await $(const Key('settings-item-logout')).tap();
    await pumpFrames($);

    // AppAlert.confirm — botão "Sair".
    final confirm = $('Sair');
    if (confirm.evaluate().isNotEmpty) {
      await confirm.tap();
      await pumpFrames($, times: 3);
    }

    await $(const Key('login-username')).waitUntilVisible(
      timeout: _homeTimeout,
    );
  }

  /// Artista: menu + → Criar Post → texto → publicar. Retorna o stamp usado.
  static Future<String> createArtistTextPost(
    PatrolIntegrationTester $, {
    String? stamp,
  }) async {
    final text = stamp ?? 'e2e-${DateTime.now().millisecondsSinceEpoch}';

    await $(const Key('nav-create')).tap();
    await pumpFrames($);
    await $(const Key('create-menu-create-post')).waitUntilVisible(
      timeout: _stepTimeout,
    );
    await $(const Key('create-menu-create-post')).tap();
    await pumpFrames($);

    await $(const Key('create-post-type-text')).waitUntilVisible(
      timeout: _stepTimeout,
    );
    await $(const Key('create-post-type-text')).tap();
    await pumpFrames($);

    await $(const Key('create-post-content')).enterText('load-e2e $text');
    await pumpFrames($);
    await $(const Key('create-post-submit')).tap();
    await pumpFrames($, times: 6);

    await $('Meus Posts').waitUntilVisible(timeout: _homeTimeout);
    expect($('load-e2e $text'), findsWidgets);
    return text;
  }

  /// Confirma diálogo genérico pelo rótulo do botão afirmativo.
  static Future<void> confirmDialog(
    PatrolIntegrationTester $,
    String confirmLabel,
  ) async {
    await pumpFrames($);
    final button = $(confirmLabel);
    if (button.evaluate().isNotEmpty) {
      await button.tap();
      await pumpFrames($, times: 2);
    }
  }
}
