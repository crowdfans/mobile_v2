import 'dart:async';

import 'package:crowdfans/components/profile/profile_screen_header.dart';
import 'package:crowdfans/components/profile/profile_state.dart';
import 'package:crowdfans/components/profile/wallet_home_balance_card.dart';
import 'package:crowdfans/components/profile/wallet_membership_banner.dart';
import 'package:crowdfans/components/profile/wallet_promo_banner.dart';
import 'package:crowdfans/components/profile/wallet_scan_earn_row.dart';
import 'package:crowdfans/constants/pages.dart';
import 'package:crowdfans/constants/theme.dart';
import 'package:crowdfans/services/wallet_service.dart';
import 'package:flutter/material.dart';
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

/// Home de Jam Coins (CF-76): saldo, promo, membership e convite.
class ProfileWalletScreen extends StatefulWidget {
  const ProfileWalletScreen({super.key});

  @override
  State<ProfileWalletScreen> createState() => _ProfileWalletScreenState();
}

class _ProfileWalletScreenState extends State<ProfileWalletScreen> {
  WalletSnapshot? _wallet;
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
    if (!silent) {
      setState(() {
        _loading = true;
        _error = null;
      });
    }
    try {
      final wallet = await WalletService.getWallet();
      if (!mounted) {
        return;
      }
      setState(() {
        _wallet = wallet;
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

  @override
  Widget build(BuildContext context) {
    final colors = CrowdFansTheme.of(context);
    final wallet = _wallet;
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
                          onPressed: () => context.push(Pages.profileReferral),
                        ),
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
