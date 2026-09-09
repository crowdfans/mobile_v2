import 'package:crowdfans/constants/pages.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:patrol/patrol.dart';

import 'helpers/app_harness.dart';
import 'helpers/e2e_auth.dart';
import 'helpers/e2e_env.dart';

/// CF-128 — E2E artista posta + superfã comenta (API prod).
///
/// Requer `E2E_ARTIST_*` e `E2E_FAN_*`. Opcional: `E2E_ARTIST_UID` (perfil
/// do artista para achar o post) e `E2E_SEED_POST_ID` (atalho comentários).
void main() {
  final missingCreds = !(E2eEnv.hasArtist && E2eEnv.hasFan);
  if (missingCreds) {
    // ignore: avoid_print
    print('SKIP CF-128: ${E2eEnv.artistAndFanMissingMessage}');
  }

  patrolTest(
    'E2E: artista posta e superfã comenta',
    skip: missingCreds,
    timeout: const Timeout(Duration(minutes: 4)),
    ($) async {
      await bootstrapCrowdFansForPatrol($);

      final stamp = await () async {
        await E2eAuth.loginAsArtist($);
        return E2eAuth.createArtistTextPost($);
      }();

      await E2eAuth.logoutViaSettings($);
      await E2eAuth.loginAsFan($);

      final seedPostId = E2eEnv.seedPostId;
      final artistUid = E2eEnv.artistUid;
      final postLabel = 'load-e2e $stamp';

      if (artistUid != null) {
        await E2eAuth.go($, Pages.artistProfileOf(artistUid));
        await E2eAuth.pumpFrames($, times: 5);
      } else {
        await $(const Key('nav-home')).tap();
        await E2eAuth.pumpFrames($, times: 5);
      }

      // Preferir o post acabado de criar; senão seed; senão 1º comentários do feed.
      if ($(postLabel).evaluate().isNotEmpty) {
        await $(const Key('post-comments')).tap();
      } else if (seedPostId != null) {
        await E2eAuth.go(
          $,
          Pages.comments.replaceAll(':postId', seedPostId),
        );
      } else {
        await $(const Key('post-comments')).waitUntilVisible(
          timeout: const Duration(seconds: 30),
        );
        await $(const Key('post-comments')).tap();
      }

      await E2eAuth.pumpFrames($, times: 3);
      await $('Comentários').waitUntilVisible(
        timeout: const Duration(seconds: 20),
      );

      final comment = 'e2e-cmt-${DateTime.now().millisecondsSinceEpoch}';
      await $(const Key('comment-composer')).enterText(comment);
      await $(const Key('comment-submit')).tap();
      await E2eAuth.pumpFrames($, times: 4);

      expect($(comment), findsWidgets);
    },
  );
}
