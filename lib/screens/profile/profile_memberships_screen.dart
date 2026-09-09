import 'dart:async';

import 'package:crowdfans/components/buttons/app_button.dart';
import 'package:crowdfans/components/profile/membership_artist_card.dart';
import 'package:crowdfans/components/profile/membership_balance_banner.dart';
import 'package:crowdfans/components/profile/membership_pro_teaser.dart';
import 'package:crowdfans/components/profile/notification_quiet_mode_note.dart';
import 'package:crowdfans/components/profile/profile_screen_header.dart';
import 'package:crowdfans/components/profile/profile_state.dart';
import 'package:crowdfans/constants/pages.dart';
import 'package:crowdfans/constants/theme.dart';
import 'package:crowdfans/models/membership.dart';
import 'package:crowdfans/services/profile_service.dart';
import 'package:crowdfans/services/subscription_service.dart';
import 'package:crowdfans/services/wallet_service.dart';
import 'package:crowdfans/state/auth_session.dart';
import 'package:crowdfans/utils/app_alert.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// Memberships ativas, catálogo e atalho para recarga / Pro.
class ProfileMembershipsScreen extends ConsumerStatefulWidget {
  const ProfileMembershipsScreen({super.key});

  @override
  ConsumerState<ProfileMembershipsScreen> createState() =>
      _ProfileMembershipsScreenState();
}

class _ProfileMembershipsScreenState
    extends ConsumerState<ProfileMembershipsScreen> {
  MembershipOverview? _overview;
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
    } catch (_) {}
  }

  Future<void> handleLoad({bool silent = false}) async {
    if (!silent) {
      setState(() {
        _loading = true;
        _error = null;
      });
    }
    try {
      final session = ref.read(authSessionProvider);
      var profile = session.profile ?? await ProfileService.getMyProfile();
      final handle = profile.name.trim().isNotEmpty
          ? profile.name
          : profile.displayName;
      final memberships = await ProfileService.getMemberships(handle);
      WalletSnapshot? wallet;
      try {
        wallet = await WalletService.getWallet();
      } catch (_) {
        wallet = null;
      }
      var overview = memberships;
      if (wallet != null && wallet.displayBalance.isNotEmpty) {
        overview = overview.copyWith(jamCoinsBalance: wallet.displayBalance);
      }
      if (!mounted) {
        return;
      }
      setState(() {
        _overview = overview;
        _loading = false;
        _error = null;
      });
    } catch (error) {
      if (!mounted) {
        return;
      }
      setState(() {
        _loading = false;
        if (!silent) {
          _error = error.toString();
        }
      });
    }
  }

  Future<void> handleCancel(MembershipCard item) async {
    final artistId = item.artistId;
    if (!item.canCancel || artistId == null) {
      await AppAlert.show(
        context,
        title: 'Memberships',
        message: 'Esta assinatura não pode ser cancelada.',
      );
      return;
    }
    final ok = await AppAlert.confirm(
      context,
      title: 'Cancelar membership',
      message: 'Deixar de seguir ${item.displayName}?',
      confirmLabel: 'Cancelar',
      cancelLabel: 'Manter',
    );
    if (!ok) {
      return;
    }
    setState(() => _busyId = item.id);
    try {
      await SubscriptionService.cancelSubscription(artistId);
      await handleLoad();
    } catch (error) {
      if (mounted) {
        await AppAlert.show(
          context,
          title: 'Memberships',
          message: error.toString(),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _busyId = null);
      }
    }
  }

  List<Widget> section(
    BuildContext context, {
    required String title,
    required List<MembershipCard> items,
    required bool allowCancel,
  }) {
    final colors = CrowdFansTheme.of(context);
    if (items.isEmpty) {
      return const [];
    }
    return [
      const SizedBox(height: 12),
      Text(
        title,
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w800,
          color: colors.textPrimary,
        ),
      ),
      const SizedBox(height: 10),
      for (final item in items) ...[
        MembershipArtistCard(
          item: item,
          busy: _busyId == item.id,
          onCancel: allowCancel && item.canCancel
              ? () => handleCancel(item)
              : null,
        ),
        const SizedBox(height: 12),
      ],
    ];
  }

  @override
  Widget build(BuildContext context) {
    final colors = CrowdFansTheme.of(context);
    final overview = _overview;
    final cards = overview?.cards ?? const <MembershipCard>[];
    final active = [for (final item in cards) if (item.isActiveStatus) item];
    final late = [for (final item in cards) if (item.isLate) item];
    final cancelled = [for (final item in cards) if (item.isCancelled) item];
    final catalog =
        overview?.catalog.where((item) => !item.isCurrentMember).toList() ??
        const <MembershipCard>[];
    return Scaffold(
      backgroundColor: colors.background,
      body: SafeArea(
        child: Column(
          children: [
            ProfileScreenHeader(
              title: 'Meus memberships',
              onBack: () => context.pop(),
            ),
            Expanded(
              child: _loading
                  ? const ProfileState(loading: true)
                  : _error != null
                  ? ProfileState(
                      title: 'Memberships indisponíveis',
                      message: _error,
                      actionLabel: 'Tentar novamente',
                      onAction: handleLoad,
                    )
                  : ListView(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 36),
                      children: [
                        MembershipBalanceBanner(
                          balance: overview?.jamCoinsBalance ?? '0',
                        ),
                        const SizedBox(height: 16),
                        AppButton(
                          label: 'Recarregar Jam Coins',
                          onPressed: () => context.push(Pages.profileWallet),
                        ),
                        const SizedBox(height: 16),
                        MembershipProTeaser(
                          onPressed: () => context.push(Pages.profilePro),
                        ),
                        if (active.isEmpty && late.isEmpty && cancelled.isEmpty)
                          const Padding(
                            padding: EdgeInsets.only(top: 22),
                            child: ProfileState(
                              title: 'Nenhuma membership ativa',
                              message:
                                  'Suas assinaturas ativas aparecerão aqui.',
                            ),
                          )
                        else ...[
                          ...section(
                            context,
                            title: 'Ativos',
                            items: active,
                            allowCancel: true,
                          ),
                          ...section(
                            context,
                            title: 'Em atraso',
                            items: late,
                            allowCancel: true,
                          ),
                          ...section(
                            context,
                            title: 'Cancelados',
                            items: cancelled,
                            allowCancel: false,
                          ),
                        ],
                        const SizedBox(height: 10),
                        Text(
                          'Disponíveis',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: colors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 10),
                        if (catalog.isEmpty)
                          const ProfileState(
                            title: 'Nenhuma nova membership',
                            message:
                                'Não há outras assinaturas disponíveis neste momento.',
                          )
                        else
                          for (final item in catalog) ...[
                            MembershipArtistCard(item: item, catalog: true),
                            const SizedBox(height: 12),
                          ],
                        const NotificationQuietModeNote(
                          message:
                              'Assinar cobra 100 Jam Coins. Recarga fica em Jam Coins. Cancelar não estorna.',
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
