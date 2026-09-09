import 'package:crowdfans/components/buttons/app_button.dart';
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

/// Sobre o fã clube: descrição, moderadores, pedido e apelação.
class FanClubAboutScreen extends StatefulWidget {
  const FanClubAboutScreen({
    super.key,
    required this.artistId,
    this.artistName,
  });

  final String artistId;
  final String? artistName;

  @override
  State<FanClubAboutScreen> createState() => _FanClubAboutScreenState();
}

class _FanClubAboutScreenState extends State<FanClubAboutScreen> {
  ArtistFanClub? _club;
  var _loading = true;
  String? _error;
  var _requestReason = '';
  var _appealDefense = '';
  var _requesting = false;
  var _appealing = false;
  var _formNonce = 0;

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
      if (!mounted) {
        return;
      }
      setState(() {
        _club = club;
        _loading = false;
        if (club == null) {
          _error = 'Não foi possível carregar o fã clube.';
        }
      });
    } catch (_) {
      if (!mounted) {
        return;
      }
      setState(() {
        _loading = false;
        _error = 'Não foi possível carregar o fã clube.';
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

  Future<void> handleRequestModeration() async {
    final trimmed = _requestReason.trim();
    if (trimmed.length < 24 || trimmed.length > 420) {
      await AppAlert.show(
        context,
        title: 'Moderação',
        message: 'Explique em 24 a 420 caracteres por que você quer moderar.',
      );
      return;
    }
    setState(() => _requesting = true);
    try {
      await FanClubService.requestFanClubModeration(widget.artistId, trimmed);
      if (!mounted) {
        return;
      }
      setState(() {
        _requestReason = '';
        _formNonce++;
      });
      await AppAlert.show(
        context,
        title: 'Moderação',
        message: 'Pedido enviado ao artista.',
      );
    } catch (error) {
      if (mounted) {
        await AppAlert.show(
          context,
          title: 'Moderação',
          message: error.toString(),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _requesting = false);
      }
    }
  }

  Future<void> handleAppeal() async {
    final trimmed = _appealDefense.trim();
    if (trimmed.length < 24 || trimmed.length > 420) {
      await AppAlert.show(
        context,
        title: 'Apelação',
        message: 'Explique em 24 a 420 caracteres por que merece retornar.',
      );
      return;
    }
    setState(() => _appealing = true);
    try {
      await FanClubService.createFanClubAppeal(widget.artistId, trimmed);
      if (!mounted) {
        return;
      }
      setState(() {
        _appealDefense = '';
        _formNonce++;
      });
      await AppAlert.show(
        context,
        title: 'Apelação',
        message: 'Pedido de retorno enviado.',
      );
    } catch (error) {
      if (mounted) {
        await AppAlert.show(
          context,
          title: 'Apelação',
          message: error.toString(),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _appealing = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = CrowdFansTheme.of(context);
    final club = _club;
    final preview = (club?.moderators ?? const []).take(3).toList();
    final canRequest =
        club != null &&
        club.isMember &&
        !club.viewerIsOwner &&
        !club.viewerIsModerator;
    return Scaffold(
      backgroundColor: colors.background,
      body: SafeArea(
        child: Column(
          children: [
            ProfileScreenHeader(title: 'Sobre', onBack: handleBack),
            Expanded(
              child: _loading
                  ? const ProfileState(loading: true)
                  : ListView(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 36),
                      children: [
                        if (_error != null)
                          Text(
                            _error!,
                            textAlign: TextAlign.center,
                            style: TextStyle(color: colors.textSecondary),
                          )
                        else if (club != null) ...[
                          Text(
                            club.name.isEmpty
                                ? (widget.artistName ?? 'Fã Clube')
                                : club.name,
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w700,
                              color: colors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            '${club.artistName.isEmpty ? (widget.artistName ?? 'Artista') : club.artistName} · ${club.memberCount} membros',
                            style: TextStyle(
                              fontSize: 14,
                              color: colors.textSecondary,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            club.description.trim().isEmpty
                                ? 'Este fã clube ainda não tem uma descrição.'
                                : club.description,
                            style: TextStyle(
                              fontSize: 15,
                              height: 1.45,
                              color: colors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 22),
                          Text(
                            'Moderadores',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: colors.textPrimary,
                            ),
                          ),
                          if (preview.isEmpty)
                            Padding(
                              padding: const EdgeInsets.only(top: 8),
                              child: Text(
                                'Nenhum moderador listado.',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: colors.textTertiary,
                                ),
                              ),
                            )
                          else
                            for (final mod in preview)
                              FanClubModeratorRow(moderator: mod),
                          const SizedBox(height: 12),
                          AppButton(
                            label: 'Ver todos os moderadores',
                            variant: AppButtonVariant.outline,
                            onPressed: () {
                              context.push(
                                Pages.fanClubModeratorsOf(
                                  artistId: widget.artistId,
                                  name: club.artistName,
                                ),
                              );
                            },
                          ),
                          if (club.viewerIsOwner || club.viewerIsModerator) ...[
                            const SizedBox(height: 8),
                            AppButton(
                              label: 'Moderação (strikes / expulsões)',
                              variant: AppButtonVariant.outline,
                              onPressed: () {
                                context.push(
                                  Pages.fanClubModerationOf(
                                    artistId: widget.artistId,
                                    name: club.artistName,
                                  ),
                                );
                              },
                            ),
                          ],
                          if (canRequest) ...[
                            const SizedBox(height: 20),
                            Text(
                              'Solicitar moderação',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: colors.textSecondary,
                              ),
                            ),
                            const SizedBox(height: 8),
                            AppTextField(
                              key: ValueKey('request-$_formNonce'),
                              hint: 'Conte por que você quer ajudar a moderar este fã clube',
                              maxLines: 4,
                              onChanged: (value) => _requestReason = value,
                            ),
                            const SizedBox(height: 12),
                            AppButton(
                              label: 'Enviar pedido',
                              loading: _requesting,
                              onPressed: handleRequestModeration,
                            ),
                          ],
                          if (club.viewerIsExpelled) ...[
                            const SizedBox(height: 20),
                            Text(
                              'Você foi expulso — apelar',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: colors.textSecondary,
                              ),
                            ),
                            const SizedBox(height: 8),
                            AppTextField(
                              key: ValueKey('appeal-$_formNonce'),
                              hint: 'Explique por que merece retornar (mín. 24 caracteres)',
                              maxLines: 4,
                              onChanged: (value) => _appealDefense = value,
                            ),
                            const SizedBox(height: 12),
                            AppButton(
                              label: 'Enviar apelação',
                              loading: _appealing,
                              onPressed: handleAppeal,
                            ),
                          ],
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
