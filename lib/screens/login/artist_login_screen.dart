import 'package:crowdfans/constants/pages.dart';
import 'package:crowdfans/constants/theme.dart';
import 'package:crowdfans/services/auth_service.dart';
import 'package:crowdfans/services/firebase_service.dart';
import 'package:crowdfans/state/auth_session.dart';
import 'package:crowdfans/components/login/credentials_form.dart';
import 'package:crowdfans/components/login/login_label.dart';
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

  Future<void> _login() async {
    final email = _email.trim();
    if (email.isEmpty || _password.isEmpty) {
      _alert('Login', 'Informe e-mail e senha.');
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
      if (!ok) {
        _alert(
          'Login',
          'Conta autenticada no Firebase, mas o CrowdFans ainda não validou a sessão. Tente de novo.',
        );
        return;
      }
      if (ref.read(authSessionProvider).profile?.isArtist != true) {
        await ref.read(authSessionProvider.notifier).logout();
        _alert(
          'Login Artista',
          'Esta conta é de superfã. Entre pela área de login de superfã.',
        );
        return;
      }
      if (mounted) {
        context.go(Pages.home);
      }
    } catch (error) {
      _alert('Login', mapLoginError(error));
    }
  }

  void _alert(String title, String message) {
    if (!mounted) {
      return;
    }
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = CrowdFansTheme.of(context);
    return Scaffold(
      backgroundColor: colors.background,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(24, 0, 24, 20),
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: IconButton(
                onPressed: () => context.go(Pages.presentation),
                icon: Icon(Icons.arrow_back, color: colors.icon),
              ),
            ),
            const SizedBox(height: 48),
            const LoginLabel(isArtist: true),
            Text(
              'Artista',
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
              onSubmit: _login,
              onForgotPassword: () => _alert(
                'Recuperar senha',
                'Informe o e-mail da conta. O envio do link entra no próximo corte da migração.',
              ),
            ),
            const SizedBox(height: 34),
            Center(
              child: TextButton(
                onPressed: () => context.push(Pages.registerArtist),
                style: TextButton.styleFrom(
                  backgroundColor: colors.surfaceAlt,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 22, vertical: 10),
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
      ),
    );
  }
}
