import 'package:crowdfans/components/buttons/app_button.dart';
import 'package:crowdfans/components/profile/connected_device_row.dart';
import 'package:crowdfans/components/profile/profile_screen_header.dart';
import 'package:crowdfans/constants/theme.dart';
import 'package:crowdfans/mocks/cf_temp_mocks.dart';
import 'package:crowdfans/utils/app_alert.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Dispositivos conectados (CF-216).
///
/// Sem API de sessões ainda: lista local ilustrativa + ações com confirmação.
class ProfileConnectedDevicesScreen extends StatefulWidget {
  const ProfileConnectedDevicesScreen({super.key});

  @override
  State<ProfileConnectedDevicesScreen> createState() =>
      _ProfileConnectedDevicesScreenState();
}

class _ProfileConnectedDevicesScreenState
    extends State<ProfileConnectedDevicesScreen> {
  late List<ConnectedDeviceSession> _sessions;

  @override
  void initState() {
    super.initState();
    _sessions = kUseCfTempMocks && CfTempMocks.useSecuritySettingsFixtures
        ? Cf216ConnectedDevicesFixtures.sessions()
        : const [
            ConnectedDeviceSession(
              id: 'current',
              name: 'Este aparelho',
              platformLine: 'Crowd Fans App',
              location: 'Sessão atual',
              activity: 'Ativo agora',
              isCurrent: true,
            ),
          ];
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
    setState(() {
      _sessions = [for (final item in _sessions) if (item.id != session.id) item];
    });
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
    setState(() {
      _sessions = [for (final item in _sessions) if (item.isCurrent) item];
    });
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
              child: ListView(
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
                          style: const TextStyle(fontWeight: FontWeight.w800),
                        ),
                        TextSpan(
                          text:
                              ' dispositivo${count == 1 ? '' : 's'} conectado${count == 1 ? '' : 's'}',
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  for (final session in _sessions) ...[
                    ConnectedDeviceRow(
                      session: session,
                      onDisconnect: session.isCurrent
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
                label: 'Desconectar todos menos este',
                disabled: _sessions.every((item) => item.isCurrent),
                onPressed: handleDisconnectOthers,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
