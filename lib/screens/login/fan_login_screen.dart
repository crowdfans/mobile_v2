import 'package:crowdfans/components/login/credentials_form.dart';
import 'package:crowdfans/components/login/login_label.dart';
import 'package:crowdfans/components/login/login_layout.dart';
import 'package:crowdfans/constants/pages.dart';
import 'package:crowdfans/constants/theme.dart';
import 'package:crowdfans/services/api_config.dart';
import 'package:crowdfans/services/auth_service.dart';
import 'package:crowdfans/services/firebase_service.dart';
import 'package:crowdfans/services/profile_security_service.dart';
import 'package:crowdfans/state/auth_session.dart';
import 'package:crowdfans/utils/app_alert.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class FanLoginScreen extends ConsumerStatefulWidget {
  const FanLoginScreen({super.key});

  @override
  ConsumerState<FanLoginScreen> createState() => _FanLoginScreenState();
}

class _FanLoginScreenState extends ConsumerState<FanLoginScreen> {
  String _email = '';
  String _password = '';

  Future<void> handleLogin() async {
    final email = _email.trim();
    if (email.isEmpty || _password.isEmpty) {
      await AppAlert.show(
        context,
        title: 'Login',
        message: 'Informe e-mail e senha.',
      );
      return;
    }
    try {
      final credential = await FirebaseService.auth.signInWithEmailAndPassword(
        email: email,
        password: _password,
      );
      final token = await credential.user?.getIdToken();
      if (token == null) {
        throw StateError('token vazio');
      }
      await AuthService.loginBackendWithFirebaseToken(token);
      await AuthService.verifyBackendFirebaseToken(token);
      final ok = await ref.read(authSessionProvider.notifier).refreshSession();
      if (!mounted) {
        return;
      }
      if (!ok) {
        await AppAlert.show(
          context,
          title: 'Login',
          message: 'Conta autenticada no Firebase, mas o CrowdFans ainda não validou a sessão. Tente de novo.',
        );
        return;
      }
      if (ref.read(authSessionProvider).profile?.isArtist == true) {
        await ref.read(authSessionProvider.notifier).logout();
        if (!mounted) {
          return;
        }
        await AppAlert.show(
          context,
          title: 'Login Superfã',
          message:
              'Esta conta é de artista. Entre pela área de login de artista.',
        );
        return;
      }
      if (mounted) {
        context.go(Pages.home);
      }
    } catch (error) {
      if (mounted) {
        await AppAlert.show(
          context,
          title: 'Login',
          message: mapLoginError(error),
        );
      }
    }
  }

  Future<void> handleForgotPassword() async {
    final email = _email.trim();
    if (email.isEmpty) {
      await AppAlert.show(
        context,
        title: 'Recuperar senha',
        message: 'Informe o e-mail da conta para enviar o link.',
      );
      return;
    }
    try {
      await ProfileSecurityService.requestPasswordReset(email);
      if (mounted) {
        await AppAlert.show(
          context,
          title: 'Recuperar senha',
          message: 'Enviamos um e-mail com o link para redefinir a senha.',
        );
      }
    } catch (error) {
      if (mounted) {
        await AppAlert.show(
          context,
          title: 'Recuperar senha',
          message: mapLoginError(error),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = CrowdFansTheme.of(context);
    final debug = kDebugMode ? apiConfigDebug() : null;
    return LoginLayout(
      onBack: () => context.go(Pages.presentation),
      child: Column(
        children: [
          const SizedBox(height: 48),
          const LoginLabel(isArtist: false),
          Text(
            'Fan',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 60,
              height: 1.05,
              fontWeight: FontWeight.w800,
              color: colors.textPrimary,
            ),
          ),
          const SizedBox(height: 60),
          CredentialsForm(
            email: _email,
            password: _password,
            onEmailChanged: (value) => _email = value,
            onPasswordChanged: (value) => _password = value,
            onSubmit: handleLogin,
            onForgotPassword: handleForgotPassword,
          ),
          const SizedBox(height: 34),
          Center(
            child: TextButton(
              onPressed: () => context.push(Pages.registerFan),
              style: TextButton.styleFrom(
                backgroundColor: colors.surfaceAlt,
                padding: const EdgeInsets.symmetric(
                  horizontal: 22,
                  vertical: 10,
                ),
                shape: const StadiumBorder(),
              ),
              child: Text(
                'Não tem conta ainda? Crie aqui',
                style: TextStyle(fontSize: 12, color: colors.textPrimary),
              ),
            ),
          ),
          if (debug != null)
            Padding(
              padding: const EdgeInsets.only(top: 12),
              child: Text(
                'API ${debug.mode}: ${debug.baseUrl}',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 12, color: colors.textTertiary),
              ),
            ),
        ],
      ),
    );
  }
}
