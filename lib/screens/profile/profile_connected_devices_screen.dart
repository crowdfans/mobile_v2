import 'package:crowdfans/components/buttons/app_button.dart';
import 'package:crowdfans/components/profile/connected_device_row.dart';
import 'package:crowdfans/components/profile/profile_screen_header.dart';
import 'package:crowdfans/components/profile/profile_state.dart';
import 'package:crowdfans/constants/theme.dart';
import 'package:crowdfans/services/user_session_service.dart';
import 'package:crowdfans/utils/app_alert.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Dispositivos conectados (CF-216) — lista real via CF-266 `/me/sessions`.
class ProfileConnectedDevicesScreen extends StatefulWidget {
  const ProfileConnectedDevicesScreen({super.key});

  @override
  State<ProfileConnectedDevicesScreen> createState() =>
      _ProfileConnectedDevicesScreenState();
}

class _ProfileConnectedDevicesScreenState
    extends State<ProfileConnectedDevicesScreen> {
  var _sessions = <ConnectedDeviceSession>[];
  var _loading = true;
  var _busy = false;
  String? _error;

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
      await UserSessionService.syncCurrentSession();
      final sessions = await UserSessionService.listSessions();
      if (!mounted) {
        return;
      }
      setState(() {
        _sessions = sessions;
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

  Future<void> handleDisconnect(ConnectedDeviceSession session) async {
    final ok = await AppAlert.confirm(
      context,
      title: 'Desconectar',
      message: 'Encerrar a sessão em ${session.name}?',
      confirmLabel: 'Desconectar',
    );
    if (!ok) {
      return;
    }
    setState(() => _busy = true);
    try {
      await UserSessionService.revokeSession(session.id);
      await handleLoad();
    } catch (error) {
      if (!mounted) {
        return;
      }
      setState(() {
        _busy = false;
        _error = error.toString();
      });
      return;
    }
    if (mounted) {
      setState(() => _busy = false);
    }
  }

  Future<void> handleDisconnectOthers() async {
    final ok = await AppAlert.confirm(
      context,
      title: 'Desconectar outros',
      message: 'Encerrar todas as sessões exceto este dispositivo?',
      confirmLabel: 'Desconectar',
    );
    if (!ok) {
      return;
    }
    setState(() => _busy = true);
    try {
      await UserSessionService.revokeOtherSessions();
      await handleLoad();
    } catch (error) {
      if (!mounted) {
        return;
      }
      setState(() {
        _busy = false;
        _error = error.toString();
      });
      return;
    }
    if (mounted) {
      setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = CrowdFansTheme.of(context);
    final count = _sessions.length;
    return Scaffold(
      backgroundColor: colors.background,
      body: SafeArea(
        child: Column(
          children: [
            ProfileScreenHeader(
              title: 'Dispositivos conectados',
              onBack: () => context.pop(),
            ),
            Expanded(
              child: _loading
                  ? const ProfileState(loading: true)
                  : ListView(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                      children: [
                        Text(
                          'Sessões ativas na sua conta',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                            color: colors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Revise os aparelhos em que sua conta está logada e encerre '
                          'qualquer acesso que você não reconheça.',
                          style: TextStyle(
                            fontSize: 14,
                            height: 1.45,
                            color: colors.textSecondary,
                          ),
                        ),
                        if (_error != null) ...[
                          const SizedBox(height: 12),
                          Text(
                            _error!,
                            style: TextStyle(
                              fontSize: 13,
                              color: colors.danger,
                            ),
                          ),
                        ],
                        const SizedBox(height: 16),
                        Text.rich(
                          TextSpan(
                            style: TextStyle(
                              fontSize: 15,
                              color: colors.textPrimary,
                            ),
                            children: [
                              TextSpan(
                                text: '$count',
                                style: const TextStyle(
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              TextSpan(
                                text:
                                    ' dispositivo${count == 1 ? '' : 's'} conectado${count == 1 ? '' : 's'}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 8),
                        if (_sessions.isEmpty)
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 24),
                            child: Text(
                              'Nenhuma sessão ativa encontrada. Abra o app '
                              'novamente para registrar este aparelho.',
                              style: TextStyle(
                                fontSize: 14,
                                height: 1.4,
                                color: colors.textSecondary,
                              ),
                            ),
                          ),
                        for (final session in _sessions) ...[
                          ConnectedDeviceRow(
                            session: session,
                            onDisconnect: session.isCurrent || _busy
                                ? null
                                : () => handleDisconnect(session),
                          ),
                          Divider(height: 1, color: colors.border),
                        ],
                        const SizedBox(height: 16),
                        DecoratedBox(
                          decoration: BoxDecoration(
                            color: AppPalette.purple50,
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(14),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Dica de segurança',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700,
                                    color: colors.primary,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  'Se você trocou a senha recentemente, desconectar os '
                                  'outros dispositivos ajuda a encerrar sessões antigas '
                                  'imediatamente.',
                                  style: TextStyle(
                                    fontSize: 13,
                                    height: 1.4,
                                    color: colors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              child: AppButton(
                label: _busy
                    ? 'Atualizando...'
                    : 'Desconectar todos menos este',
                disabled: _busy ||
                    _loading ||
                    _sessions.isEmpty ||
                    _sessions.every((item) => item.isCurrent),
                onPressed: handleDisconnectOthers,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
