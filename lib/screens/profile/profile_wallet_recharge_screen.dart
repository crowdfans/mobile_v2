import 'package:crowdfans/components/buttons/app_button.dart';
import 'package:crowdfans/components/profile/profile_screen_header.dart';
import 'package:crowdfans/components/profile/profile_state.dart';
import 'package:crowdfans/components/profile/wallet_recharge_pack_tile.dart';
import 'package:crowdfans/constants/pages.dart';
import 'package:crowdfans/constants/theme.dart';
import 'package:crowdfans/services/wallet_service.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Lista de pacotes para recarga (CF-76).
class ProfileWalletRechargeScreen extends StatefulWidget {
  const ProfileWalletRechargeScreen({super.key});

  @override
  State<ProfileWalletRechargeScreen> createState() =>
      _ProfileWalletRechargeScreenState();
}

class _ProfileWalletRechargeScreenState
    extends State<ProfileWalletRechargeScreen> {
  var _packs = <JamCoinPack>[];
  String? _selectedId;
  var _loading = true;
  String? _error;

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
    context.go(Pages.profileWallet);
  }

  Future<void> handleLoad() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final packs = await WalletService.listPacks();
      if (!mounted) {
        return;
      }
      setState(() {
        _packs = packs;
        _selectedId = packs.isEmpty ? null : packs.first.id;
        _loading = false;
      });
    } catch (_) {
      if (!mounted) {
        return;
      }
      setState(() {
        _loading = false;
        _error = 'Não foi possível carregar os pacotes.';
      });
    }
  }

  void handleNext() {
    JamCoinPack? pack;
    for (final item in _packs) {
      if (item.id == _selectedId) {
        pack = item;
        break;
      }
    }
    if (pack == null) {
      return;
    }
    context.push(
      Pages.profileWalletPaymentOf(
        packId: pack.id,
        productId: pack.resolvedProductId,
        label: pack.label,
        coins: pack.coins,
        priceCents: pack.priceCents,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = CrowdFansTheme.of(context);
    return Scaffold(
      backgroundColor: colors.background,
      body: SafeArea(
        child: Column(
          children: [
            ProfileScreenHeader(
              title: 'Recarregar Jam Coins',
              onBack: handleBack,
            ),
            Expanded(
              child: _loading
                  ? const ProfileState(loading: true)
                  : _error != null
                  ? ProfileState(
                      title: 'Pacotes indisponíveis',
                      message: _error,
                      actionLabel: 'Tentar novamente',
                      onAction: handleLoad,
                    )
                  : ListView(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                      children: [
                        Text(
                          'Escolha a quantidade',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                            color: colors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Selecione o pacote e siga para a etapa de pagamento.',
                          style: TextStyle(
                            fontSize: 14,
                            color: colors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 16),
                        for (var index = 0; index < _packs.length; index++) ...[
                          WalletRechargePackTile(
                            pack: _packs[index],
                            selected: _packs[index].id == _selectedId,
                            featured: index == 1,
                            onPressed: () {
                              setState(() => _selectedId = _packs[index].id);
                            },
                          ),
                          const SizedBox(height: 12),
                        ],
                      ],
                    ),
            ),
            if (!_loading && _error == null && _packs.isNotEmpty)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                child: AppButton(
                  label: 'Próximo',
                  onPressed: handleNext,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
