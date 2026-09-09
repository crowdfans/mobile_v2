import 'package:crowdfans/components/buttons/app_button.dart';
import 'package:crowdfans/components/input/app_text_field.dart';
import 'package:crowdfans/components/profile/profile_screen_header.dart';
import 'package:crowdfans/components/profile/profile_state.dart';
import 'package:crowdfans/constants/pages.dart';
import 'package:crowdfans/constants/theme.dart';
import 'package:crowdfans/services/earnings_service.dart';
import 'package:crowdfans/utils/app_alert.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Ganhos do artista e pedido de saque PIX.
class ProfileEarningsScreen extends StatefulWidget {
  const ProfileEarningsScreen({super.key});

  @override
  State<ProfileEarningsScreen> createState() => _ProfileEarningsScreenState();
}

class _ProfileEarningsScreenState extends State<ProfileEarningsScreen> {
  EarningsSnapshot? _snapshot;
  var _loading = true;
  var _busy = false;
  String? _error;
  var _amount = '';
  var _pixKey = '';
  var _formNonce = 0;

  @override
  void initState() {
    super.initState();
    handleLoad();
  }

  void handleBack() {
    if (context.canPop()) {
      context.pop();
      return;
    }
    context.go(Pages.profileSettings);
  }

  Future<void> handleLoad() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final snapshot = await EarningsService.getEarnings();
      if (!mounted) {
        return;
      }
      setState(() {
        _snapshot = snapshot;
        _loading = false;
      });
    } catch (_) {
      if (!mounted) {
        return;
      }
      setState(() {
        _loading = false;
        _error = 'Não foi possível carregar os ganhos.';
      });
    }
  }

  Future<void> handleSubmit() async {
    final coins = num.tryParse(_amount.trim()) ?? 0;
    if (coins <= 0 || _pixKey.trim().isEmpty) {
      await AppAlert.show(
        context,
        title: 'Saque',
        message: 'Informe um valor positivo e a chave PIX.',
      );
      return;
    }
    setState(() => _busy = true);
    try {
      await EarningsService.requestWithdrawal(coins, _pixKey.trim());
      if (!mounted) {
        return;
      }
      setState(() {
        _amount = '';
        _formNonce++;
      });
      await handleLoad();
      if (mounted) {
        await AppAlert.show(
          context,
          title: 'Saque',
          message: 'Pedido enviado. O PIX fica pendente até o PSP (Pagar.me).',
        );
      }
    } catch (error) {
      if (mounted) {
        await AppAlert.show(context, title: 'Saque', message: error.toString());
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
    final snapshot = _snapshot;
    return Scaffold(
      backgroundColor: colors.background,
      body: SafeArea(
        child: Column(
          children: [
            ProfileScreenHeader(title: 'Solicitar resgate', onBack: handleBack),
            Expanded(
              child: _loading
                  ? const ProfileState(
                      title: 'Carregando ganhos',
                      message: 'Saldo e pedidos de saque.',
                    )
                  : _error != null
                  ? ProfileState(
                      title: 'Não foi possível carregar',
                      message: _error,
                    )
                  : ListView(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 36),
                      children: [
                        DecoratedBox(
                          decoration: BoxDecoration(
                            color: colors.surface,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: colors.border),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(14),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Disponível',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: colors.textSecondary,
                                  ),
                                ),
                                Text(
                                  '${snapshot?.available ?? 0} Jam Coins',
                                  style: TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.w900,
                                    color: colors.textPrimary,
                                  ),
                                ),
                                Text(
                                  '${snapshot?.pending ?? 0} em análise. Sua fatia é ${snapshot?.sharePercent ?? 70}% de cada membership.',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: colors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 18),
                        DecoratedBox(
                          decoration: BoxDecoration(
                            color: colors.surface,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: colors.border),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(14),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Pedir saque PIX',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: colors.textPrimary,
                                  ),
                                ),
                                const SizedBox(height: 10),
                                AppTextField(
                                  key: ValueKey('amount-$_formNonce'),
                                  hint: 'Quantidade de Jam Coins',
                                  keyboardType: TextInputType.number,
                                  onChanged: (value) => _amount = value,
                                ),
                                const SizedBox(height: 10),
                                AppTextField(
                                  key: ValueKey('pix-$_formNonce'),
                                  hint: 'Chave PIX',
                                  onChanged: (value) => _pixKey = value,
                                ),
                                const SizedBox(height: 12),
                                AppButton(
                                  label: 'Pedir saque',
                                  loading: _busy,
                                  onPressed: handleSubmit,
                                ),
                              ],
                            ),
                          ),
                        ),
                        for (final item
                            in snapshot?.withdrawals ??
                                const <WithdrawalItem>[]) ...[
                          const SizedBox(height: 12),
                          DecoratedBox(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: colors.border),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(14),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '${item.amount} JC · ${item.status}',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      color: colors.textPrimary,
                                    ),
                                  ),
                                  Text(
                                    item.pixKey,
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: colors.textSecondary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
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
