import 'dart:async';

import 'package:crowdfans/components/profile/membership_artist_card.dart';
import 'package:crowdfans/components/profile/membership_balance_pill.dart';
import 'package:crowdfans/components/profile/membership_filter_chip.dart';
import 'package:crowdfans/components/profile/membership_pro_teaser.dart';
import 'package:crowdfans/components/profile/notification_quiet_mode_note.dart';
import 'package:crowdfans/components/profile/profile_state.dart';
import 'package:crowdfans/components/toolbar/toolbar_back_button.dart';
import 'package:crowdfans/constants/pages.dart';
import 'package:crowdfans/constants/theme.dart';
import 'package:crowdfans/models/membership.dart';
import 'package:crowdfans/services/profile_service.dart';
import 'package:crowdfans/services/wallet_service.dart';
import 'package:crowdfans/state/auth_session.dart';
import 'package:crowdfans/utils/app_alert.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

enum _MembershipFilter { all, active, late, cancelled, available }

/// Memberships ativas, catálogo e banner aprovado (CF-167).
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
  var _filter = _MembershipFilter.all;
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

  Future<void> handleManage(MembershipCard item) async {
    final artistId = item.artistId?.trim() ?? '';
    if (artistId.isEmpty) {
      await AppAlert.show(
        context,
        title: 'Memberships',
        message: 'Esta assinatura não pode ser gerenciada.',
      );
      return;
    }
    final price = item.price?.toInt() ?? 100;
    context.push(
      Pages.profileMembershipManageOf(
        artistId: artistId,
        artistName: item.displayName,
        artistHandle: item.label,
        artistAvatarUrl: item.artistAvatarUri,
        pricePerMonth: price > 0 ? price : 100,
        monthsLabel: item.monthsLabel,
      ),
    );
  }

  Widget _sectionTitle(String title, AppColors colors) {
    return Padding(
      padding: const EdgeInsets.only(top: 8, bottom: 10),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w800,
          color: colors.textPrimary,
        ),
      ),
    );
  }

  List<Widget> _cards(
    List<MembershipCard> items, {
    required bool allowCancel,
    required bool catalog,
  }) {
    if (items.isEmpty) {
      return const [];
    }
    return [
      for (final item in items) ...[
        MembershipArtistCard(
          item: item,
          catalog: catalog,
          busy: _busyId == item.id,
          onCancel: allowCancel && item.canCancel
              ? () => handleManage(item)
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
    final balance = overview?.jamCoinsBalance ?? '0';

    return Scaffold(
      backgroundColor: colors.background,
      body: SafeArea(
        child: Column(
          children: [
            SizedBox(
              height: 56,
              child: Row(
                children: [
                  ToolbarBackButton(onPressed: () => context.pop()),
                  Expanded(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SvgPicture.asset(
                          'assets/icons/Shapes/star-01.svg',
                          width: 18,
                          height: 18,
                          colorFilter: ColorFilter.mode(
                            colors.textPrimary,
                            BlendMode.srcIn,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'Meus Memberships',
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w700,
                            color: colors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  MembershipBalancePill(balance: balance),
                ],
              ),
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
                        MembershipProTeaser(
                          onPressed: () => context.push(Pages.profilePro),
                        ),
                        const SizedBox(height: 20),
                        _sectionTitle('Meus Memberships', colors),
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: [
                              MembershipFilterChip(
                                label: 'Todos',
                                selected: _filter == _MembershipFilter.all,
                                onTap: () => setState(
                                  () => _filter = _MembershipFilter.all,
                                ),
                              ),
                              const SizedBox(width: 8),
                              MembershipFilterChip(
                                label: 'Ativos',
                                selected: _filter == _MembershipFilter.active,
                                onTap: () => setState(
                                  () => _filter = _MembershipFilter.active,
                                ),
                              ),
                              const SizedBox(width: 8),
                              MembershipFilterChip(
                                label: 'Em atraso',
                                selected: _filter == _MembershipFilter.late,
                                onTap: () => setState(
                                  () => _filter = _MembershipFilter.late,
                                ),
                              ),
                              const SizedBox(width: 8),
                              MembershipFilterChip(
                                label: 'Cancelados',
                                selected:
                                    _filter == _MembershipFilter.cancelled,
                                onTap: () => setState(
                                  () =>
                                      _filter = _MembershipFilter.cancelled,
                                ),
                              ),
                              const SizedBox(width: 8),
                              MembershipFilterChip(
                                label: 'Disponíveis',
                                selected:
                                    _filter == _MembershipFilter.available,
                                onTap: () => setState(
                                  () =>
                                      _filter = _MembershipFilter.available,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 12),
                        if (_filter == _MembershipFilter.all ||
                            _filter == _MembershipFilter.active) ...[
                          if (active.isEmpty &&
                              _filter == _MembershipFilter.active)
                            const ProfileState(
                              title: 'Nenhuma membership ativa',
                              message:
                                  'Suas assinaturas ativas aparecerão aqui.',
                              align: TextAlign.left,
                            )
                          else if (active.isNotEmpty) ...[
                            if (_filter == _MembershipFilter.all)
                              _sectionTitle('Ativos', colors),
                            ..._cards(
                              active,
                              allowCancel: true,
                              catalog: false,
                            ),
                          ],
                        ],
                        if (_filter == _MembershipFilter.all ||
                            _filter == _MembershipFilter.late) ...[
                          if (late.isNotEmpty) ...[
                            if (_filter == _MembershipFilter.all)
                              _sectionTitle('Em atraso', colors),
                            ..._cards(late, allowCancel: true, catalog: false),
                          ],
                        ],
                        if (_filter == _MembershipFilter.all ||
                            _filter == _MembershipFilter.cancelled) ...[
                          if (cancelled.isNotEmpty) ...[
                            if (_filter == _MembershipFilter.all)
                              _sectionTitle('Cancelados', colors),
                            ..._cards(
                              cancelled,
                              allowCancel: false,
                              catalog: false,
                            ),
                          ],
                        ],
                        if (_filter == _MembershipFilter.all &&
                            active.isEmpty &&
                            late.isEmpty &&
                            cancelled.isEmpty)
                          const Padding(
                            padding: EdgeInsets.only(bottom: 12),
                            child: ProfileState(
                              title: 'Nenhuma membership ativa',
                              message:
                                  'Suas assinaturas ativas aparecerão aqui.',
                              align: TextAlign.left,
                            ),
                          ),
                        if (_filter == _MembershipFilter.all ||
                            _filter == _MembershipFilter.available) ...[
                          if (_filter == _MembershipFilter.all)
                            _sectionTitle('Disponíveis', colors),
                          if (catalog.isEmpty)
                            const ProfileState(
                              title: 'Nenhuma nova membership',
                              message:
                                  'Não há outras assinaturas disponíveis neste momento.',
                              align: TextAlign.left,
                            )
                          else
                            ..._cards(
                              catalog,
                              allowCancel: false,
                              catalog: true,
                            ),
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
