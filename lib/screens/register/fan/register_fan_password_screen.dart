import 'package:crowdfans/components/buttons/app_button.dart';
import 'package:crowdfans/components/input/app_text_field.dart';
import 'package:crowdfans/components/register/register_fan_scaffold.dart';
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
    final checks = getPasswordChecks(form.password);
    final match =
        form.password.isNotEmpty && form.password == form.confirmPassword;
    return RegisterFanScaffold(
      onBack: () => context.pop(),
      footer: AppButton(
        label: 'Continuar',
        disabled: !isStrongPassword(form.password) || !match,
        onPressed: () => context.push(Pages.registerFanName),
      ),
      child: ListView(
        children: [
          const SizedBox(height: 32),
          Text(
            'Crie uma senha',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w800,
              color: colors.textPrimary,
            ),
          ),
          const SizedBox(height: 24),
          AppTextField(
            hint: 'Senha',
            obscureText: true,
            onChanged: (value) {
              ref
                  .read(fanRegisterProvider.notifier)
                  .setFields((current) => current.copyWith(password: value));
            },
          ),
          const SizedBox(height: 12),
          AppTextField(
            hint: 'Confirmar senha',
            obscureText: true,
            onChanged: (value) {
              ref
                  .read(fanRegisterProvider.notifier)
                  .setFields(
                    (current) => current.copyWith(confirmPassword: value),
                  );
            },
          ),
          const SizedBox(height: 16),
          for (final check in checks)
            Text(
              '${check.ok ? '✓' : '○'} ${check.label}',
              style: TextStyle(
                color: check.ok ? colors.primary : colors.textTertiary,
              ),
            ),
        ],
      ),
    );
  }
}
