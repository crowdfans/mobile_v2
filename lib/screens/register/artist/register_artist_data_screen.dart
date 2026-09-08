import 'package:crowdfans/components/buttons/app_button.dart';
import 'package:crowdfans/components/input/app_text_field.dart';
import 'package:crowdfans/components/register/register_fan_scaffold.dart';
import 'package:crowdfans/constants/pages.dart';
import 'package:crowdfans/constants/theme.dart';
import 'package:crowdfans/services/artist_register_service.dart';
import 'package:crowdfans/services/otp_service.dart';
import 'package:crowdfans/state/artist_register_store.dart';
import 'package:crowdfans/state/auth_session.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// Nome, username e senha — `POST /register/artist`.
class RegisterArtistDataScreen extends ConsumerStatefulWidget {
  const RegisterArtistDataScreen({super.key});

  @override
  ConsumerState<RegisterArtistDataScreen> createState() =>
      _RegisterArtistDataScreenState();
}

class _RegisterArtistDataScreenState
    extends ConsumerState<RegisterArtistDataScreen> {
  String _error = '';
  bool _loading = false;

  bool isFormValid({
    required String name,
    required String username,
    required String password,
    required String confirmPassword,
  }) {
    return name.trim().isNotEmpty &&
        username.trim().length >= 3 &&
        password.length >= 8 &&
        password == confirmPassword;
  }

  Future<void> handleRegister() async {
    final form = ref.read(artistRegisterProvider);
    if (!isFormValid(
      name: form.name,
      username: form.username,
      password: form.password,
      confirmPassword: form.confirmPassword,
    )) {
      return;
    }
    setState(() {
      _loading = true;
      _error = '';
    });
    try {
      await ArtistRegisterService.registerArtist(
        email: form.email,
        password: form.password,
        displayName: form.name,
        phone: OtpService.formatPhoneE164(form.phoneCountryCode, form.phone),
        phoneVerified: form.phoneVerified,
      );
      await ref.read(authSessionProvider.notifier).refreshSession();
      if (mounted) {
        context.go(Pages.home);
      }
    } catch (error) {
      setState(() => _error = error.toString());
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = CrowdFansTheme.of(context);
    final form = ref.watch(artistRegisterProvider);
    final match =
        form.password.isNotEmpty &&
        form.confirmPassword.isNotEmpty &&
        form.password == form.confirmPassword;
    final mismatch =
        form.password.isNotEmpty &&
        form.confirmPassword.isNotEmpty &&
        form.password != form.confirmPassword;
    final valid = isFormValid(
      name: form.name,
      username: form.username,
      password: form.password,
      confirmPassword: form.confirmPassword,
    );

    return RegisterFanScaffold(
      onBack: () => context.pop(),
      footer: AppButton(
        label: 'Registrar',
        onPressed: handleRegister,
        disabled: !valid,
        loading: _loading,
      ),
      child: ListView(
        children: [
          const SizedBox(height: 40),
          Text(
            'Cadastrar',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: AuthAccentPalette.artist.end,
            ),
          ),
          Text(
            'Dados',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 44,
              fontWeight: FontWeight.w800,
              color: colors.textPrimary,
            ),
          ),
          const SizedBox(height: 40),
          if (_error.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Text(_error, style: TextStyle(color: colors.danger)),
            ),
          AppTextField(
            label: 'Nome',
            hint: 'João Silva',
            initialValue: form.name,
            textCapitalization: TextCapitalization.words,
            onChanged: (value) {
              ref
                  .read(artistRegisterProvider.notifier)
                  .setFields((current) => current.copyWith(name: value));
            },
          ),
          const SizedBox(height: 16),
          AppTextField(
            label: 'Username',
            hint: 'joao_silva',
            initialValue: form.username,
            helper: '3-20 caracteres, sem espaços',
            onChanged: (value) {
              ref
                  .read(artistRegisterProvider.notifier)
                  .setFields((current) => current.copyWith(username: value));
            },
          ),
          const SizedBox(height: 16),
          AppTextField(
            label: 'Senha',
            hint: '••••••••',
            obscureText: true,
            helper: 'Mínimo 8 caracteres',
            onChanged: (value) {
              ref
                  .read(artistRegisterProvider.notifier)
                  .setFields((current) => current.copyWith(password: value));
            },
          ),
          const SizedBox(height: 16),
          AppTextField(
            label: 'Confirmar Senha',
            hint: '••••••••',
            obscureText: true,
            helper: mismatch
                ? 'Senhas não coincidem'
                : (match ? 'Senhas coincidem ✓' : ''),
            helperColor: mismatch ? colors.danger : colors.textSecondary,
            onChanged: (value) {
              ref
                  .read(artistRegisterProvider.notifier)
                  .setFields(
                    (current) => current.copyWith(confirmPassword: value),
                  );
            },
          ),
        ],
      ),
    );
  }
}
