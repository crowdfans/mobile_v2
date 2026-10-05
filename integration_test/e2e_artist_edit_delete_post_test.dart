import 'package:crowdfans/constants/pages.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:patrol/patrol.dart';

import 'helpers/app_harness.dart';
import 'helpers/e2e_auth.dart';
import 'helpers/e2e_env.dart';

/// CF-130 — E2E Artista: editar e apagar o próprio post (API prod).
///
/// Requer `E2E_ARTIST_*`. Cria o post no setup (não depende de fixture prévia).
///
/// Obrigatório (Gustavo): green / red / edge — nunca só happy path.
void main() {
  final missingCreds = !E2eEnv.hasArtist;
  if (missingCreds) {
    // ignore: avoid_print
    print('SKIP CF-130: ${E2eEnv.artistMissingMessage}');
  }

  // ---------------------------------------------------------------------------
  // GREEN — cria → Meus posts (menu +) → edita → apaga
  // ---------------------------------------------------------------------------
  patrolTest(
    'GREEN: artista edita e apaga o próprio post',
    skip: missingCreds,
    timeout: const Timeout(Duration(minutes: 4)),
    ($) async {
      await bootstrapCrowdFansForPatrol($);
      await E2eAuth.loginAsArtist($);

      final stamp = await E2eAuth.createArtistTextPost($);
      expect($('load-e2e $stamp'), findsWidgets);

      // Ticket: nav-create → create-menu-my-posts (após create já está em Meus
      // Posts; volta à Home e reabre pela key do fluxo).
      await E2eAuth.go($, Pages.home);
      await $(const Key('nav-home')).waitUntilVisible(
        timeout: const Duration(seconds: 30),
      );
      await $(const Key('nav-create')).tap();
      await E2eAuth.pumpFrames($);
      await $(const Key('create-menu-my-posts')).waitUntilVisible(
        timeout: const Duration(seconds: 15),
      );
      await $(const Key('create-menu-my-posts')).tap();
      await E2eAuth.pumpFrames($, times: 3);
      await $('Meus Posts').waitUntilVisible(
        timeout: const Duration(seconds: 30),
      );
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

  // ---------------------------------------------------------------------------
  // RED — senha inválida / cancelar delete mantém o post
  // ---------------------------------------------------------------------------
  patrolTest(
    'RED: login artista com senha inválida permanece no form',
    skip: !E2eEnv.hasArtist,
    timeout: const Timeout(Duration(minutes: 2)),
    ($) async {
      await bootstrapCrowdFansForPatrol($);
      final artist = E2eEnv.artist!;
      await E2eAuth.openArtistLogin($);
      await E2eAuth.submitCredentials(
        $,
        E2eCredentials(
          email: artist.email,
          password: 'senha-invalida-cf130!',
        ),
      );
      await $(const Key('login-username')).waitUntilVisible(
        timeout: const Duration(seconds: 20),
      );
      expect($(const Key('nav-home')).evaluate(), isEmpty);
    },
  );

  patrolTest(
    'RED: cancelar delete mantém o post na lista',
    skip: missingCreds,
    timeout: const Timeout(Duration(minutes: 4)),
    ($) async {
      await bootstrapCrowdFansForPatrol($);
      await E2eAuth.loginAsArtist($);

      final stamp = await E2eAuth.createArtistTextPost($);
      final label = 'load-e2e $stamp';
      expect($(label), findsWidgets);

      await $(const Key('my-posts-item-menu')).tap();
      await E2eAuth.pumpFrames($);
      await $(const Key('my-posts-delete')).tap();
      await E2eAuth.pumpFrames($);
      // Cancela o AppAlert.confirm
      await E2eAuth.confirmDialog($, 'Cancelar');
      await E2eAuth.pumpFrames($, times: 2);

      expect($(label), findsWidgets);
      expect($('Meus Posts'), findsOneWidget);
    },
  );

  // ---------------------------------------------------------------------------
  // EDGE — texto longo (280) na edição continua publicável
  // ---------------------------------------------------------------------------
  patrolTest(
    'EDGE: editar post com texto no limite 280 e salvar',
    skip: missingCreds,
    timeout: const Timeout(Duration(minutes: 4)),
    ($) async {
      await bootstrapCrowdFansForPatrol($);
      await E2eAuth.loginAsArtist($);

      final stamp = await E2eAuth.createArtistTextPost($);
      expect($('load-e2e $stamp'), findsWidgets);

      await $(const Key('my-posts-item-menu')).tap();
      await E2eAuth.pumpFrames($);
      await $(const Key('my-posts-edit')).tap();
      await E2eAuth.pumpFrames($, times: 3);
      await $('Editar Post').waitUntilVisible(
        timeout: const Duration(seconds: 20),
      );

      final longText = 'E' * 280;
      await $(const Key('create-post-content')).enterText(longText);
      await $(const Key('create-post-submit')).tap();
      await E2eAuth.pumpFrames($, times: 6);

      await $('Meus Posts').waitUntilVisible(
        timeout: const Duration(seconds: 30),
      );
      // Lista trunca visualmente; conferir prefixo + menu ainda presente.
      expect($(longText.substring(0, 40)), findsWidgets);
      expect($(const Key('my-posts-item-menu')), findsWidgets);

      // Limpa o post longo (não deixar lixo no feed/prod).
      await $(const Key('my-posts-item-menu')).tap();
      await E2eAuth.pumpFrames($);
      await $(const Key('my-posts-delete')).tap();
      await E2eAuth.confirmDialog($, 'Deletar');
      await E2eAuth.pumpFrames($, times: 4);
    },
  );
}
