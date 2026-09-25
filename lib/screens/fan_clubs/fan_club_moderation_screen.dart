import 'package:crowdfans/components/buttons/app_button.dart';
import 'package:crowdfans/components/fan_club/fan_club_moderation_card.dart';
import 'package:crowdfans/components/fan_club/fan_club_moderation_search_field.dart';
import 'package:crowdfans/components/fan_club/fan_club_moderation_section_header.dart';
import 'package:crowdfans/components/fan_club/fan_club_moderation_tab_bar.dart';
import 'package:crowdfans/components/input/app_text_field.dart';
import 'package:crowdfans/components/profile/profile_screen_header.dart';
import 'package:crowdfans/components/profile/profile_state.dart';
import 'package:crowdfans/constants/pages.dart';
import 'package:crowdfans/constants/theme.dart';
import 'package:crowdfans/mocks/cf_temp_mocks.dart';
import 'package:crowdfans/services/fan_club_service.dart';
import 'package:crowdfans/utils/app_alert.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Painel de moderação: Contestações, Avisos e Expulsos.
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
  String? _error;
  var _tab = 'contestacoes';
  var _query = '';
  String? _actingAppealId;
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
      setState(() {
        _loading = false;
        _error = 'Fã-clube inválido.';
      });
      return;
    }
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      var strikes = await FanClubService.listFanClubStrikes(widget.artistId);
      var expulsions = await FanClubService.listFanClubExpulsions(
        widget.artistId,
      );
      var appeals = await FanClubService.listFanClubAppeals(widget.artistId);
      if (kUseCfTempMocks &&
          CfTempMocks.useModerationPanelFixtures &&
          appeals.isEmpty &&
          strikes.isEmpty &&
          expulsions.isEmpty) {
        appeals = Cf199ModerationPanelFixtures.appeals();
        strikes = Cf199ModerationPanelFixtures.strikes();
        expulsions = Cf199ModerationPanelFixtures.expulsions();
      }
      if (!mounted) {
        return;
      }
      setState(() {
        _strikes = strikes;
        _expulsions = expulsions;
        _appeals = appeals;
        _loading = false;
        _error = null;
      });
    } catch (_) {
      if (!mounted) {
        return;
      }
      if (kUseCfTempMocks && CfTempMocks.useModerationPanelFixtures) {
        setState(() {
          _appeals = Cf199ModerationPanelFixtures.appeals();
          _strikes = Cf199ModerationPanelFixtures.strikes();
          _expulsions = Cf199ModerationPanelFixtures.expulsions();
          _loading = false;
          _error = null;
        });
        return;
      }
      setState(() {
        _loading = false;
        _error = 'Não foi possível carregar a moderação.';
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

  bool matchesQuery(String haystack) {
    final q = _query.trim().toLowerCase();
    if (q.isEmpty) {
      return true;
    }
    return haystack.toLowerCase().contains(q);
  }

  List<FanClubAppeal> get filteredAppeals => [
    for (final appeal in _appeals)
      if (matchesQuery(
        '${appeal.displayName} ${appeal.handle} ${appeal.defense}',
      ))
        appeal,
  ];

  List<FanClubStrike> get filteredStrikes => [
    for (final strike in _strikes)
      if (matchesQuery(
        '${strike.displayName} ${strike.handle} ${strike.reason}',
      ))
        strike,
  ];

  List<FanClubExpulsion> get filteredExpulsions => [
    for (final item in _expulsions)
      if (matchesQuery('${item.displayName} ${item.handle} ${item.reason}'))
        item,
  ];

  Future<void> handleStrike() async {
    if (_targetUid.trim().isEmpty || _reason.trim().length < 8) {
      await AppAlert.show(
        context,
        title: 'Aviso',
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
          title: 'Aviso',
          message: 'Aviso registrado.',
        );
      }
    } catch (error) {
      if (mounted) {
        await AppAlert.show(
          context,
          title: 'Aviso',
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
    if (_actingAppealId != null) {
      return;
    }
    setState(() => _actingAppealId = appeal.appealId);
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
          title: 'Contestações',
          message: error.toString(),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _actingAppealId = null);
      }
    }
  }

  Future<void> handleRejectAppeal(FanClubAppeal appeal) async {
    if (_actingAppealId != null) {
      return;
    }
    setState(() => _actingAppealId = appeal.appealId);
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
          title: 'Contestações',
          message: error.toString(),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _actingAppealId = null);
      }
    }
  }

  Widget buildApplyForm({
    required String title,
    required String actionLabel,
    required VoidCallback onSubmit,
  }) {
    final colors = CrowdFansTheme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 20),
        Text(
          title,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w800,
            color: colors.textPrimary,
          ),
        ),
        const SizedBox(height: 12),
        AppTextField(
          key: ValueKey('uid-$_formNonce-$title'),
          label: 'userUid do fã',
          hint: 'UUID',
          onChanged: (value) => _targetUid = value,
        ),
        const SizedBox(height: 12),
        AppTextField(
          key: ValueKey('reason-$_formNonce-$title'),
          label: 'Motivo',
          hint: 'Descreva o motivo e a consequência',
          maxLines: 3,
          onChanged: (value) => _reason = value,
        ),
        const SizedBox(height: 12),
        AppButton(
          label: actionLabel,
          loading: _saving,
          onPressed: onSubmit,
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = CrowdFansTheme.of(context);
    final appeals = filteredAppeals;
    final strikes = filteredStrikes;
    final expulsions = filteredExpulsions;
    return Scaffold(
      backgroundColor: colors.background,
      body: SafeArea(
        child: Column(
          children: [
            ProfileScreenHeader(
              title: 'Painel de moderação',
              onBack: handleBack,
            ),
            Expanded(
              child: _loading
                  ? const ProfileState(loading: true)
                  : RefreshIndicator(
                      onRefresh: handleLoad,
                      child: ListView(
                        padding: const EdgeInsets.fromLTRB(16, 8, 16, 36),
                        children: [
                          FanClubModerationSearchField(
                            initialValue: _query,
                            onChanged: (value) =>
                                setState(() => _query = value),
                          ),
                          const SizedBox(height: 14),
                          FanClubModerationTabBar(
                            selectedId: _tab,
                            contestationCount: _appeals.length,
                            warningCount: _strikes.length,
                            expulsionCount: _expulsions.length,
                            onSelected: (id) => setState(() => _tab = id),
                          ),
                          const SizedBox(height: 18),
                          if (_error != null)
                            ProfileState(
                              title: 'Não foi possível carregar',
                              message: _error,
                              actionLabel: 'Tentar de novo',
                              onAction: handleLoad,
                            )
                          else if (_tab == 'contestacoes') ...[
                            FanClubModerationSectionHeader(
                              title: 'Pedidos para voltar',
                              count: appeals.length,
                            ),
                            const SizedBox(height: 12),
                            // Vazio do print: só o cabeçalho com badge 0 (sem card extra).
                            if (appeals.isEmpty && _query.trim().isNotEmpty)
                              ProfileState(
                                title: 'Nenhum resultado',
                                message: 'Nenhum resultado para a busca.',
                              )
                            else if (appeals.isNotEmpty)
                              for (final appeal in appeals) ...[
                                FanClubModerationCard(
                                  title: appeal.displayName,
                                  subtitle: appeal.handle.isEmpty
                                      ? ''
                                      : appeal.handle.startsWith('fan/')
                                      ? appeal.handle
                                      : 'fan/${appeal.handle}',
                                  photoUrl: appeal.photoUrl,
                                  statusLabel: 'Defesa enviada',
                                  body: appeal.defense,
                                  busy: _actingAppealId == appeal.appealId,
                                  onApprove: () =>
                                      handleApproveAppeal(appeal),
                                  onReject: () => handleRejectAppeal(appeal),
                                ),
                                const SizedBox(height: 12),
                              ],
                          ] else if (_tab == 'avisos') ...[
                            FanClubModerationSectionHeader(
                              title: 'Avisos registrados',
                              count: strikes.length,
                            ),
                            const SizedBox(height: 12),
                            if (strikes.isEmpty)
                              ProfileState(
                                title: 'Nenhum aviso',
                                message: _query.trim().isEmpty
                                    ? 'Nenhum aviso neste fã-clube.'
                                    : 'Nenhum resultado para a busca.',
                              )
                            else
                              for (final strike in strikes) ...[
                                FanClubModerationCard(
                                  title: strike.displayName,
                                  subtitle: strike.handle,
                                  photoUrl: strike.photoUrl,
                                  severityLabel:
                                      'Aviso · chances restantes: ${strike.remainingChances}',
                                  body: strike.reason,
                                ),
                                const SizedBox(height: 12),
                              ],
                            buildApplyForm(
                              title: 'Registrar aviso',
                              actionLabel: 'Aplicar aviso',
                              onSubmit: handleStrike,
                            ),
                          ] else ...[
                            FanClubModerationSectionHeader(
                              title: 'Membros expulsos',
                              count: expulsions.length,
                            ),
                            const SizedBox(height: 12),
                            if (expulsions.isEmpty)
                              ProfileState(
                                title: 'Nenhuma expulsão',
                                message: _query.trim().isEmpty
                                    ? 'Nenhum membro expulso neste fã-clube.'
                                    : 'Nenhum resultado para a busca.',
                              )
                            else
                              for (final item in expulsions) ...[
                                FanClubModerationCard(
                                  title: item.displayName,
                                  subtitle: item.handle,
                                  photoUrl: item.photoUrl,
                                  severityLabel: 'Expulso',
                                  body: item.reason,
                                ),
                                const SizedBox(height: 12),
                              ],
                            buildApplyForm(
                              title: 'Expulsar membro',
                              actionLabel: 'Expulsar',
                              onSubmit: handleExpel,
                            ),
                          ],
                        ],
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
