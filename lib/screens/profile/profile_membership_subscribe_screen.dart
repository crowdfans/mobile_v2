import 'package:crowdfans/api/api_error.dart';
import 'package:crowdfans/components/buttons/app_button.dart';
import 'package:crowdfans/components/profile/membership_subscribe_artist_summary.dart';
import 'package:crowdfans/components/profile/membership_subscribe_balance_pill.dart';
import 'package:crowdfans/components/profile/membership_subscribe_expectations.dart';
import 'package:crowdfans/components/profile/membership_subscribe_terms_checkbox.dart';
import 'package:crowdfans/components/profile/profile_screen_header.dart';
import 'package:crowdfans/constants/pages.dart';
import 'package:crowdfans/constants/theme.dart';
import 'package:crowdfans/mocks/cf_temp_mocks.dart';
import 'package:crowdfans/services/follow_service.dart';
import 'package:crowdfans/services/subscription_service.dart';
import 'package:crowdfans/services/wallet_service.dart';
import 'package:crowdfans/utils/app_alert.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Revisão e aceite antes de cobrir a membership (CF-206).
class ProfileMembershipSubscribeScreen extends StatefulWidget {
  const ProfileMembershipSubscribeScreen({
    super.key,
    required this.artistId,
    required this.artistName,
    this.artistHandle,
    this.artistAvatarUrl,
    this.pricePerMonth = 100,
  });

  final String artistId;
  final String artistName;
  final String? artistHandle;
  final String? artistAvatarUrl;
  final int pricePerMonth;

  @override
  State<ProfileMembershipSubscribeScreen> createState() =>
      _ProfileMembershipSubscribeScreenState();
}

class _ProfileMembershipSubscribeScreenState
    extends State<ProfileMembershipSubscribeScreen> {
  var _accepted = false;
  var _busy = false;
  var _balance = '—';

  @override
  void initState() {
    super.initState();
    handleLoadBalance();
  }

  Future<void> handleLoadBalance() async {
    try {
      final wallet = await WalletService.getWallet();
      if (!mounted) {
        return;
      }
      setState(() => _balance = wallet.displayBalance);
    } catch (_) {
      if (!mounted) {
        return;
      }
      // TEMP: saldo do print CF-206 quando a carteira falha.
      if (CfTempMocks.useMembershipFixtures && kUseCfTempMocks) {
        setState(
          () => _balance = cfTempMockMembershipSummary.jamCoinsBalanceLabel,
        );
      }
    }
  }

  void handleBack() {
    if (context.canPop()) {
      context.pop();
      return;
    }
    context.go(Pages.artistProfileOf(widget.artistId, name: widget.artistName));
  }

  void handleOpenTerms() {
    context.push('${Pages.profileInformation}?tab=terms');
  }

  Future<void> handleSubscribe() async {
    if (!_accepted || _busy || widget.artistId.trim().isEmpty) {
      return;
    }
    setState(() => _busy = true);
    try {
      final subscription = await SubscriptionService.createSubscription(
        widget.artistId,
      );
      try {
        await FollowService.followArtist(widget.artistId);
      } catch (_) {}
      if (!mounted) {
        return;
      }
      if (subscription.isActive) {
        context.go(
          Pages.profileMembershipActivationConfirmedOf(
            artistName: subscription.artistName.trim().isNotEmpty
                ? subscription.artistName.trim()
                : widget.artistName,
            artistId: widget.artistId,
            artistHandle: widget.artistHandle,
            artistAvatarUrl: widget.artistAvatarUrl,
            pricePerMonth: widget.pricePerMonth > 0
                ? widget.pricePerMonth
                : 100,
          ),
        );
        return;
      }
      await AppAlert.show(
        context,
        title: 'Assinatura',
        message: 'A assinatura ainda não está ativa. Tente novamente em instantes.',
      );
    } on ApiError catch (error) {
      if (mounted) {
        await AppAlert.show(
          context,
          title: 'Assinatura',
          message: error.status == 402
              ? 'Saldo de Jam Coins insuficiente para a membership (${widget.pricePerMonth}). Recarregue em Jam Coins.'
              : error.message,
        );
      }
    } catch (error) {
      if (mounted) {
        await AppAlert.show(
          context,
          title: 'Assinatura',
          message: error.toString(),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _busy = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = CrowdFansTheme.of(context);
    final useMock = CfTempMocks.useMembershipFixtures &&
        kUseCfTempMocks &&
        (widget.artistName.trim().isEmpty || widget.pricePerMonth <= 0);
    final name = useMock
        ? cfTempMockMembershipSummary.artistName
        : (widget.artistName.trim().isEmpty
            ? 'Artista'
            : widget.artistName.trim());
    final handle = useMock
        ? cfTempMockMembershipSummary.artistHandle
        : widget.artistHandle;
    final price = useMock
        ? cfTempMockMembershipSummary.pricePerMonth
        : (widget.pricePerMonth > 0 ? widget.pricePerMonth : 100);
    final balance = (_balance == '—' || _balance.trim().isEmpty) &&
            CfTempMocks.useMembershipFixtures &&
            kUseCfTempMocks
        ? cfTempMockMembershipSummary.jamCoinsBalanceLabel
        : _balance;
    final canSubscribe = _accepted && !_busy;

    return Scaffold(
      backgroundColor: colors.background,
      body: SafeArea(
        child: Column(
          children: [
            ProfileScreenHeader(
              title: 'Assinar',
              onBack: handleBack,
              action: MembershipSubscribeBalancePill(
                balance: balance,
                onPressed: () => context.push(Pages.profileWallet),
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                children: [
                  MembershipSubscribeArtistSummary(
                    artistName: name,
                    artistHandle: handle,
                    artistAvatarUrl: widget.artistAvatarUrl,
                    pricePerMonth: price,
                  ),
                  const SizedBox(height: 24),
                  const MembershipSubscribeExpectations(),
                  const SizedBox(height: 24),
                  AppButton(
                    label: 'Termos de Uso e Condições de Serviço',
                    variant: AppButtonVariant.outline,
                    onPressed: handleOpenTerms,
                  ),
                  const SizedBox(height: 16),
                  MembershipSubscribeTermsCheckbox(
                    accepted: _accepted,
                    onChanged: (value) {
                      setState(() => _accepted = value);
                    },
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: AppButton(
                label: _busy ? 'Assinando...' : 'Assinar',
                variant: AppButtonVariant.dark,
                disabled: !canSubscribe,
                loading: _busy,
                onPressed: handleSubscribe,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
