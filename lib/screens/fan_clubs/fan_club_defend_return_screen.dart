import 'package:crowdfans/api/api_error.dart';
import 'package:crowdfans/components/buttons/app_button.dart';
import 'package:crowdfans/components/fan_club/fan_club_defend_return_field.dart';
import 'package:crowdfans/components/fan_club/fan_club_defend_return_reason_card.dart';
import 'package:crowdfans/components/profile/profile_screen_header.dart';
import 'package:crowdfans/constants/pages.dart';
import 'package:crowdfans/constants/theme.dart';
import 'package:crowdfans/mocks/cf_temp_mocks.dart';
import 'package:crowdfans/services/fan_club_service.dart';
import 'package:crowdfans/utils/app_alert.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Formulário para defender o retorno ao fã-clube (CF-200).
class FanClubDefendReturnScreen extends StatefulWidget {
  const FanClubDefendReturnScreen({
    super.key,
    required this.artistId,
    this.artistName,
    this.expulsionReason,
  });

  final String artistId;
  final String? artistName;
  final String? expulsionReason;

  @override
  State<FanClubDefendReturnScreen> createState() =>
      _FanClubDefendReturnScreenState();
}

class _FanClubDefendReturnScreenState extends State<FanClubDefendReturnScreen> {
  final _controller = TextEditingController();
  var _busy = false;
  String? _fieldError;
  String? _reason;

  @override
  void initState() {
    super.initState();
    _reason = widget.expulsionReason;
    if ((_reason ?? '').trim().isEmpty) {
      // TEMP: demo do card rosado do print enquanto a API não manda motivo.
      if (CfTempMocks.useFanClubFixtures) {
        _reason = cfTempMockExpulsionReason;
      }
      handleLoadReason();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> handleLoadReason() async {
    try {
      final club = await FanClubService.getArtistFanClub(widget.artistId);
      if (!mounted) {
        return;
      }
      final apiReason = club?.viewerExpulsionReason?.trim() ?? '';
      setState(() {
        if (apiReason.isNotEmpty) {
          _reason = apiReason;
        } else if (CfTempMocks.useFanClubFixtures &&
            (_reason ?? '').trim().isEmpty) {
          _reason = cfTempMockExpulsionReason;
        }
      });
    } catch (_) {
      if (!mounted) {
        return;
      }
      if (CfTempMocks.useFanClubFixtures && (_reason ?? '').trim().isEmpty) {
        setState(() => _reason = cfTempMockExpulsionReason);
      }
    }
  }

  void handleBack() {
    if (context.canPop()) {
      context.pop();
      return;
    }
    context.go(
      Pages.fanClubCommunityOf(
        widget.artistId,
        name: widget.artistName,
      ),
    );
  }

  bool get canSubmit {
    final length = _controller.text.trim().characters.length;
    return length >= FanClubDefendReturnField.minChars &&
        length <= FanClubDefendReturnField.maxChars &&
        !_busy;
  }

  Future<void> handleSubmit() async {
    final trimmed = _controller.text.trim();
    final length = trimmed.characters.length;
    if (length < FanClubDefendReturnField.minChars ||
        length > FanClubDefendReturnField.maxChars) {
      setState(() {
        _fieldError =
            'Explique em ${FanClubDefendReturnField.minChars} a ${FanClubDefendReturnField.maxChars} caracteres.';
      });
      return;
    }
    setState(() {
      _busy = true;
      _fieldError = null;
    });
    try {
      await FanClubService.createFanClubAppeal(widget.artistId, trimmed);
      if (!mounted) {
        return;
      }
      await AppAlert.show(
        context,
        title: 'Defesa enviada',
        message: 'A moderação vai analisar seu pedido de retorno.',
      );
      if (mounted) {
        handleBack();
      }
    } on ApiError catch (error) {
      if (mounted) {
        setState(() => _fieldError = error.message);
      }
    } catch (error) {
      if (mounted) {
        setState(() => _fieldError = error.toString());
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
    return Scaffold(
      backgroundColor: colors.background,
      body: SafeArea(
        child: Column(
          children: [
            ProfileScreenHeader(
              title: 'Defender retorno',
              onBack: handleBack,
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                children: [
                  Text(
                    'Explique para a moderação por que você acredita que deve voltar para a comunidade e o que mudou desde a expulsão.',
                    style: TextStyle(
                      fontSize: 14,
                      height: 20 / 14,
                      color: colors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 16),
                  FanClubDefendReturnReasonCard(reason: _reason ?? ''),
                  const SizedBox(height: 20),
                  FanClubDefendReturnField(
                    controller: _controller,
                    errorText: _fieldError,
                    onChanged: (_) {
                      setState(() => _fieldError = null);
                    },
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: AppButton(
                label: _busy ? 'Enviando...' : 'Enviar defesa',
                variant: AppButtonVariant.dark,
                disabled: !canSubmit,
                loading: _busy,
                onPressed: handleSubmit,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
