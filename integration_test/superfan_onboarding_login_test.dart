import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:patrol/patrol.dart';

import 'helpers/app_harness.dart';

/// CF-124 — smoke Superfã deslogado: onboarding → login.
void main() {
  patrolTest(
    'smoke Superfã: onboarding abre login deslogado',
    ($) async {
      await bootstrapCrowdFansForPatrol($);

      expect($('CROWD FANS'), findsOneWidget);

      await $(const Key('onboarding-superfan')).tap();
      await $.pump(const Duration(milliseconds: 800));
      await $.pump(const Duration(milliseconds: 800));

      // Tela de login Superfã (campos + CTA Entrar).
      expect($(const Key('login-username')), findsOneWidget);
      expect($(const Key('login-password')), findsOneWidget);
      expect($(const Key('login-submit')), findsOneWidget);
      expect($('Entrar'), findsOneWidget);
    },
  );
}
