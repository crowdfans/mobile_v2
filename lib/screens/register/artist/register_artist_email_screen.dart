import 'package:crowdfans/components/buttons/app_button.dart';
import 'package:crowdfans/components/input/app_text_field.dart';
import 'package:crowdfans/components/register/register_fan_scaffold.dart';
import 'package:crowdfans/constants/pages.dart';
import 'package:crowdfans/constants/theme.dart';
import 'package:crowdfans/state/artist_register_store.dart';
import 'package:crowdfans/utils/email_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// E-mail do administrador da conta de artista.
class RegisterArtistEmailScreen extends ConsumerWidget {
  const RegisterArtistEmailScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = CrowdFansTheme.of(context);
    final email = ref.watch(artistRegisterProvider).email;
    return RegisterFanScaffold(
      onBack: () => context.pop(),
      footer: AppButton(
        label: 'Próximo',
        disabled: !isEmailValid(email),
        onPressed: () => context.push(Pages.registerArtistData),
      ),
      child: ListView(
        children: [
          const SizedBox(height: 32),
          Text(
            'Crie o acesso\ndo artista',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w800,
              color: colors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Use o e-mail principal que vai administrar seu perfil e sua comunidade.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16, color: colors.textSecondary),
          ),
          const SizedBox(height: 32),
          AppTextField(
            initialValue: email,
            hint: 'E-mail',
            keyboardType: TextInputType.emailAddress,
            onChanged: (value) {
              ref
                  .read(artistRegisterProvider.notifier)
                  .setFields(
                    (current) => current.copyWith(email: value.trim()),
                  );
            },
          ),
        ],
      ),
    );
  }
}
