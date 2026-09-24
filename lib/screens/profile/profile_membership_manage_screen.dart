import 'package:crowdfans/api/api_error.dart';
import 'package:crowdfans/components/buttons/app_button.dart';
import 'package:crowdfans/components/profile/membership_manage_artist_summary.dart';
import 'package:crowdfans/components/profile/membership_manage_option_tile.dart';
import 'package:crowdfans/components/profile/profile_screen_header.dart';
import 'package:crowdfans/constants/pages.dart';
import 'package:crowdfans/constants/theme.dart';
import 'package:crowdfans/services/subscription_service.dart';
import 'package:crowdfans/utils/app_alert.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Gerenciar membership — Pausar ou Cancelar com consequências legíveis (CF-205).
class ProfileMembershipManageScreen extends StatefulWidget {
  const ProfileMembershipManageScreen({
    super.key,
    required this.artistId,
    required this.artistName,
    this.artistHandle,
    this.artistAvatarUrl,
    this.pricePerMonth = 100,
    this.monthsLabel,
  });

  final String artistId;
  final String artistName;
  final String? artistHandle;
  final String? artistAvatarUrl;
  final int pricePerMonth;
  final String? monthsLabel;

  @override
  State<ProfileMembershipManageScreen> createState() =>
      _ProfileMembershipManageScreenState();
}

class _ProfileMembershipManageScreenState
    extends State<ProfileMembershipManageScreen> {
  var _selected = MembershipManageAction.pause;
  var _busy = false;

  void handleBack() {
    if (context.canPop()) {
      context.pop();
      return;
    }
    context.go(Pages.profileMemberships);
  }

  Future<void> handleConfirm() async {
    if (_busy || widget.artistId.trim().isEmpty) {
      return;
    }
    if (_selected == MembershipManageAction.pause) {
      await AppAlert.show(
        context,
        title: 'Pausar membership',
        message:
            'A pausa ainda não está disponível no serviço. Você pode Cancelar para encerrar a assinatura agora, ou manter ativa e voltar depois.',
      );
      return;
    }

    setState(() => _busy = true);
    try {
      await SubscriptionService.cancelSubscription(widget.artistId);
      if (!mounted) {
        return;
      }
      context.go(Pages.profileMemberships);
    } on ApiError catch (error) {
      if (mounted) {
        await AppAlert.show(
          context,
          title: 'Membership',
          message: error.message,
        );
      }
    } catch (error) {
      if (mounted) {
        await AppAlert.show(
          context,
          title: 'Membership',
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
    final name = widget.artistName.trim().isEmpty
        ? 'Artista'
        : widget.artistName.trim();
    final price = widget.pricePerMonth > 0 ? widget.pricePerMonth : 100;
    final months = (widget.monthsLabel ?? '').trim();
    final contextLine = months.isNotEmpty
        ? 'Seu vínculo atual está em $months. Você pode pausar para voltar depois ou cancelar de vez.'
        : 'Você pode pausar para voltar depois ou cancelar de vez.';

    return Scaffold(
      backgroundColor: colors.background,
      body: SafeArea(
        child: Column(
          children: [
            ProfileScreenHeader(
              title: 'Gerenciar membership',
              onBack: handleBack,
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                children: [
                  MembershipManageArtistSummary(
                    artistName: name,
                    artistHandle: widget.artistHandle,
                    artistAvatarUrl: widget.artistAvatarUrl,
                    pricePerMonth: price,
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'O que você quer fazer com esse membership?',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                      color: colors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    contextLine,
                    style: TextStyle(
                      fontSize: 14,
                      height: 20 / 14,
                      color: colors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 20),
                  MembershipManageOptionTile(
                    action: MembershipManageAction.pause,
                    selected: _selected == MembershipManageAction.pause,
                    onSelected: (action) {
                      setState(() => _selected = action);
                    },
                  ),
                  const SizedBox(height: 12),
                  MembershipManageOptionTile(
                    action: MembershipManageAction.cancel,
                    selected: _selected == MembershipManageAction.cancel,
                    onSelected: (action) {
                      setState(() => _selected = action);
                    },
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: AppButton(
                label: _busy ? 'Confirmando...' : 'Confirmar',
                variant: AppButtonVariant.dark,
                loading: _busy,
                disabled: _busy,
                onPressed: handleConfirm,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
