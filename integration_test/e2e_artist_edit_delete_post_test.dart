import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:patrol/patrol.dart';

import 'helpers/app_harness.dart';
import 'helpers/e2e_auth.dart';
import 'helpers/e2e_env.dart';

/// CF-130 — E2E Artista: editar e apagar o próprio post (API prod).
///
/// Requer `E2E_ARTIST_*`. Cria o post no setup (não depende de fixture prévia).
void main() {
  final missingCreds = !E2eEnv.hasArtist;
  if (missingCreds) {
    // ignore: avoid_print
    print('SKIP CF-130: ${E2eEnv.artistMissingMessage}');
  }

  patrolTest(
    'E2E Artista: editar e apagar o próprio post',
    skip: missingCreds,
    timeout: const Timeout(Duration(minutes: 4)),
    ($) async {
      await bootstrapCrowdFansForPatrol($);
      await E2eAuth.loginAsArtist($);

      final stamp = await E2eAuth.createArtistTextPost($);
      expect($('load-e2e $stamp'), findsWidgets);

      // --- Editar ---
      final editStamp = 'edit-${DateTime.now().millisecondsSinceEpoch}';
      await $(const Key('my-posts-item-menu')).tap();
      await E2eAuth.pumpFrames($);
      await $(const Key('my-posts-edit')).waitUntilVisible(
        timeout: const Duration(seconds: 15),
      );
      await $(const Key('my-posts-edit')).tap();
      await E2eAuth.pumpFrames($, times: 3);

      await $('Editar Post').waitUntilVisible(
        timeout: const Duration(seconds: 20),
      );
      await $(const Key('create-post-content')).enterText('editado $editStamp');
      await $(const Key('create-post-submit')).tap();
      await E2eAuth.pumpFrames($, times: 6);

      await $('Meus Posts').waitUntilVisible(
        timeout: const Duration(seconds: 30),
      );
      expect($('editado $editStamp'), findsWidgets);

      // --- Apagar ---
      await $(const Key('my-posts-item-menu')).tap();
      await E2eAuth.pumpFrames($);
      await $(const Key('my-posts-delete')).tap();
      await E2eAuth.confirmDialog($, 'Deletar');
      await E2eAuth.pumpFrames($, times: 4);

      expect($('editado $editStamp'), findsNothing);
      expect($('Meus Posts'), findsOneWidget);
    },
  );
}
