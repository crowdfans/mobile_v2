import 'package:crowdfans/components/buttons/app_button.dart';
import 'package:crowdfans/components/fan_club/fan_club_moderator_row.dart';
import 'package:crowdfans/components/profile/profile_screen_header.dart';
import 'package:crowdfans/constants/pages.dart';
import 'package:crowdfans/constants/theme.dart';
import 'package:crowdfans/services/fan_club_service.dart';
import 'package:crowdfans/state/auth_session.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// Gestão rápida do fã clube do artista autenticado.
class ArtistFanClubSettingsScreen extends ConsumerStatefulWidget {
  const ArtistFanClubSettingsScreen({super.key});

  @override
  ConsumerState<ArtistFanClubSettingsScreen> createState() =>
      _ArtistFanClubSettingsScreenState();
}

class _ArtistFanClubSettingsScreenState
    extends ConsumerState<ArtistFanClubSettingsScreen> {
  ArtistFanClub? _fanClub;
  var _requests = <FanClubModeratorRequest>[];
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
    context.go(Pages.profileSettings);
  }

  Future<void> handleLoad() async {
    final uid = ref.read(authSessionProvider).profile?.userUid ?? '';
    if (uid.isEmpty) {
      setState(() {
        _loading = false;
        _error = 'Perfil de artista não encontrado.';
      });
      return;
    }
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final club = await FanClubService.getArtistFanClub(uid);
      var requests = <FanClubModeratorRequest>[];
      try {
        requests = await FanClubService.listFanClubModeratorRequests(uid);
      } catch (_) {
        requests = const [];
      }
      if (!mounted) {
        return;
      }
      setState(() {
        _fanClub = club;
        _requests = requests;
        _loading = false;
      });
    } catch (_) {
      if (!mounted) {
        return;
      }
      setState(() {
        _fanClub = null;
        _loading = false;
        _error = 'Não foi possível carregar o fã clube.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = CrowdFansTheme.of(context);
    final profile = ref.watch(authSessionProvider).profile;
    final club = _fanClub;
    final artistId = profile?.userUid ?? '';
    return Scaffold(
      backgroundColor: colors.background,
      body: SafeArea(
        child: Column(
          children: [
            ProfileScreenHeader(title: 'Gerenciar Fã Clube', onBack: handleBack),
            Expanded(
              child: _loading
                  ? const Center(child: CircularProgressIndicator())
                  : ListView(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 40),
                      children: [
                        if (_error != null)
                          Text(
                            _error!,
                            style: TextStyle(color: colors.textSecondary),
                          ),
                        if (club != null) ...[
                          DecoratedBox(
                            decoration: BoxDecoration(
                              color: colors.surface,
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(color: colors.border),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    club.name.trim().isEmpty
                                        ? 'Fã Clube'
                                        : club.name,
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w700,
                                      color: colors.textPrimary,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    '${club.memberCount} membros · ${club.moderators.length} moderadores · ${_requests.length} pedidos pendentes',
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: colors.textSecondary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 14),
                          AppButton(
                            label: 'Abrir gestão de moderadores',
                            onPressed: () => context.push(
                              Pages.fanClubModeratorsOf(
                                artistId: artistId,
                                name: club.artistName,
                              ),
                            ),
                          ),
                          const SizedBox(height: 10),
                          AppButton(
                            label: 'Abrir moderação (strikes / expulsões)',
                            variant: AppButtonVariant.outline,
                            onPressed: () => context.push(
                              Pages.fanClubModerationOf(
                                artistId: artistId,
                                name: club.artistName,
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),
                          Text(
                            'Moderadores',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: colors.textPrimary,
                            ),
                          ),
                          if (club.moderators.isEmpty)
                            Padding(
                              padding: const EdgeInsets.only(top: 8),
                              child: Text(
                                'Nenhum moderador nomeado ainda.',
                                style: TextStyle(color: colors.textSecondary),
                              ),
                            )
                          else
                            for (final mod in club.moderators)
                              FanClubModeratorRow(moderator: mod),
                          const SizedBox(height: 16),
                          Text(
                            'Pedidos pendentes',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: colors.textPrimary,
                            ),
                          ),
                          if (_requests.isEmpty)
                            Padding(
                              padding: const EdgeInsets.only(top: 8),
                              child: Text(
                                'Sem pedidos de moderação no momento.',
                                style: TextStyle(color: colors.textSecondary),
                              ),
                            )
                          else
                            for (final request in _requests.take(5))
                              Padding(
                                padding: const EdgeInsets.only(top: 10),
                                child: DecoratedBox(
                                  decoration: BoxDecoration(
                                    color: colors.surface,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(color: colors.border),
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.all(12),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          request.displayName.trim().isEmpty
                                              ? request.requesterUid
                                              : request.displayName,
                                          style: TextStyle(
                                            fontWeight: FontWeight.w600,
                                            color: colors.textPrimary,
                                          ),
                                        ),
                                        Text(
                                          request.reason,
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: colors.textSecondary,
                                          ),
                                        ),
                                      ],
                                    ),
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
