import 'package:crowdfans/components/buttons/app_button.dart';
import 'package:crowdfans/components/profile/wallet_payment_confirmed_badge.dart';
import 'package:crowdfans/components/profile/wallet_payment_confirmed_info_note.dart';
import 'package:crowdfans/components/profile/wallet_payment_confirmed_purchase_card.dart';
import 'package:crowdfans/constants/pages.dart';
import 'package:crowdfans/constants/theme.dart';
import 'package:crowdfans/mocks/cf_temp_mocks.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Confirmação real da recarga — só após crédito (CF-204).
class ProfileWalletPaymentConfirmedScreen extends StatelessWidget {
  const ProfileWalletPaymentConfirmedScreen({
    super.key,
    required this.coinsTotal,
    this.baseCoins,
    this.bonusCoins,
    this.checkoutId,
    this.packId,
  });

  final int coinsTotal;
  final int? baseCoins;
  final int? bonusCoins;
  final String? checkoutId;
  final String? packId;

  void handleClose(BuildContext context) {
    context.go(Pages.profileWallet);
  }

  @override
  Widget build(BuildContext context) {
    final colors = CrowdFansTheme.of(context);
    // TEMP: demo do print (240 = 200 + 40) se a rota chegar sem valores.
    final useMock =
        coinsTotal <= 0 && CfTempMocks.useMembershipFixtures && kUseCfTempMocks;
    final total =
        useMock ? cfTempMockRechargeConfirmed.coinsTotal : coinsTotal;
    final base =
        useMock ? cfTempMockRechargeConfirmed.baseCoins : baseCoins;
    final bonus =
        useMock ? cfTempMockRechargeConfirmed.bonusCoins : bonusCoins;

    return Scaffold(
      backgroundColor: colors.background,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Semantics(
                liveRegion: true,
                label:
                    'Pagamento confirmado. Carteira cheia. $total Jam Coins creditadas.',
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(24, 32, 24, 24),
                  children: [
                    Center(
                      child: Image.asset(
                        'assets/images/Confetti.png',
                        width: 120,
                        height: 120,
                        excludeFromSemantics: true,
                        errorBuilder: (_, _, _) => Icon(
                          Icons.celebration,
                          size: 96,
                          color: colors.primary,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Center(child: WalletPaymentConfirmedBadge()),
                    const SizedBox(height: 16),
                    Text(
                      'Carteira cheia!',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w900,
                        color: colors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Suas Jam Coins chegaram e já estão liberadas para usar no app.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 15,
                        height: 22 / 15,
                        color: colors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 28),
                    WalletPaymentConfirmedPurchaseCard(
                      coinsTotal: total,
                      baseCoins: base,
                      bonusCoins: bonus,
                      checkoutId: checkoutId,
                    ),
                    const SizedBox(height: 16),
                    const WalletPaymentConfirmedInfoNote(),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: AppButton(
                label: 'Fechar',
                variant: AppButtonVariant.dark,
                onPressed: () => handleClose(context),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
