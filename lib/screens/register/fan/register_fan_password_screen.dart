import 'package:crowdfans/components/buttons/app_button.dart';
import 'package:crowdfans/components/input/app_text_field.dart';
import 'package:crowdfans/components/register/password_strength_meter.dart';
import 'package:crowdfans/components/register/register_fan_scaffold.dart';
import 'package:crowdfans/components/register/register_step_header.dart';
import 'package:crowdfans/constants/pages.dart';
import 'package:crowdfans/constants/theme.dart';
import 'package:crowdfans/state/fan_register_store.dart';
import 'package:crowdfans/utils/password_util.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class RegisterFanPasswordScreen extends ConsumerWidget {
  const RegisterFanPasswordScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = CrowdFansTheme.of(context);
    final form = ref.watch(fanRegisterProvider);
    final match =
        form.password.isNotEmpty && form.password == form.confirmPassword;
    final mismatch =
        form.confirmPassword.isNotEmpty &&
        form.password != form.confirmPassword;
    return RegisterFanScaffold(
      onBack: () => context.pop(),
      footer: AppButton(
        label: 'Próximo',
        disabled: !isStrongPassword(form.password) || !match,
        onPressed: () => context.push(Pages.registerFanName),
      ),
      child: ListView(
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        children: [
          const RegisterStepHeader(
            title: 'Crie sua senha',
            subtitle: 'Coloca uma senha forte, com letra maiúscula, número e caractere especial, viu?',
          ),
          const SizedBox(height: 32),
          AppTextField(
            label: 'Senha',
            hint: 'Senha',
            obscureText: true,
            initialValue: form.password,
            onChanged: (value) {
              ref
                  .read(fanRegisterProvider.notifier)
                  .setFields((current) => current.copyWith(password: value));
            },
          ),
          if (form.password.isNotEmpty) ...[
            const SizedBox(height: 12),
            PasswordStrengthMeter(password: form.password),
          ],
          const SizedBox(height: 16),
          AppTextField(
            label: 'Confirmar senha',
            hint: 'Confirme sua senha',
            obscureText: true,
            initialValue: form.confirmPassword,
            onChanged: (value) {
              ref
                  .read(fanRegisterProvider.notifier)
                  .setFields(
                    (current) => current.copyWith(confirmPassword: value),
                  );
            },
          ),
          if (mismatch)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                'As senhas não conferem.',
                style: TextStyle(fontSize: 12, color: colors.danger),
              ),
            ),
        ],
      ),
    );
  }
}
