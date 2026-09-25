import 'dart:async';

import 'package:crowdfans/components/profile/profile_screen_header.dart';
import 'package:crowdfans/components/profile/profile_state.dart';
import 'package:crowdfans/components/profile/wallet_payment_method_tabs.dart';
import 'package:crowdfans/components/profile/wallet_payment_summary_card.dart';
import 'package:crowdfans/components/profile/wallet_pix_code_panel.dart';
import 'package:crowdfans/constants/pages.dart';
import 'package:crowdfans/constants/theme.dart';
import 'package:crowdfans/services/wallet_service.dart';
import 'package:crowdfans/utils/app_alert.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

/// Pagamento do pacote (sandbox PIX até RevenueCat).
class ProfileWalletPaymentScreen extends StatefulWidget {
  const ProfileWalletPaymentScreen({
    super.key,
    required this.packId,
    this.productId,
    this.label,
    this.coins,
    this.priceCents,
  });

  final String packId;
  final String? productId;
  final String? label;
  final String? coins;
  final int? priceCents;

  @override
  State<ProfileWalletPaymentScreen> createState() =>
      _ProfileWalletPaymentScreenState();
}

class _ProfileWalletPaymentScreenState
    extends State<ProfileWalletPaymentScreen> {
  var _method = WalletPaymentMethod.pix;
  var _busy = false;
  WalletCheckoutResult? _receipt;
  VoidCallback? _unsubscribeWs;

  @override
  void initState() {
    super.initState();
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
        if (event.type == 'wallet.credited' && mounted) {
          handleNavigateConfirmedFromEvent(event);
        }
      });
      if (!mounted) {
        stop();
        return;
      }
      _unsubscribeWs = stop;
    } catch (_) {}
  }

  void handleNavigateConfirmed({
    required int coins,
    String? checkoutId,
    String? packId,
  }) {
    if (!mounted || coins <= 0) {
      return;
    }
    context.go(
      Pages.profileWalletPaymentConfirmedOf(
        coins: coins,
        checkoutId: checkoutId,
        packId: packId ?? widget.packId,
      ),
    );
  }

  void handleNavigateConfirmedFromEvent(WalletRealtimeEvent event) {
    final data = (event.data as Map?)?.cast<String, dynamic>() ?? {};
    final packId = data['packId']?.toString() ?? '';
    if (packId.isNotEmpty && packId != widget.packId) {
      return;
    }
    final coins =
        (data['coins'] as num?)?.toInt() ??
        int.tryParse(widget.coins ?? '') ??
        _receipt?.coins ??
        0;
    handleNavigateConfirmed(
      coins: coins,
      checkoutId: _receipt?.checkoutId,
      packId: packId.isNotEmpty ? packId : widget.packId,
    );
  }

  void handleBack() {
    if (context.canPop()) {
      context.pop();
      return;
    }
    context.go(Pages.profileWalletRecharge);
  }

  String priceLabel() {
    final cents = widget.priceCents ?? 0;
    return 'R\$ ${(cents / 100).toStringAsFixed(2).replaceAll('.', ',')}';
  }

  Future<void> handleCheckout() async {
    if (widget.packId.isEmpty) {
      return;
    }
    if (_method != WalletPaymentMethod.pix) {
      await AppAlert.show(
        context,
        title: 'Pagamento',
        message: 'Débito e crédito entram com a compra na loja (RevenueCat).',
      );
      return;
    }
    setState(() => _busy = true);
    try {
      final result = await WalletService.checkout(widget.packId);
      if (!mounted) {
        return;
      }
      if (result.status == 'paid' && result.coins > 0) {
        handleNavigateConfirmed(
          coins: result.coins,
          checkoutId: result.checkoutId,
          packId: result.packId.isNotEmpty ? result.packId : widget.packId,
        );
        return;
      }
      setState(() => _receipt = result);
    } catch (error) {
      if (mounted) {
        await AppAlert.show(
          context,
          title: 'Pagamento',
          message: error.toString(),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _busy = false);
      }
    }
  }

  /// Omite mensagens internas (sandbox / RevenueCat / CF-*).
  String? get _receiptUserMessage {
    final raw = _receipt?.message?.trim();
    if (raw == null || raw.isEmpty) {
      return null;
    }
    final lower = raw.toLowerCase();
    if (lower.contains('sandbox') ||
        lower.contains('revenuecat') ||
        RegExp(r'\bcf-\d+', caseSensitive: false).hasMatch(raw)) {
      return null;
    }
    return raw;
  }

  /// Validade do código PIX (referência CF-171).
  String _pixValidityLabel() {
    final brasilia = DateTime.now().toUtc().subtract(const Duration(hours: 3));
    final until = brasilia.add(const Duration(minutes: 30));
    final hour = until.hour.toString().padLeft(2, '0');
    final minute = until.minute.toString().padLeft(2, '0');
    return 'Este código é válido até hoje, $hour:$minute - Horário de Brasília.';
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
    if (widget.packId.isEmpty) {
      return Scaffold(
        backgroundColor: colors.background,
        body: SafeArea(
          child: Column(
            children: [
              ProfileScreenHeader(title: 'Pagamento', onBack: handleBack),
              Expanded(
                child: ProfileState(
                  title: 'Pacote não encontrado',
                  message: 'Volte e escolha um pacote para recarregar.',
                  actionLabel: 'Recarregar',
                  onAction: () => context.go(Pages.profileWalletRecharge),
                ),
              ),
            ],
          ),
        ),
      );
    }

    final coins = widget.coins?.trim().isNotEmpty == true
        ? widget.coins!.trim()
        : '—';
    final detail = widget.label?.trim().isNotEmpty == true
        ? widget.label!.trim()
        : '$coins Jam Coins';
    final pix = _receipt?.pixCopyPaste?.trim() ?? '';
    final hasPix = pix.isNotEmpty;

    return Scaffold(
      backgroundColor: colors.background,
      body: SafeArea(
        child: Column(
          children: [
            ProfileScreenHeader(title: 'Pagamento', onBack: handleBack),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                children: [
                  WalletPaymentSummaryCard(
                    coinsLabel: coins,
                    detail: detail,
                    priceLabel: priceLabel(),
                  ),
                  const SizedBox(height: 20),
                  WalletPaymentMethodTabs(
                    selected: _method,
                    onChanged: (method) {
                      setState(() => _method = method);
                    },
                  ),
                  const SizedBox(height: 16),
                  if (!hasPix && _method == WalletPaymentMethod.pix)
                    DecoratedBox(
                      decoration: BoxDecoration(
                        color: colors.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(14),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Pagamento por Pix',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w800,
                                color: colors.primary,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              'Ao tocar em Próximo, o código Pix copia e cola será gerado para esse pacote.',
                              style: TextStyle(
                                fontSize: 13,
                                height: 18 / 13,
                                color: colors.textPrimary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  if (_method != WalletPaymentMethod.pix)
                    DecoratedBox(
                      decoration: BoxDecoration(
                        color: colors.surfaceAlt,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(14),
                        child:                         Text(
                          'Cartão na loja (App Store / Google Play) chega em breve. Por enquanto use PIX.',
                          style: TextStyle(
                            fontSize: 13,
                            height: 18 / 13,
                            color: colors.textSecondary,
                          ),
                        ),
                      ),
                    ),
                  if (hasPix) ...[
                    const SizedBox(height: 16),
                    WalletPixCodePanel(pixCode: pix, onCopy: handleCopyPix),
                    const SizedBox(height: 12),
                    Text(
                      _pixValidityLabel(),
                      style: TextStyle(
                        fontSize: 12,
                        color: colors.textSecondary,
                      ),
                    ),
                    if (_receiptUserMessage != null) ...[
                      const SizedBox(height: 8),
                      Text(
                        _receiptUserMessage!,
                        style: TextStyle(
                          fontSize: 12,
                          color: colors.textSecondary,
                        ),
                      ),
                    ],
                  ],
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              // Referência CF-171: botão escuro com cantos suaves (não pílula roxa).
              child: SizedBox(
                width: double.infinity,
                height: 56,
                child: FilledButton(
                  onPressed: _busy
                      ? null
                      : (hasPix ? handleCopyPix : handleCheckout),
                  style: FilledButton.styleFrom(
                    backgroundColor: AppPalette.platinum900,
                    foregroundColor: AppPalette.platinum50,
                    disabledBackgroundColor:
                        AppPalette.platinum900.withValues(alpha: 0.4),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    hasPix
                        ? 'Copiar Código PIX'
                        : (_busy ? 'Gerando...' : 'Próximo'),
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
