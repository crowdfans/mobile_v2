import 'package:crowdfans/components/buttons/app_button.dart';
import 'package:crowdfans/components/fan_club/fan_club_moderation_card.dart';
import 'package:crowdfans/components/input/app_text_field.dart';
import 'package:crowdfans/components/profile/profile_screen_header.dart';
import 'package:crowdfans/components/profile/profile_state.dart';
import 'package:crowdfans/constants/pages.dart';
import 'package:crowdfans/constants/theme.dart';
import 'package:crowdfans/services/fan_club_service.dart';
import 'package:crowdfans/utils/app_alert.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Moderação: strikes, expulsões e apelações (dono/moderador).
class FanClubModerationScreen extends StatefulWidget {
  const FanClubModerationScreen({super.key, required this.artistId});

  final String artistId;

  @override
  State<FanClubModerationScreen> createState() =>
      _FanClubModerationScreenState();
}

class _FanClubModerationScreenState extends State<FanClubModerationScreen> {
  var _strikes = <FanClubStrike>[];
  var _expulsions = <FanClubExpulsion>[];
  var _appeals = <FanClubAppeal>[];
  var _loading = true;
  var _saving = false;
  var _targetUid = '';
  var _reason = '';
  var _formNonce = 0;

  @override
  void initState() {
    super.initState();
    handleLoad();
  }

  Future<void> handleLoad() async {
    if (widget.artistId.trim().isEmpty) {
      setState(() => _loading = false);
      return;
    }
    setState(() => _loading = true);
    try {
      final strikes = await FanClubService.listFanClubStrikes(widget.artistId);
      final expulsions = await FanClubService.listFanClubExpulsions(
        widget.artistId,
      );
      final appeals = await FanClubService.listFanClubAppeals(widget.artistId);
      if (!mounted) {
        return;
      }
      setState(() {
        _strikes = strikes;
        _expulsions = expulsions;
        _appeals = appeals;
        _loading = false;
      });
    } catch (_) {
      if (!mounted) {
        return;
      }
      setState(() => _loading = false);
      await AppAlert.show(
        context,
        title: 'Moderação',
        message: 'Não foi possível carregar a moderação.',
      );
    }
  }

  void handleBack() {
    if (context.canPop()) {
      context.pop();
      return;
    }
    context.go(Pages.clubs);
  }

  Future<void> handleStrike() async {
    if (_targetUid.trim().isEmpty || _reason.trim().length < 8) {
      await AppAlert.show(
        context,
        title: 'Strike',
        message: 'Informe userUid e motivo (mín. 8 caracteres).',
      );
      return;
    }
    setState(() => _saving = true);
    try {
      await FanClubService.issueFanClubStrike(
        widget.artistId,
        _targetUid.trim(),
        _reason.trim(),
      );
      if (!mounted) {
        return;
      }
      setState(() {
        _reason = '';
        _formNonce++;
      });
      await handleLoad();
      if (mounted) {
        await AppAlert.show(
          context,
          title: 'Strike',
          message: 'Strike aplicado.',
        );
      }
    } catch (error) {
      if (mounted) {
        await AppAlert.show(
          context,
          title: 'Strike',
          message: error.toString(),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _saving = false);
      }
    }
  }

  Future<void> handleExpel() async {
    if (_targetUid.trim().isEmpty || _reason.trim().length < 8) {
      await AppAlert.show(
        context,
        title: 'Expulsão',
        message: 'Informe userUid e motivo (mín. 8 caracteres).',
      );
      return;
    }
    setState(() => _saving = true);
    try {
      await FanClubService.issueFanClubExpulsion(
        widget.artistId,
        _targetUid.trim(),
        _reason.trim(),
      );
      if (!mounted) {
        return;
      }
      setState(() {
        _reason = '';
        _formNonce++;
      });
      await handleLoad();
      if (mounted) {
        await AppAlert.show(
          context,
          title: 'Expulsão',
          message: 'Membro expulso.',
        );
      }
    } catch (error) {
      if (mounted) {
        await AppAlert.show(
          context,
          title: 'Expulsão',
          message: error.toString(),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _saving = false);
      }
    }
  }

  Future<void> handleApproveAppeal(FanClubAppeal appeal) async {
    try {
      await FanClubService.approveFanClubAppeal(
        widget.artistId,
        appeal.appealId,
      );
      await handleLoad();
    } catch (error) {
      if (mounted) {
        await AppAlert.show(
          context,
          title: 'Apelações',
          message: error.toString(),
        );
      }
    }
  }

  Future<void> handleRejectAppeal(FanClubAppeal appeal) async {
    try {
      await FanClubService.rejectFanClubAppeal(
        widget.artistId,
        appeal.appealId,
      );
      await handleLoad();
    } catch (error) {
      if (mounted) {
        await AppAlert.show(
          context,
          title: 'Apelações',
          message: error.toString(),
        );
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
            ProfileScreenHeader(title: 'Moderação', onBack: handleBack),
            Expanded(
              child: _loading
                  ? const ProfileState(loading: true)
                  : ListView(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 36),
                      children: [
                        Text(
                          'Aplicar ação',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: colors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 12),
                        AppTextField(
                          key: ValueKey('uid-$_formNonce'),
                          label: 'userUid do fã',
                          hint: 'UUID',
                          onChanged: (value) => _targetUid = value,
                        ),
                        const SizedBox(height: 12),
                        AppTextField(
                          key: ValueKey('reason-$_formNonce'),
                          label: 'Motivo',
                          hint: 'Descreva o motivo',
                          maxLines: 3,
                          onChanged: (value) => _reason = value,
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: AppButton(
                                label: 'Strike',
                                variant: AppButtonVariant.outline,
                                loading: _saving,
                                onPressed: handleStrike,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: AppButton(
                                label: 'Expulsar',
                                variant: AppButtonVariant.outline,
                                loading: _saving,
                                onPressed: handleExpel,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        Text(
                          'Apelações pendentes',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: colors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 10),
                        if (_appeals.isEmpty)
                          Text(
                            'Nenhuma apelação pendente.',
                            style: TextStyle(
                              fontSize: 13,
                              color: colors.textTertiary,
                            ),
                          )
                        else
                          for (final appeal in _appeals) ...[
                            FanClubModerationCard(
                              title: appeal.displayName,
                              subtitle: appeal.handle,
                              body: appeal.defense,
                              onApprove: () => handleApproveAppeal(appeal),
                              onReject: () => handleRejectAppeal(appeal),
                            ),
                            const SizedBox(height: 10),
                          ],
                        const SizedBox(height: 14),
                        Text(
                          'Strikes',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: colors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 10),
                        if (_strikes.isEmpty)
                          Text(
                            'Nenhum strike.',
                            style: TextStyle(
                              fontSize: 13,
                              color: colors.textTertiary,
                            ),
                          )
                        else
                          for (final strike in _strikes) ...[
                            FanClubModerationCard(
                              title: strike.displayName,
                              subtitle:
                                  '${strike.handle} · chances restantes: ${strike.remainingChances}',
                              body: strike.reason,
                            ),
                            const SizedBox(height: 10),
                          ],
                        const SizedBox(height: 14),
                        Text(
                          'Expulsões',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: colors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 10),
                        if (_expulsions.isEmpty)
                          Text(
                            'Nenhuma expulsão.',
                            style: TextStyle(
                              fontSize: 13,
                              color: colors.textTertiary,
                            ),
                          )
                        else
                          for (final item in _expulsions) ...[
                            FanClubModerationCard(
                              title: item.displayName,
                              subtitle: item.handle,
                              body: item.reason,
                            ),
                            const SizedBox(height: 10),
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
