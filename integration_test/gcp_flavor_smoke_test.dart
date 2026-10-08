import 'package:crowdfans/services/api_config.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:patrol/patrol.dart';

import 'helpers/app_harness.dart';

/// Smoke stub `APP_FLAVOR=gcp` contra Cloud Run placeholder (não HTTP live).
///
/// Rodar:
/// ```bash
/// patrol test --flavor gcp --dart-define-from-file=config/gcp.json \
///   -t integration_test/gcp_flavor_smoke_test.dart
/// # ou: npm run test:patrol:gcp
/// ```
///
/// GRE completo de wiring: `test/services/gcp_flavor_gre_test.dart`.
/// Suite live pós-deploy: CF-362.
void main() {
  // GREEN — app sobe com flavor gcp e API aponta placeholder .run.app
  patrolTest('gcp green: onboarding + API Cloud Run stub', ($) async {
    await bootstrapCrowdFansForPatrol($);

    final debug = apiConfigDebug();
    expect(debug.flavor, anyOf('gcp', 'local'));
    // Com config/gcp.json o mode é gcp (local só se API_MODE=local).
    expect(debug.mode, 'gcp');
    expect(debug.baseUrl, contains('.run.app'));
    expect(debug.baseUrl.contains('ondigitalocean'), isFalse);
    expect(debug.baseUrl.contains('crowdfans-app-dev'), isFalse);
    expect(debug.baseUrl.contains('crowdfans-app-prod'), isFalse);

    expect($('CROWD FANS'), findsOneWidget);
    expect($(const Key('onboarding-superfan')), findsOneWidget);
    expect($(const Key('onboarding-artist')), findsOneWidget);
  });

  // RED — login com credencial lixo não autentica (Firebase stub / rede)
  patrolTest('gcp red: login inválido permanece na tela de login', ($) async {
    await bootstrapCrowdFansForPatrol($);

    await $(const Key('onboarding-superfan')).tap();
    await $.pump(const Duration(milliseconds: 800));
    await $.pump(const Duration(milliseconds: 800));

    expect($(const Key('login-username')), findsOneWidget);
    await $(const Key('login-username')).enterText('invalid-gcp-stub@example.com');
    await $(const Key('login-password')).enterText('wrong-password-gcp-stub');
    await $(const Key('login-submit')).tap();
    await $.pump(const Duration(seconds: 2));
    await $.pump(const Duration(seconds: 2));

    // Continua no login (Firebase stub / credencial inválida).
    expect($(const Key('login-username')), findsOneWidget);
    expect($(const Key('login-submit')), findsOneWidget);
    expect(apiConfigDebug().mode, 'gcp');
  });

  // EDGE — teclado/campos + ainda no backend gcp
  patrolTest('gcp edge: login campos + mode gcp após onboarding', ($) async {
    await bootstrapCrowdFansForPatrol($);

    await $(const Key('onboarding-superfan')).tap();
    await $.pump(const Duration(milliseconds: 800));
    await $.pump(const Duration(milliseconds: 800));

    expect($(const Key('login-username')), findsOneWidget);
    expect($(const Key('login-password')), findsOneWidget);
    expect($(const Key('login-submit')), findsOneWidget);
    expect($('Entrar'), findsOneWidget);

    // Texto longo no username (borda UI) não muda o backend.
    final long = 'a' * 120 + '@crowdfans.test';
    await $(const Key('login-username')).enterText(long);
    await $.pump(const Duration(milliseconds: 400));

    final debug = apiConfigDebug();
    expect(debug.mode, 'gcp');
    expect(debug.baseUrl, contains('.run.app'));
  });
}
