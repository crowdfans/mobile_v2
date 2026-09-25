import 'package:crowdfans/components/profile/profile_screen_header.dart';
import 'package:crowdfans/components/profile/security_access_nav_row.dart';
import 'package:crowdfans/components/profile/security_protection_toggle_row.dart';
import 'package:crowdfans/constants/pages.dart';
import 'package:crowdfans/constants/theme.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _loginAlertsKey = 'security.loginAlertsEnabled';

/// Central Segurança e Login (CF-215) — proteção + acessos.
class ProfileSecurityScreen extends StatefulWidget {
  const ProfileSecurityScreen({super.key});

  @override
  State<ProfileSecurityScreen> createState() => _ProfileSecurityScreenState();
}

class _ProfileSecurityScreenState extends State<ProfileSecurityScreen> {
  var _twoFactor = false;
  var _loginAlerts = true;
  var _twoFactorReady = false;

  @override
  void initState() {
    super.initState();
    handleLoadPrefs();
  }

  Future<void> handleLoadPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) {
      return;
    }
    setState(() {
      _loginAlerts = prefs.getBool(_loginAlertsKey) ?? true;
      // 2FA só aparece ligado quando o fluxo completo existir.
      _twoFactor = false;
      _twoFactorReady = false;
    });
  }

  Future<void> handleToggleLoginAlerts(bool value) async {
    setState(() => _loginAlerts = value);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_loginAlertsKey, value);
  }

  void handleToggleTwoFactor(bool value) {
    // Sem endpoint completo: não simular proteção ativa.
    setState(() {
      _twoFactor = false;
      _twoFactorReady = false;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'A autenticação em dois fatores ainda não está disponível neste app.',
        ),
      ),
    );
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
              title: 'Segurança e Login',
              onBack: () => context.pop(),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
                children: [
                  Text(
                    'Proteção da conta',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: colors.textTertiary,
                    ),
                  ),
                  SecurityProtectionToggleRow(
                    title: 'Autenticação em dois fatores',
                    subtitle: 'Exigir código adicional ao entrar na conta.',
                    value: _twoFactor && _twoFactorReady,
                    onChanged: handleToggleTwoFactor,
                  ),
                  Divider(height: 1, color: colors.border),
                  SecurityProtectionToggleRow(
                    title: 'Alertas de novo login',
                    subtitle:
                        'Avisar quando detectarmos acesso em novo dispositivo.',
                    value: _loginAlerts,
                    onChanged: handleToggleLoginAlerts,
                  ),
                  const SizedBox(height: 28),
                  Text(
                    'Acesso',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: colors.textTertiary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  SecurityAccessNavRow(
                    title: 'Alterar senha',
                    subtitle: 'Atualize sua senha periodicamente.',
                    onTap: () => context.push(
                      '${Pages.profileSecurityCredentials}?mode=password',
                    ),
                  ),
                  SecurityAccessNavRow(
                    title: 'Trocar e-mail',
                    subtitle: 'Atualize o e-mail principal usado no login.',
                    // CF-165: página dedicada — NUNCA credentials?mode=email (abas).
                    onTap: () => context.push(Pages.profileChangeEmail),
                  ),
                  SecurityAccessNavRow(
                    title: 'Trocar telefone',
                    subtitle:
                        'Atualize o número usado em verificações de segurança.',
                    onTap: () => context.push(Pages.profileChangePhone),
                  ),
                  SecurityAccessNavRow(
                    title: 'Dispositivos conectados',
                    subtitle: 'Revise onde sua conta está logada.',
                    showDivider: false,
                    onTap: () => context.push(Pages.profileConnectedDevices),
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
