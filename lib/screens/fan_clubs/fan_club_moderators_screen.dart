import 'package:crowdfans/components/buttons/app_button.dart';
import 'package:crowdfans/components/fan_club/fan_club_moderator_request_card.dart';
import 'package:crowdfans/components/fan_club/fan_club_moderator_row.dart';
import 'package:crowdfans/components/input/app_text_field.dart';
import 'package:crowdfans/components/profile/profile_screen_header.dart';
import 'package:crowdfans/components/profile/profile_state.dart';
import 'package:crowdfans/constants/pages.dart';
import 'package:crowdfans/constants/theme.dart';
import 'package:crowdfans/services/fan_club_service.dart';
import 'package:crowdfans/utils/app_alert.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Lista de moderadores; o dono adiciona, remove e revisa pedidos.
class FanClubModeratorsScreen extends StatefulWidget {
  const FanClubModeratorsScreen({super.key, required this.artistId});

  final String artistId;

  @override
  State<FanClubModeratorsScreen> createState() =>
      _FanClubModeratorsScreenState();
}

class _FanClubModeratorsScreenState extends State<FanClubModeratorsScreen> {
  ArtistFanClub? _club;
  var _requests = <FanClubModeratorRequest>[];
  var _loading = true;
  String? _error;
  var _newUid = '';
  var _saving = false;
  var _uidNonce = 0;

  @override
  void initState() {
    super.initState();
    handleLoad();
  }

  Future<void> handleLoad() async {
    if (widget.artistId.trim().isEmpty) {
      setState(() {
        _loading = false;
        _error = 'Artista inválido.';
      });
      return;
    }
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final club = await FanClubService.getArtistFanClub(widget.artistId);
      var requests = <FanClubModeratorRequest>[];
      if (club?.viewerIsOwner == true) {
        try {
          requests = await FanClubService.listFanClubModeratorRequests(
            widget.artistId,
          );
        } catch (_) {
          // Pedidos só existem para o dono; 403/404 não bloqueia a lista.
          requests = [];
        }
      }
      if (!mounted) {
        return;
      }
      setState(() {
        _club = club;
        _requests = requests;
        _loading = false;
        if (club == null) {
          _error = 'Não foi possível carregar os moderadores.';
        }
      });
    } catch (_) {
      if (!mounted) {
        return;
      }
      setState(() {
        _loading = false;
        _error = 'Não foi possível carregar os moderadores.';
      });
    }
  }

  void handleBack() {
    if (context.canPop()) {
      context.pop();
      return;
    }
    context.go(Pages.clubs);
  }

  Future<void> handleAddModerator() async {
    final uid = _newUid.trim();
    if (uid.isEmpty) {
      await AppAlert.show(
        context,
        title: 'Moderadores',
        message: 'Informe o userUid do fã.',
      );
      return;
    }
    setState(() => _saving = true);
    try {
      await FanClubService.addFanClubModerator(widget.artistId, uid);
      if (!mounted) {
        return;
      }
      setState(() {
        _newUid = '';
        _uidNonce++;
      });
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
        setState(() => _saving = false);
      }
    }
  }

  Future<void> handleRemoveModerator(FanClubModerator moderator) async {
    if (moderator.isOwner) {
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
    try {
      await FanClubService.removeFanClubModerator(
        widget.artistId,
        moderator.userUid,
      );
      await handleLoad();
    } catch (error) {
      if (mounted) {
        await AppAlert.show(
          context,
          title: 'Moderadores',
          message: error.toString(),
        );
      }
    }
  }

  Future<void> handleApprove(FanClubModeratorRequest request) async {
    try {
      await FanClubService.approveFanClubModeratorRequest(
        widget.artistId,
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
    }
  }

  Future<void> handleReject(FanClubModeratorRequest request) async {
    try {
      await FanClubService.rejectFanClubModeratorRequest(
        widget.artistId,
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
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = CrowdFansTheme.of(context);
    final club = _club;
    final isOwner = club?.viewerIsOwner == true;
    final mods = club?.moderators ?? const [];
    return Scaffold(
      backgroundColor: colors.background,
      body: SafeArea(
        child: Column(
          children: [
            ProfileScreenHeader(title: 'Moderadores', onBack: handleBack),
            Expanded(
              child: _loading
                  ? const ProfileState(loading: true)
                  : ListView(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 36),
                      children: [
                        if (isOwner) ...[
                          if (_requests.isNotEmpty) ...[
                            Text(
                              'Pedidos pendentes',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: colors.textSecondary,
                              ),
                            ),
                            const SizedBox(height: 8),
                            for (final request in _requests) ...[
                              FanClubModeratorRequestCard(
                                request: request,
                                onApprove: () => handleApprove(request),
                                onReject: () => handleReject(request),
                              ),
                              const SizedBox(height: 10),
                            ],
                          ],
                          Text(
                            'Adicionar moderador (userUid)',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: colors.textSecondary,
                            ),
                          ),
                          const SizedBox(height: 8),
                          AppTextField(
                            key: ValueKey('uid-$_uidNonce'),
                            hint: 'UUID do fã',
                            onChanged: (value) => _newUid = value,
                          ),
                          const SizedBox(height: 12),
                          AppButton(
                            label: 'Adicionar',
                            loading: _saving,
                            onPressed: handleAddModerator,
                          ),
                          const SizedBox(height: 16),
                        ],
                        if (_error != null)
                          ProfileState(title: 'Erro', message: _error)
                        else if (mods.isEmpty)
                          const ProfileState(
                            title: 'Nenhum moderador',
                            message: 'Nenhum moderador encontrado.',
                          )
                        else
                          for (final mod in mods)
                            FanClubModeratorRow(
                              moderator: mod,
                              onRemove: isOwner && !mod.isOwner
                                  ? () => handleRemoveModerator(mod)
                                  : null,
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
