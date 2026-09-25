import 'package:crowdfans/components/buttons/app_button.dart';
import 'package:crowdfans/components/profile/membership_activation_confirmed_badge.dart';
import 'package:crowdfans/components/profile/membership_activation_confirmed_card.dart';
import 'package:crowdfans/components/profile/membership_activation_confirmed_info_note.dart';
import 'package:crowdfans/constants/pages.dart';
import 'package:crowdfans/constants/theme.dart';
import 'package:crowdfans/mocks/cf_temp_mocks.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Confirmação de membership ativa — só após assinatura confirmada (CF-207).
///
/// Tela puramente apresentacional: reabrir a rota não cobra de novo.
class ProfileMembershipActivationConfirmedScreen extends StatelessWidget {
  const ProfileMembershipActivationConfirmedScreen({
    super.key,
    required this.artistName,
    required this.pricePerMonth,
    this.artistId,
    this.artistHandle,
    this.artistAvatarUrl,
    this.periodLabel = '1 mês',
  });

  final String artistName;
  final int pricePerMonth;
  final String? artistId;
  final String? artistHandle;
  final String? artistAvatarUrl;
  final String periodLabel;

  void handleClose(BuildContext context) {
    context.go(Pages.profileMemberships);
  }

  @override
  Widget build(BuildContext context) {
    final colors = CrowdFansTheme.of(context);
    final useMock = CfTempMocks.useMembershipFixtures &&
        kUseCfTempMocks &&
        (artistName.trim().isEmpty || pricePerMonth <= 0);
    final name = useMock
        ? cfTempMockMembershipSummary.artistName
        : (artistName.trim().isEmpty ? 'o artista' : artistName.trim());
    final handle =
        useMock ? cfTempMockMembershipSummary.artistHandle : artistHandle;
    final price = useMock
        ? cfTempMockMembershipSummary.pricePerMonth
        : (pricePerMonth > 0 ? pricePerMonth : 100);
    final period =
        useMock ? cfTempMockMembershipSummary.periodLabel : periodLabel;

    return Scaffold(
      backgroundColor: colors.background,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Semantics(
                liveRegion: true,
                label:
                    'Membership ativo. Oficialmente do bando. Você apoia $name.',
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
                    const Center(child: MembershipActivationConfirmedBadge()),
                    const SizedBox(height: 16),
                    Text(
                      'Oficialmente do bando!',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w900,
                        color: colors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Agora você apoia $name todo mês e entra no círculo mais próximo da fanbase.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 15,
                        height: 22 / 15,
                        color: colors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 28),
                    MembershipActivationConfirmedCard(
                      artistName: name,
                      artistHandle: handle,
                      artistAvatarUrl: artistAvatarUrl,
                      pricePerMonth: price,
                      periodLabel: period,
                    ),
                    const SizedBox(height: 16),
                    const MembershipActivationConfirmedInfoNote(),
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
