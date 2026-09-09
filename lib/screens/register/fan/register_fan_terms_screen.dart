import 'package:crowdfans/components/buttons/app_button.dart';
import 'package:crowdfans/components/register/register_fan_scaffold.dart';
import 'package:crowdfans/components/register/register_step_header.dart';
import 'package:crowdfans/components/register/register_terms_checkbox.dart';
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

  String resolveDisplayName() {
    final form = ref.read(fanRegisterProvider);
    for (final value in [form.name, form.username, form.email]) {
      final trimmed = value.trim();
      if (trimmed.isNotEmpty) {
        return trimmed;
      }
    }
    return 'CrowdFans User';
  }

  void handleOpenTerms() {
    // Documentos legais ainda não têm URL no app (igual ao Expo).
  }

  void handleOpenPrivacy() {
    // Documentos legais ainda não têm URL no app (igual ao Expo).
  }

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
    if (!isEmailValid(email)) {
      await AppAlert.show(
        context,
        title: 'Cadastro',
        message: 'Informe um e-mail válido antes de continuar.',
      );
      return;
    }
    if (!isStrongPassword(form.password)) {
      await AppAlert.show(
        context,
        title: 'Cadastro',
        message: 'Defina uma senha forte antes de continuar.',
      );
      return;
    }
    setState(() => _submitting = true);
    try {
      if (FirebaseService.auth.currentUser != null) {
        await FirebaseService.auth.signOut();
      }
      final displayName = resolveDisplayName();
      final credential = await FirebaseService.auth
          .createUserWithEmailAndPassword(
            email: email,
            password: form.password,
          );
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
      var sessionOk = await ref
          .read(authSessionProvider.notifier)
          .refreshSession();
      if (!sessionOk) {
        await AuthService.loginBackendWithFirebaseToken(token);
        await AuthService.verifyBackendFirebaseToken(token);
        sessionOk = await ref
            .read(authSessionProvider.notifier)
            .refreshSession();
      }
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
        key: const Key('register-terms-submit'),
        label: _submitting ? 'Criando conta...' : 'Aceitar e Criar Conta',
        disabled: !_accepted,
        loading: _submitting,
        onPressed: handleSubmit,
      ),
      child: ListView(
        children: [
          const RegisterStepHeader(
            title: 'Antes de começar',
            subtitle: 'Para criar sua conta e garantir uma experiência segura e transparente para todos na Crowd Fans, precisamos que você leia e aceite nossos documentos legais.',
          ),
          const SizedBox(height: 12),
          Text(
            'Eles explicam como nossa plataforma funciona, seus direitos e suas responsabilidades como usuário, tá bom?',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 15,
              height: 22 / 15,
              color: colors.textSecondary,
            ),
          ),
          const SizedBox(height: 32),
          AppButton(
            label: 'Termos de Uso',
            onPressed: handleOpenTerms,
            variant: AppButtonVariant.outline,
          ),
          const SizedBox(height: 14),
          AppButton(
            label: 'Política de Privacidade',
            onPressed: handleOpenPrivacy,
            variant: AppButtonVariant.outline,
          ),
          const SizedBox(height: 14),
          RegisterTermsCheckbox(
            accepted: _accepted,
            onToggle: () => setState(() => _accepted = !_accepted),
          ),
        ],
      ),
    );
  }
}
