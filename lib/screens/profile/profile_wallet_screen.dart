import 'dart:async';

import 'package:crowdfans/components/profile/membership_balance_banner.dart';
import 'package:crowdfans/components/profile/profile_screen_header.dart';
import 'package:crowdfans/components/profile/profile_state.dart';
import 'package:crowdfans/components/profile/wallet_pack_card.dart';
import 'package:crowdfans/components/profile/wallet_pix_receipt.dart';
import 'package:crowdfans/constants/pages.dart';
import 'package:crowdfans/constants/theme.dart';
import 'package:crowdfans/services/wallet_service.dart';
import 'package:crowdfans/utils/app_alert.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

/// Carteira Jam Coins: saldo, pacotes e checkout sandbox.
class ProfileWalletScreen extends StatefulWidget {
  const ProfileWalletScreen({super.key});

  @override
  State<ProfileWalletScreen> createState() => _ProfileWalletScreenState();
}

class _ProfileWalletScreenState extends State<ProfileWalletScreen> {
  WalletSnapshot? _wallet;
  WalletCheckoutResult? _receipt;
  var _loading = true;
  String? _error;
  String? _busyId;
  VoidCallback? _unsubscribeWs;

  @override
  void initState() {
    super.initState();
    handleLoad();
    unawaited(handleSubscribe());
  }

  @override
  void dispose() {
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
    } catch (_) {
      // WS é best-effort; saldo ainda atualiza no pull/checkout.
    }
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

  Future<void> handleBuy(JamCoinPack pack) async {
    setState(() => _busyId = pack.id);
    try {
      final result = await WalletService.checkout(pack.id);
      await handleLoad();
      if (mounted) {
        setState(() => _receipt = result);
      }
    } catch (error) {
      if (mounted) {
        await AppAlert.show(
          context,
          title: 'Jam Coins',
          message: error.toString(),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _busyId = null);
      }
    }
  }

  Future<void> handleCopyPix() async {
    final pix = _receipt?.pixCopyPaste?.trim() ?? '';
    if (pix.isEmpty) {
      return;
    }
    await Clipboard.setData(ClipboardData(text: pix));
    if (mounted) {
      await AppAlert.show(
        context,
        title: 'PIX',
        message: 'Código copia e cola copiado.',
      );
    }
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
                        MembershipBalanceBanner(
                          balance: wallet?.displayBalance ?? '0',
                        ),
                        if (_receipt != null) ...[
                          const SizedBox(height: 22),
                          WalletPixReceipt(
                            receipt: _receipt!,
                            onCopyPix: handleCopyPix,
                          ),
                        ],
                        const SizedBox(height: 22),
                        Text(
                          'Pacotes',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: colors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 10),
                        for (final pack
                            in wallet?.packs ?? const <JamCoinPack>[]) ...[
                          WalletPackCard(
                            pack: pack,
                            busy: _busyId == pack.id,
                            onBuy: () => handleBuy(pack),
                          ),
                          const SizedBox(height: 10),
                        ],
                        DecoratedBox(
                          decoration: BoxDecoration(
                            color: colors.surfaceAlt,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Text(
                              'Sandbox credita na hora e devolve payload PIX para copiar. Compra na loja (RevenueCat) entra depois.',
                              style: TextStyle(
                                fontSize: 12,
                                height: 18 / 12,
                                color: colors.textSecondary,
                              ),
                            ),
                          ),
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
