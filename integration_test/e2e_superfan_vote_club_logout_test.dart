import 'package:flutter_test/flutter_test.dart';
import 'package:patrol/patrol.dart';

/// CF-129 — E2E Superfã: voto, fã clube e logout.
///
/// Depende de sessão superfã (`E2E_FAN_*`) e dados de clube/voto na API.
void main() {
  patrolTest(
    // skip: precisa E2E_FAN_* e fixtures de voto/fã clube
    'E2E Superfã: voto, fã clube e logout',
    skip: true,
    ($) async {
      // TODO(CF-129):
      // 1. Login superfã
      // 2. Votar em ranking/post conforme fluxo prod
      // 3. Abrir fã clube e validar feed
      // 4. Logout → volta ao onboarding/login
      fail('não implementado sem fixtures E2E');
    },
  );
}
