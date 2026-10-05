import 'package:crowdfans/constants/pages.dart';
import 'package:flutter_test/flutter_test.dart';

/// Regressão de rota: Settings → Meus Memberships abre a tela dedicada.
void main() {
  test('CF-167: Pages.profileMemberships é a rota dedicada', () {
    expect(Pages.profileMemberships, '/me/settings/memberships');
    expect(Pages.profilePro, '/me/settings/pro');
    expect(Pages.profileWallet, '/me/settings/wallet');
  });
}
