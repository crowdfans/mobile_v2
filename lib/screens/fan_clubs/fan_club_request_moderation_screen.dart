import 'package:crowdfans/api/api_error.dart';
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

/// Traduz erros do POST moderator-requests para copy compreensível (CF-224).
String mapFanClubModerationRequestError(Object error) {
  final raw = error is ApiError ? error.message : error.toString();
  final lower = raw.toLowerCase();
  if (lower.contains('pending request already exists') ||
      lower.contains('already pending')) {
    return 'Você já tem um pedido de moderação pendente neste fã-clube.';
  }
  if (lower.contains('between 24 and 420')) {
    return 'Explique em 24 a 420 caracteres.';
  }
  if (lower.contains('only members or subscribers')) {
    return 'Só membros ou assinantes podem solicitar moderação.';
  }
  if (lower.contains('already a moderator')) {
    return 'Você já é moderador(a) deste fã-clube.';
  }
  if (lower.contains('club owner') || lower.contains('already the club')) {
    return 'O artista já é o dono do fã-clube.';
  }
  return raw;
}

Profile _cf224FixtureCandidate() {
  return Profile(
    userUid: 'cf-mod-aline',
    displayName: cfTempMockModerationCandidate.displayName,
    name: 'alineduarte',
    description: '',
    photoUrl: cfTempMockModerationCandidate.photoUrl,
    isArtist: false,
  );
}

bool get _useCf224CandidateFixture =>
    kUseCfTempMocks &&
    (kUseCf224RequestModerationMocks || CfTempMocks.useFanClubFixtures);

/// Solicitar moderação — formulário dedicado (CF-224 / destino do CF-223).
class FanClubRequestModerationScreen extends StatefulWidget {
  const FanClubRequestModerationScreen({
    super.key,
    required this.artistId,
    this.artistName,
  });

  /// Limite mínimo alinhado ao servidor (`CreateModeratorRequest`, 24 runes).
  static const minReasonLength = 24;

  /// Limite máximo alinhado ao servidor (`CreateModeratorRequest`, 420 runes).
  static const maxReasonLength = 420;

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

  int get _reasonChars => _reason.trim().characters.length;

  bool get _canSubmit =>
      _reasonChars >= FanClubRequestModerationScreen.minReasonLength &&
      _reasonChars <= FanClubRequestModerationScreen.maxReasonLength &&
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
      if (_useCf224CandidateFixture) {
        if (!mounted) {
          return;
        }
        setState(() {
          _profile = _cf224FixtureCandidate();
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
      if (_useCf224CandidateFixture) {
        setState(() {
          _profile = _cf224FixtureCandidate();
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
    final chars = trimmed.characters.length;
    if (chars < FanClubRequestModerationScreen.minReasonLength ||
        chars > FanClubRequestModerationScreen.maxReasonLength) {
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
          message: mapFanClubModerationRequestError(error),
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
    final count = _reason.characters.length.clamp(
      0,
      FanClubRequestModerationScreen.maxReasonLength,
    );

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
                            maxLength:
                                FanClubRequestModerationScreen.maxReasonLength,
                            onChanged: (value) {
                              setState(() => _reason = value);
                            },
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  'Mínimo de ${FanClubRequestModerationScreen.minReasonLength} caracteres.',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: colors.textTertiary,
                                  ),
                                ),
                              ),
                              Text(
                                '$count/${FanClubRequestModerationScreen.maxReasonLength}',
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
