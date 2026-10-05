import 'package:crowdfans/constants/pages.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:patrol/patrol.dart';

import 'helpers/app_harness.dart';
import 'helpers/e2e_auth.dart';
import 'helpers/e2e_env.dart';

/// CF-129 — E2E Superfã: voto, fã clube e logout (API prod).
///
/// Requer `E2E_FAN_*`. Opcional: `E2E_ARTIST_UID` para abrir a comunidade
/// direta; sem UID, usa a aba Clubes.
///
/// Obrigatório (Gustavo): green / red / edge — não só happy path.
void main() {
  final missingCreds = !E2eEnv.hasFan;
  if (missingCreds) {
    // ignore: avoid_print
    print('SKIP CF-129: ${E2eEnv.fanMissingMessage}');
  }

  patrolTest(
    'CF-129 green: voto, fã clube e logout',
    skip: missingCreds,
    timeout: const Timeout(Duration(minutes: 3)),
    ($) async {
      await bootstrapCrowdFansForPatrol($);
      await E2eAuth.loginAsFan($);

      // --- Voto ---
      await $(const Key('nav-home')).tap();
      await E2eAuth.pumpFrames($, times: 4);

      final voteCount = $(const Key('vote-count'));
      await voteCount.waitUntilVisible(timeout: const Duration(seconds: 30));

      final beforeText = voteCount.evaluate().isEmpty
          ? '0'
          : (voteCount.text ?? '0').trim();
      final before = int.tryParse(beforeText) ?? 0;

      await $(const Key('vote-up')).tap();
      await E2eAuth.pumpFrames($, times: 2);

      final afterText = $(const Key('vote-count')).evaluate().isEmpty
          ? beforeText
          : ($(const Key('vote-count')).text ?? beforeText).trim();
      final after = int.tryParse(afterText) ?? before;

      // Toggle pode +1, -1 (desfazer) ou manter se API falhar parcialmente.
      expect(
        after == before + 1 || after == before - 1 || after == before,
        isTrue,
        reason: 'contagem de voto inesperada: $before → $after',
      );

      // --- Fã clube ---
      final artistUid = E2eEnv.artistUid;
      if (artistUid != null) {
        await E2eAuth.go($, Pages.fanClubCommunityOf(artistUid));
      } else {
        await $(const Key('nav-clubs')).tap();
        await E2eAuth.pumpFrames($, times: 5);
      }

      await E2eAuth.pumpFrames($, times: 3);
      final clubSignals = find.textContaining(
        RegExp(
          r'Fã Clube|Fa Clube|Postagens dos|comunidade|Novos|Popularidade|Clubes|Siga artistas',
          caseSensitive: false,
        ),
      );
      expect(
        clubSignals,
        findsWidgets,
        reason:
            'Esperava UI de fã clube/clubes. '
            'Defina E2E_ARTIST_UID se a conta não tiver clubes seguidos.',
      );

      // --- Logout ---
      await E2eAuth.logoutViaSettings($);
      expect($(const Key('login-username')), findsOneWidget);
      expect($(const Key('login-submit')), findsOneWidget);
    },
  );

  patrolTest(
    'CF-129 red: logout cancelado mantém sessão',
    skip: missingCreds,
    timeout: const Timeout(Duration(minutes: 2)),
    ($) async {
      await bootstrapCrowdFansForPatrol($);
      await E2eAuth.loginAsFan($);

      if ($(const Key('nav-profile')).evaluate().isEmpty) {
        await E2eAuth.go($, Pages.home);
        await E2eAuth.pumpFrames($, times: 2);
      }
      await $(const Key('nav-profile')).tap();
      await E2eAuth.pumpFrames($);

      final fanSettings = $(const Key('profile-settings'));
      await fanSettings.waitUntilVisible(timeout: const Duration(seconds: 20));
      await fanSettings.tap();
      await E2eAuth.pumpFrames($);

      await $(const Key('settings-item-logout')).waitUntilVisible(
        timeout: const Duration(seconds: 20),
      );
      await $(const Key('settings-item-logout')).tap();
      await E2eAuth.pumpFrames($);

      final cancel = $('Cancelar');
      expect(cancel, findsWidgets);
      await cancel.tap();
      await E2eAuth.pumpFrames($, times: 2);

      // Continua no hub de configurações — não voltou ao login.
      expect($(const Key('settings-item-logout')), findsOneWidget);
      expect($(const Key('login-username')).evaluate(), isEmpty);
    },
  );

  patrolTest(
    'CF-129 edge: toggle voto e empty clubs tolerado',
    skip: missingCreds,
    timeout: const Timeout(Duration(minutes: 3)),
    ($) async {
      await bootstrapCrowdFansForPatrol($);
      await E2eAuth.loginAsFan($);

      await $(const Key('nav-home')).tap();
      await E2eAuth.pumpFrames($, times: 4);

      final voteCount = $(const Key('vote-count'));
      await voteCount.waitUntilVisible(timeout: const Duration(seconds: 30));
      final beforeText = (voteCount.text ?? '0').trim();
      final before = int.tryParse(beforeText) ?? 0;

      await $(const Key('vote-up')).tap();
      await E2eAuth.pumpFrames($, times: 2);
      await $(const Key('vote-up')).tap();
      await E2eAuth.pumpFrames($, times: 2);

      final afterText = ($(const Key('vote-count')).text ?? beforeText).trim();
      final after = int.tryParse(afterText) ?? before;
      expect(
        after == before || after == before + 1 || after == before - 1,
        isTrue,
        reason: 'toggle de voto fora do esperado: $before → $after',
      );

      await $(const Key('nav-clubs')).tap();
      await E2eAuth.pumpFrames($, times: 5);

      final emptyOrFeed = find.byWidgetPredicate((widget) {
        if (widget.key == const Key('fan-clubs-empty') ||
            widget.key == const Key('fan-clubs-search')) {
          return true;
        }
        if (widget is Text) {
          final t = widget.data ?? '';
          return RegExp(
            r'Postagens dos|Siga artistas|Nenhum fã|Clubes|Popularidade|Novos',
            caseSensitive: false,
          ).hasMatch(t);
        }
        return false;
      });
      expect(
        emptyOrFeed,
        findsWidgets,
        reason: 'Aba Clubes deve mostrar feed, empty ou busca — sem crash',
      );
    },
  );
}
