import 'dart:async';

import 'package:crowdfans/components/profile/artist_jam_coins_balance_card.dart';
import 'package:crowdfans/components/profile/artist_jam_coins_earnings_section.dart';
import 'package:crowdfans/components/profile/artist_jam_coins_math.dart';
import 'package:crowdfans/components/profile/profile_screen_header.dart';
import 'package:crowdfans/components/profile/profile_state.dart';
import 'package:crowdfans/components/profile/wallet_home_balance_card.dart';
import 'package:crowdfans/components/profile/wallet_membership_banner.dart';
import 'package:crowdfans/components/profile/wallet_promo_banner.dart';
import 'package:crowdfans/components/profile/wallet_scan_earn_row.dart';
import 'package:crowdfans/constants/pages.dart';
import 'package:crowdfans/constants/theme.dart';
import 'package:crowdfans/services/earnings_service.dart';
import 'package:crowdfans/services/wallet_service.dart';
import 'package:crowdfans/state/auth_session.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

DateTime nextSundayEnd() {
  final now = DateTime.now();
  final daysUntilSunday = now.weekday == DateTime.sunday ? 0 : 7 - now.weekday;
  return DateTime(
    now.year,
    now.month,
    now.day + daysUntilSunday,
    23,
    59,
    59,
    999,
  );
}

String formatCountdown(DateTime target) {
  final remaining = target.difference(DateTime.now());
  if (remaining.isNegative) {
    return '00:00:00';
  }
  final hours = remaining.inHours;
  final minutes = remaining.inMinutes.remainder(60);
  final seconds = remaining.inSeconds.remainder(60);
  return '${hours.toString().padLeft(2, '0')}:'
      '${minutes.toString().padLeft(2, '0')}:'
      '${seconds.toString().padLeft(2, '0')}';
}

/// Home de Jam Coins: superfã (CF-76) ou artista (CF-118).
class ProfileWalletScreen extends ConsumerStatefulWidget {
  const ProfileWalletScreen({super.key});

  @override
  ConsumerState<ProfileWalletScreen> createState() => _ProfileWalletScreenState();
}

class _ProfileWalletScreenState extends ConsumerState<ProfileWalletScreen> {
  WalletSnapshot? _wallet;
  EarningsSnapshot? _earnings;
  var _loading = true;
  String? _error;
  var _countdown = formatCountdown(nextSundayEnd());
  Timer? _countdownTimer;
  VoidCallback? _unsubscribeWs;

  @override
  void initState() {
    super.initState();
    handleLoad();
    unawaited(handleSubscribe());
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) {
        return;
      }
      setState(() => _countdown = formatCountdown(nextSundayEnd()));
    });
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    _unsubscribeWs?.call();
    super.dispose();
  }

  Future<void> handleSubscribe() async {
    try {
      final stop = await WalletService.subscribe((event) {
        if (event.type == 'wallet.credited') {
          unawaited(handleLoad(silent: true));
        }
      });
      if (!mounted) {
        stop();
        return;
      }
      _unsubscribeWs = stop;
    } catch (_) {}
  }

  void handleBack() {
    if (context.canPop()) {
      context.pop();
      return;
    }
    context.go(Pages.profileSettings);
  }

  Future<void> handleLoad({bool silent = false}) async {
    final isArtist =
        ref.read(authSessionProvider).profile?.isArtist ?? false;
    if (!silent) {
      setState(() {
        _loading = true;
        _error = null;
      });
    }
    try {
      final wallet = await WalletService.getWallet();
      EarningsSnapshot? earnings;
      if (isArtist) {
        try {
          earnings = await EarningsService.getEarnings();
        } catch (_) {
          earnings = null;
        }
      }
      if (!mounted) {
        return;
      }
      setState(() {
        _wallet = wallet;
        _earnings = earnings;
        _loading = false;
        _error = null;
      });
    } catch (_) {
      if (!mounted) {
        return;
      }
      setState(() {
        _loading = false;
        if (!silent) {
          _error = 'Não foi possível carregar a carteira.';
        }
      });
    }
  }

  void handleRecharge() {
    context.push(Pages.profileWalletRecharge);
  }

  void handleRedeem() {
    context.push(Pages.profileEarnings);
  }

  List<ArtistJamCoinsEarningRow> get _earningRows {
    final available = _earnings?.available ?? 0;
    if (available <= 0) {
      return const [
        ArtistJamCoinsEarningRow(title: 'Membership', value: '0 JC'),
        ArtistJamCoinsEarningRow(title: 'Lives', value: '0 JC'),
      ];
    }
    // API ainda não quebra origem; mostra o disponível em Membership
    // e deixa Lives em 0 até o backend expor o breakdown.
    return [
      ArtistJamCoinsEarningRow(
        title: 'Membership',
        value: '${ArtistJamCoinsMath.formatPtBr(available)} JC',
      ),
      const ArtistJamCoinsEarningRow(title: 'Lives', value: '0 JC'),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final colors = CrowdFansTheme.of(context);
    final wallet = _wallet;
    final isArtist =
        ref.watch(authSessionProvider).profile?.isArtist ?? false;
    final redeemable = _earnings?.available ?? 0;
    final redeemableReais = ArtistJamCoinsMath.formatReais(
      ArtistJamCoinsMath.convertJamCoinsToReais(redeemable),
    );

    return Scaffold(
      backgroundColor: colors.background,
      body: SafeArea(
        child: Column(
          children: [
            ProfileScreenHeader(title: 'Jam Coins', onBack: handleBack),
            Expanded(
              child: _loading && wallet == null
                  ? const ProfileState(loading: true)
                  : _error != null && wallet == null
                  ? ProfileState(
                      title: 'Carteira indisponível',
                      message: _error,
                      actionLabel: 'Tentar novamente',
                      onAction: handleLoad,
                    )
                  : ListView(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 36),
                      children: [
                        if (isArtist) ...[
                          ArtistJamCoinsBalanceCard(
                            label: 'Jam Coins para usar',
                            balance: wallet?.displayBalance ?? '0',
                            helperText:
                                'Saldo comprado com dinheiro real para usar em memberships, ativações e experiências dentro do app.',
                            actionLabel: 'Recarregar',
                            onAction: handleRecharge,
                          ),
                          const SizedBox(height: 12),
                          ArtistJamCoinsBalanceCard(
                            label: 'Jam Coins para resgatar',
                            balance: ArtistJamCoinsMath.formatPtBr(redeemable),
                            secondaryValue: redeemableReais,
                            helperText:
                                'Valor acumulado pelas suas receitas. A conversão em reais exibida aqui é estimada, e o valor final do saque considera a retenção de 30% no momento da solicitação.',
                            actionLabel: 'Solicitar resgate',
                            onAction: handleRedeem,
                          ),
                          const SizedBox(height: 16),
                          ArtistJamCoinsEarningsSection(rows: _earningRows),
                        ] else ...[
                          WalletHomeBalanceCard(
                            balance: wallet?.displayBalance ?? '0',
                            onRecharge: handleRecharge,
                          ),
                          const SizedBox(height: 16),
                          WalletPromoBanner(
                            countdown: _countdown,
                            onRecharge: handleRecharge,
                          ),
                          const SizedBox(height: 16),
                          WalletMembershipBanner(
                            onSubscribe: () =>
                                context.push(Pages.profileMemberships),
                          ),
                          const SizedBox(height: 16),
                          WalletScanEarnRow(
                            onPressed: () =>
                                context.push(Pages.profileReferral),
                          ),
                        ],
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
