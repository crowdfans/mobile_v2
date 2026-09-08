import 'package:crowdfans/components/buttons/app_button.dart';
import 'package:crowdfans/components/register/register_fan_scaffold.dart';
import 'package:crowdfans/constants/pages.dart';
import 'package:crowdfans/constants/theme.dart';
import 'package:crowdfans/services/auth_service.dart';
import 'package:crowdfans/services/firebase_phone_auth_service.dart';
import 'package:crowdfans/services/firebase_service.dart';
import 'package:crowdfans/state/auth_session.dart';
import 'package:crowdfans/state/fan_register_store.dart';
import 'package:crowdfans/utils/app_alert.dart';
import 'package:crowdfans/utils/email_utils.dart';
import 'package:crowdfans/utils/password_util.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class RegisterFanTermsScreen extends ConsumerStatefulWidget {
  const RegisterFanTermsScreen({super.key});

  @override
  ConsumerState<RegisterFanTermsScreen> createState() =>
      _RegisterFanTermsScreenState();
}

class _RegisterFanTermsScreenState
    extends ConsumerState<RegisterFanTermsScreen> {
  bool _accepted = false;
  bool _submitting = false;

  Future<void> handleSubmit() async {
    final form = ref.read(fanRegisterProvider);
    if (!_accepted || _submitting) {
      return;
    }
    if (!form.phoneVerified) {
      await AppAlert.show(
        context,
        title: 'Cadastro',
        message: 'Confirme seu telefone antes de criar a conta.',
      );
      return;
    }
    final email = form.email.trim();
    if (!isEmailValid(email) || !isStrongPassword(form.password)) {
      await AppAlert.show(
        context,
        title: 'Cadastro',
        message: 'Revise e-mail e senha antes de continuar.',
      );
      return;
    }
    setState(() => _submitting = true);
    try {
      if (FirebaseService.auth.currentUser != null) {
        await FirebaseService.auth.signOut();
      }
      final credential = await FirebaseService.auth
          .createUserWithEmailAndPassword(
            email: email,
            password: form.password,
          );
      final displayName = form.name.trim().isNotEmpty
          ? form.name.trim()
          : form.username;
      await credential.user?.updateDisplayName(displayName);
      final token = await credential.user?.getIdToken(true);
      if (token == null) {
        throw StateError('token vazio');
      }
      await AuthService.registerFan(
        email: email,
        token: token,
        displayName: displayName,
        phone: FirebasePhoneAuthService.formatPhoneNumberE164(
          form.phoneCountryCode,
          form.phone,
        ),
        phoneVerified: form.phoneVerified,
      );
      await ref.read(authSessionProvider.notifier).refreshSession();
      if (mounted) {
        context.go(Pages.registerFanSuccess);
      }
    } catch (error) {
      if (mounted) {
        await AppAlert.show(
          context,
          title: 'Falha no cadastro',
          message: error.toString(),
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
    return RegisterFanScaffold(
      onBack: () => context.pop(),
      footer: AppButton(
        label: _submitting ? 'Criando conta...' : 'Aceitar e Criar Conta',
        disabled: !_accepted,
        loading: _submitting,
        onPressed: handleSubmit,
      ),
      child: ListView(
        children: [
          const SizedBox(height: 32),
          Text(
            'Antes de começar',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w800,
              color: colors.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Para criar sua conta e garantir uma experiência segura e transparente para todos na Crowd Fans, precisamos que você leia e aceite nossos documentos legais.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 15, color: colors.textSecondary),
          ),
          CheckboxListTile(
            value: _accepted,
            onChanged: (value) => setState(() => _accepted = value ?? false),
            title: Text(
              'Ao prosseguir, você está de acordo com os Termos de Uso e a Política de Privacidade da Crowd Fans.',
              style: TextStyle(color: colors.textPrimary, fontSize: 14),
            ),
            controlAffinity: ListTileControlAffinity.leading,
          ),
        ],
      ),
    );
  }
}
