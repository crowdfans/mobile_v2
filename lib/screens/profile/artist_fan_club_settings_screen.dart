import 'package:crowdfans/components/input/app_text_field.dart';
import 'package:crowdfans/components/profile/artist_fan_club_person_row.dart';
import 'package:crowdfans/components/profile/artist_fan_club_summary_card.dart';
import 'package:crowdfans/components/profile/profile_screen_header.dart';
import 'package:crowdfans/constants/pages.dart';
import 'package:crowdfans/constants/theme.dart';
import 'package:crowdfans/services/fan_club_service.dart';
import 'package:crowdfans/state/auth_session.dart';
import 'package:crowdfans/utils/app_alert.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// Gestão do fã clube do artista (CF-117).
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
  var _busy = false;
  String? _error;
  var _searchQuery = '';
  var _searchNonce = 0;

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

  Future<void> handleRemove(FanClubModerator moderator) async {
    final artistId = ref.read(authSessionProvider).profile?.userUid ?? '';
    if (moderator.isOwner || artistId.isEmpty) {
      return;
    }
    final ok = await AppAlert.confirm(
      context,
      title: 'Remover moderador',
      message: 'Remover ${moderator.displayName} da moderação?',
      confirmLabel: 'Remover',
    );
    if (!ok) {
      return;
    }
    setState(() => _busy = true);
    try {
      await FanClubService.removeFanClubModerator(artistId, moderator.userUid);
      await handleLoad();
    } catch (error) {
      if (mounted) {
        await AppAlert.show(
          context,
          title: 'Moderadores',
          message: error.toString(),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _busy = false);
      }
    }
  }

  Future<void> handleApprove(FanClubModeratorRequest request) async {
    final artistId = ref.read(authSessionProvider).profile?.userUid ?? '';
    if (artistId.isEmpty) {
      return;
    }
    setState(() => _busy = true);
    try {
      await FanClubService.approveFanClubModeratorRequest(
        artistId,
        request.requestId,
      );
      await handleLoad();
    } catch (error) {
      if (mounted) {
        await AppAlert.show(
          context,
          title: 'Pedidos',
          message: error.toString(),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _busy = false);
      }
    }
  }

  Future<void> handleAddByUid() async {
    final artistId = ref.read(authSessionProvider).profile?.userUid ?? '';
    final uid = _searchQuery.trim();
    if (artistId.isEmpty || uid.isEmpty) {
      await AppAlert.show(
        context,
        title: 'Adicionar moderador',
        message: 'Informe o userUid do fã para adicionar.',
      );
      return;
    }
    setState(() => _busy = true);
    try {
      await FanClubService.addFanClubModerator(artistId, uid);
      if (!mounted) {
        return;
      }
      setState(() {
        _searchQuery = '';
        _searchNonce++;
      });
      await handleLoad();
    } catch (error) {
      if (mounted) {
        await AppAlert.show(
          context,
          title: 'Adicionar moderador',
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
    final profile = ref.watch(authSessionProvider).profile;
    final club = _fanClub;
    final artistId = profile?.userUid ?? '';
    final artistName = club?.artistName.isNotEmpty == true
        ? club!.artistName
        : (profile?.displayName ?? 'artista');
    final moderators = (club?.moderators ?? const [])
        .where((mod) => !mod.isOwner)
        .toList();
    final pending = _requests
        .where((item) => item.status.toLowerCase() != 'rejected')
        .toList();

    return Scaffold(
      backgroundColor: colors.background,
      body: SafeArea(
        child: Column(
          children: [
            ProfileScreenHeader(title: 'Fã Clube', onBack: handleBack),
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
                          Row(
                            children: [
                              Expanded(
                                child: ArtistFanClubSummaryCard(
                                  label: 'Moderadores ativos',
                                  value: moderators.length,
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: ArtistFanClubSummaryCard(
                                  label: 'Pedidos pendentes',
                                  value: pending.length,
                                  onTap: () => context.push(
                                    Pages.fanClubModeratorsOf(
                                      artistId: artistId,
                                      name: artistName,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          DecoratedBox(
                            decoration: BoxDecoration(
                              color: colors.surface,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: colors.border),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.fromLTRB(14, 14, 14, 6),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Moderadores',
                                    style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w700,
                                      color: colors.textPrimary,
                                    ),
                                  ),
                                  if (moderators.isEmpty)
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 12,
                                      ),
                                      child: Text(
                                        'Nenhum moderador nomeado ainda.',
                                        style: TextStyle(
                                          color: colors.textSecondary,
                                        ),
                                      ),
                                    )
                                  else
                                    for (final mod in moderators)
                                      ArtistFanClubPersonRow(
                                        displayName: mod.displayName,
                                        handle: mod.handle,
                                        photoUrl: mod.photoUrl,
                                        actionLabel: 'Remover',
                                        onAction: _busy
                                            ? () {}
                                            : () => handleRemove(mod),
                                      ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  'Pedidos para moderar',
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w700,
                                    color: colors.textPrimary,
                                  ),
                                ),
                              ),
                              TextButton(
                                onPressed: () => context.push(
                                  Pages.fanClubModeratorsOf(
                                    artistId: artistId,
                                    name: artistName,
                                  ),
                                ),
                                child: Text(
                                  'Ver todos',
                                  style: TextStyle(
                                    color: colors.primary,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          if (pending.isEmpty)
                            Text(
                              'Sem pedidos de moderação no momento.',
                              style: TextStyle(color: colors.textSecondary),
                            )
                          else
                            for (final request in pending.take(3))
                              DecoratedBox(
                                decoration: BoxDecoration(
                                  color: colors.surface,
                                  borderRadius: BorderRadius.circular(14),
                                  border: Border.all(color: colors.border),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(12),
                                  child: ArtistFanClubPersonRow(
                                    displayName: request.displayName,
                                    handle: request.handle,
                                    photoUrl: request.photoUrl,
                                    actionLabel: 'Adicionar',
                                    primaryAction: true,
                                    reason: request.reason,
                                    onAction: _busy
                                        ? () {}
                                        : () => handleApprove(request),
                                  ),
                                ),
                              ),
                          const SizedBox(height: 18),
                          Text(
                            'Adicionar fãs como moderadores',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: colors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'A API ainda não lista fãs/seguidores para busca. Use o userUid do fã.',
                            style: TextStyle(
                              fontSize: 12,
                              color: colors.textSecondary,
                            ),
                          ),
                          const SizedBox(height: 10),
                          AppTextField(
                            key: ValueKey('search-$_searchNonce'),
                            hint:
                                'Pesquisar entre fãs e seguidores de $artistName',
                            onChanged: (value) => _searchQuery = value,
                          ),
                          const SizedBox(height: 10),
                          Align(
                            alignment: Alignment.centerRight,
                            child: Material(
                              color: colors.primary,
                              borderRadius: BorderRadius.circular(999),
                              child: InkWell(
                                onTap: _busy ? null : handleAddByUid,
                                borderRadius: BorderRadius.circular(999),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 10,
                                  ),
                                  child: Text(
                                    'Adicionar',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w700,
                                      color: colors.buttonPrimaryText,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          TextButton(
                            onPressed: () => context.push(
                              Pages.fanClubModerationOf(
                                artistId: artistId,
                                name: artistName,
                              ),
                            ),
                            child: Text(
                              'Abrir painel de moderação',
                              style: TextStyle(color: colors.primary),
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
