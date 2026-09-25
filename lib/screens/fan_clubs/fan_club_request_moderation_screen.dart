import 'package:crowdfans/components/buttons/app_button.dart';
import 'package:crowdfans/components/fan_club/fan_club_moderator_candidate_card.dart';
import 'package:crowdfans/components/input/app_text_field.dart';
import 'package:crowdfans/components/profile/profile_screen_header.dart';
import 'package:crowdfans/components/profile/profile_state.dart';
import 'package:crowdfans/constants/pages.dart';
import 'package:crowdfans/constants/theme.dart';
import 'package:crowdfans/mocks/cf_temp_mocks.dart';
import 'package:crowdfans/models/profile.dart';
import 'package:crowdfans/services/fan_club_service.dart';
import 'package:crowdfans/services/profile_service.dart';
import 'package:crowdfans/utils/app_alert.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

const _minReasonLength = 24;
const _maxReasonLength = 420;

/// Solicitar moderação — formulário dedicado (CF-224 / destino do CF-223).
class FanClubRequestModerationScreen extends StatefulWidget {
  const FanClubRequestModerationScreen({
    super.key,
    required this.artistId,
    this.artistName,
  });

  final String artistId;
  final String? artistName;

  @override
  State<FanClubRequestModerationScreen> createState() =>
      _FanClubRequestModerationScreenState();
}

class _FanClubRequestModerationScreenState
    extends State<FanClubRequestModerationScreen> {
  Profile? _profile;
  var _loading = true;
  var _submitting = false;
  var _reason = '';
  String? _error;

  bool get _canSubmit =>
      _reason.trim().length >= _minReasonLength &&
      _reason.trim().length <= _maxReasonLength &&
      !_submitting;

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
      if (kUseCfTempMocks && CfTempMocks.useFanClubFixtures) {
        if (!mounted) {
          return;
        }
        setState(() {
          _profile = Profile(
            userUid: 'cf-mod-aline',
            displayName: cfTempMockModerationCandidate.displayName,
            name: 'alineduarte',
            description: '',
            photoUrl: cfTempMockModerationCandidate.photoUrl,
            isArtist: false,
          );
          _loading = false;
        });
        return;
      }
      final profile = await ProfileService.getMyProfile();
      if (!mounted) {
        return;
      }
      setState(() {
        _profile = profile;
        _loading = false;
      });
    } catch (_) {
      if (!mounted) {
        return;
      }
      if (kUseCfTempMocks && CfTempMocks.useFanClubFixtures) {
        setState(() {
          _profile = Profile(
            userUid: 'cf-mod-aline',
            displayName: cfTempMockModerationCandidate.displayName,
            name: 'alineduarte',
            description: '',
            photoUrl: cfTempMockModerationCandidate.photoUrl,
            isArtist: false,
          );
          _loading = false;
        });
        return;
      }
      setState(() {
        _loading = false;
        _error = 'Não foi possível carregar seu perfil.';
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

  Future<void> handleSubmit() async {
    final trimmed = _reason.trim();
    if (trimmed.length < _minReasonLength ||
        trimmed.length > _maxReasonLength) {
      return;
    }
    setState(() => _submitting = true);
    try {
      await FanClubService.requestFanClubModeration(widget.artistId, trimmed);
      if (!mounted) {
        return;
      }
      await AppAlert.show(
        context,
        title: 'Moderação',
        message: 'Pedido enviado ao artista.',
      );
      if (mounted) {
        handleBack();
      }
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
        setState(() => _submitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = CrowdFansTheme.of(context);
    final profile = _profile;
    final count = _reason.length.clamp(0, _maxReasonLength);

    return Scaffold(
      backgroundColor: colors.background,
      body: SafeArea(
        child: Column(
          children: [
            ProfileScreenHeader(
              title: 'Solicitar moderação',
              onBack: handleBack,
            ),
            Expanded(
              child: _loading
                  ? const ProfileState(loading: true)
                  : ListView(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                      children: [
                        if (_error != null)
                          Text(
                            _error!,
                            textAlign: TextAlign.center,
                            style: TextStyle(color: colors.textSecondary),
                          )
                        else ...[
                          Text(
                            'Conte ao artista por que você quer ajudar na '
                            'moderação e como pode contribuir com o fã-clube.',
                            style: TextStyle(
                              fontSize: 15,
                              height: 1.45,
                              color: colors.textSecondary,
                            ),
                          ),
                          const SizedBox(height: 20),
                          if (profile != null)
                            FanClubModeratorCandidateCard(
                              displayName: profile.displayName,
                              handle: profile.name,
                              photoUrl: profile.photoUrl,
                            ),
                          const SizedBox(height: 20),
                          AppTextField(
                            hint:
                                'Explique por que você quer ser moderador(a) e como ajudaria esse fã-clube.',
                            maxLines: 6,
                            maxLength: _maxReasonLength,
                            onChanged: (value) {
                              setState(() => _reason = value);
                            },
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  'Mínimo de $_minReasonLength caracteres.',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: colors.textTertiary,
                                  ),
                                ),
                              ),
                              Text(
                                '$count/$_maxReasonLength',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: colors.textTertiary,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 28),
                          AppButton(
                            label: 'Enviar solicitação',
                            loading: _submitting,
                            disabled: !_canSubmit,
                            onPressed: handleSubmit,
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
