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

  @override
  void initState() {
    super.initState();
    handleLoad();
  }

  Future<void> handleLoad() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final session = ref.read(authSessionProvider);
      var profile = session.profile ?? await ProfileService.getMyProfile();
      final handle = profile.name.trim().isNotEmpty
          ? profile.name
          : profile.displayName;
      MembershipOverview overview;
      try {
        overview = await ProfileService.getMemberships(handle);
      } catch (_) {
        overview = const MembershipOverview();
      }
      if (overview.cards.isEmpty) {
        final rows = await SubscriptionService.listSubscriptions();
        overview = MembershipOverview(
          jamCoinsBalance: overview.jamCoinsBalance,
          cards: [
            for (final row in rows.where((item) => item.isActive))
              MembershipCard(
                id: '${row.id}',
                artistId: row.artistUid,
                artistName: row.artistName,
                statusLabel: 'Ativa',
              ),
          ],
          catalog: overview.catalog,
        );
      }
      if (!mounted) {
        return;
      }
      setState(() {
        _overview = overview;
        _loading = false;
      });
    } catch (error) {
      if (!mounted) {
        return;
      }
      setState(() {
        _loading = false;
        _error = error.toString();
      });
    }
  }

  Future<void> handleCancel(MembershipCard item) async {
    final artistId = item.artistId;
    if (artistId == null || artistId.isEmpty) {
      await AppAlert.show(
        context,
        title: 'Memberships',
        message: 'Esta assinatura não tem artistId para cancelar.',
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

  @override
  Widget build(BuildContext context) {
    final colors = CrowdFansTheme.of(context);
    final overview = _overview;
    final catalog =
        overview?.catalog.where((item) => !item.isCurrentMember).toList() ??
        const <MembershipCard>[];
    return Scaffold(
      backgroundColor: colors.background,
      body: SafeArea(
        child: Column(
          children: [
            ProfileScreenHeader(
              title: 'Memberships',
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
                        const SizedBox(height: 22),
                        Text(
                          'Minhas memberships',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: colors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 10),
                        if (overview == null || overview.cards.isEmpty)
                          const ProfileState(
                            title: 'Nenhuma membership ativa',
                            message: 'Suas assinaturas ativas aparecerão aqui.',
                          )
                        else
                          for (final item in overview.cards) ...[
                            MembershipArtistCard(
                              item: item,
                              busy: _busyId == item.id,
                              onCancel: item.artistId == null
                                  ? null
                                  : () => handleCancel(item),
                            ),
                            const SizedBox(height: 12),
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
                            message: 'Não há outras assinaturas disponíveis neste momento.',
                          )
                        else
                          for (final item in catalog) ...[
                            MembershipArtistCard(item: item, catalog: true),
                            const SizedBox(height: 12),
                          ],
                        const NotificationQuietModeNote(
                          message: 'Assinar cobra 100 Jam Coins. Recarga e PIX sandbox ficam em Jam Coins. Cancelar não estorna.',
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
