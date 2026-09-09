import 'package:flutter_test/flutter_test.dart';
import 'package:patrol/patrol.dart';

/// CF-128 — E2E artista posta + superfã comenta.
///
/// Requer fixtures autenticados (`E2E_ARTIST_*` / `E2E_FAN_*`) e post real na API
/// de produção. Sem isso o teste fica skip — não fingir verde.
void main() {
  patrolTest(
    // skip: precisa contas E2E_ARTIST_* / E2E_FAN_* e fixtures estáveis
    'E2E: artista posta e superfã comenta',
    skip: true,
    ($) async {
      // TODO(CF-128):
      // 1. Login artista → criar post Home
      // 2. Logout
      // 3. Login superfã → abrir post → comentar
      // 4. Assert no comentário visível
      fail('não implementado sem fixtures E2E');
    },
  );
}
