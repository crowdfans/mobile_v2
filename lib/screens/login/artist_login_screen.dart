import 'package:crowdfans/components/login/credentials_form.dart';
import 'package:crowdfans/components/login/login_label.dart';
import 'package:crowdfans/components/login/login_layout.dart';
import 'package:crowdfans/constants/pages.dart';
import 'package:crowdfans/constants/theme.dart';
import 'package:crowdfans/services/auth_service.dart';
import 'package:crowdfans/services/firebase_service.dart';
import 'package:crowdfans/services/profile_security_service.dart';
import 'package:crowdfans/state/auth_session.dart';
import 'package:crowdfans/utils/app_alert.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class ArtistLoginScreen extends ConsumerStatefulWidget {
  const ArtistLoginScreen({super.key});

  @override
  ConsumerState<ArtistLoginScreen> createState() => _ArtistLoginScreenState();
}

class _ArtistLoginScreenState extends ConsumerState<ArtistLoginScreen> {
  String _email = '';
  String _password = '';
  bool _loading = false;

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
    setState(() => _loading = true);
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
      if (ref.read(authSessionProvider).profile?.isArtist != true) {
        await ref.read(authSessionProvider.notifier).logout();
        if (!mounted) {
          return;
        }
        await AppAlert.show(
          context,
          title: 'Login Artista',
          message:
              'Esta conta é de superfã. Entre pela área de login de superfã.',
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
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  Future<void> handleForgotPassword() async {
    final email = _email.trim();
    if (email.isEmpty) {
      await AppAlert.show(
        context,
        title: 'Recuperar senha',
        message: 'Informe o e-mail da conta no campo acima e toque novamente.',
      );
      return;
    }
    try {
      await ProfileSecurityService.requestPasswordReset(email);
      if (mounted) {
        await AppAlert.show(
          context,
          title: 'Recuperar senha',
          message: 'Se existir uma conta com esse e-mail, enviamos um link para redefinir a senha.',
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

  void handleCreateAccount() {
    context.push(Pages.registerArtist);
  }

  @override
  Widget build(BuildContext context) {
    final colors = CrowdFansTheme.of(context);
    final heroHeight = MediaQuery.sizeOf(context).height * 0.15;
    return LoginLayout(
      onBack: () => context.go(Pages.presentation),
      child: Column(
        children: [
          SizedBox(height: heroHeight),
          const LoginLabel(isArtist: true),
          Text(
            'Artista',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 60,
              height: 64 / 60,
              fontWeight: FontWeight.w800,
              color: colors.textPrimary,
            ),
          ),
          const SizedBox(height: 60),
          CredentialsForm(
            email: _email,
            password: _password,
            loading: _loading,
            onEmailChanged: (value) => _email = value,
            onPasswordChanged: (value) => _password = value,
            onSubmit: handleLogin,
            onForgotPassword: handleForgotPassword,
          ),
          const SizedBox(height: 34),
          Center(
            child: TextButton(
              key: const Key('login-create-account'),
              onPressed: handleCreateAccount,
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
        ],
      ),
    );
  }
}
