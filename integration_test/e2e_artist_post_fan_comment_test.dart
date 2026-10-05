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
///
/// Obrigatório (Gustavo): green / red / edge — nunca só happy path.
void main() {
  final missingCreds = !(E2eEnv.hasArtist && E2eEnv.hasFan);
  if (missingCreds) {
    // ignore: avoid_print
    print('SKIP CF-128: ${E2eEnv.artistAndFanMissingMessage}');
  }

  // ---------------------------------------------------------------------------
  // GREEN — artista publica e superfã comenta com sucesso
  // ---------------------------------------------------------------------------
  patrolTest(
    'GREEN: artista posta e superfã comenta',
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

  // ---------------------------------------------------------------------------
  // RED — credencial inválida / comentário vazio não publica
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
          password: 'senha-invalida-cf128!',
        ),
      );
      // Continua no form de login — Home não aparece.
      await $(const Key('login-username')).waitUntilVisible(
        timeout: const Duration(seconds: 20),
      );
      expect($(const Key('nav-home')).evaluate(), isEmpty);
    },
  );

  patrolTest(
    'RED: composer vazio não envia comentário',
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

      final artistUid = E2eEnv.artistUid;
      final postLabel = 'load-e2e $stamp';
      if (artistUid != null) {
        await E2eAuth.go($, Pages.artistProfileOf(artistUid));
        await E2eAuth.pumpFrames($, times: 5);
      } else {
        await $(const Key('nav-home')).tap();
        await E2eAuth.pumpFrames($, times: 5);
      }

      if ($(postLabel).evaluate().isNotEmpty) {
        await $(const Key('post-comments')).tap();
      } else if (E2eEnv.seedPostId != null) {
        await E2eAuth.go(
          $,
          Pages.comments.replaceAll(':postId', E2eEnv.seedPostId!),
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

      // Idle: sem rascunho → botão enviar ausente (só GIF/smile).
      expect($(const Key('comment-composer')).evaluate(), isNotEmpty);
      expect($(const Key('comment-submit')).evaluate(), isEmpty);

      // Espaços só — ainda não habilita envio.
      await $(const Key('comment-composer')).enterText('   ');
      await E2eAuth.pumpFrames($, times: 2);
      expect($(const Key('comment-submit')).evaluate(), isEmpty);
    },
  );

  // ---------------------------------------------------------------------------
  // EDGE — texto longo no comentário; teclado / composer sobe
  // ---------------------------------------------------------------------------
  patrolTest(
    'EDGE: superfã comenta texto longo e vê o comentário',
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

      final artistUid = E2eEnv.artistUid;
      final postLabel = 'load-e2e $stamp';
      if (artistUid != null) {
        await E2eAuth.go($, Pages.artistProfileOf(artistUid));
        await E2eAuth.pumpFrames($, times: 5);
      } else {
        await $(const Key('nav-home')).tap();
        await E2eAuth.pumpFrames($, times: 5);
      }

      if ($(postLabel).evaluate().isNotEmpty) {
        await $(const Key('post-comments')).tap();
      } else if (E2eEnv.seedPostId != null) {
        await E2eAuth.go(
          $,
          Pages.comments.replaceAll(':postId', E2eEnv.seedPostId!),
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

      final long = 'e2e-long-${DateTime.now().millisecondsSinceEpoch}-'
          '${'x' * 220}';
      await $(const Key('comment-composer')).enterText(long);
      await $(const Key('comment-submit')).waitUntilVisible(
        timeout: const Duration(seconds: 10),
      );
      await $(const Key('comment-submit')).tap();
      await E2eAuth.pumpFrames($, times: 5);

      expect($(long), findsWidgets);
    },
  );
}
