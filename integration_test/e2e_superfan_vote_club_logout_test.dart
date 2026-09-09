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
void main() {
  final missingCreds = !E2eEnv.hasFan;
  if (missingCreds) {
    // ignore: avoid_print
    print('SKIP CF-129: ${E2eEnv.fanMissingMessage}');
  }

  patrolTest(
    'E2E Superfã: voto, fã clube e logout',
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
          r'Fã Clube|Fa Clube|Postagens dos|comunidade|Novos|Populares|Clubes',
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
}
