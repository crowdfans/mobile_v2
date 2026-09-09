import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:patrol/patrol.dart';

import 'helpers/app_harness.dart';

/// CF-123 — smoke local: app sobe no onboarding Superfã.
void main() {
  patrolTest('smoke: abre o onboarding Superfã', ($) async {
    await bootstrapCrowdFansForPatrol($);

    expect($('CROWD FANS'), findsOneWidget);
    expect($(const Key('onboarding-superfan')), findsOneWidget);
    expect($(const Key('onboarding-artist')), findsOneWidget);
  });
}
