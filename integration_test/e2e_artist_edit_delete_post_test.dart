import 'package:flutter_test/flutter_test.dart';
import 'package:patrol/patrol.dart';

/// CF-130 — E2E Artista: editar e apagar o próprio post.
///
/// Depende de sessão artista (`E2E_ARTIST_*`) e post próprio criado no setup.
void main() {
  patrolTest(
    // skip: precisa E2E_ARTIST_* e post próprio fixture
    'E2E Artista: editar e apagar o próprio post',
    skip: true,
    ($) async {
      // TODO(CF-130):
      // 1. Login artista
      // 2. Criar post (ou usar fixture)
      // 3. Editar texto/mídia
      // 4. Apagar post e assert sumiu do feed
      fail('não implementado sem fixtures E2E');
    },
  );
}
