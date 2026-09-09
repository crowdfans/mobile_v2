import 'package:crowdfans/components/buttons/app_button.dart';
import 'package:crowdfans/components/input/app_text_field.dart';
import 'package:crowdfans/components/register/register_fan_scaffold.dart';
import 'package:crowdfans/components/register/register_step_header.dart';
import 'package:crowdfans/constants/pages.dart';
import 'package:crowdfans/state/fan_register_store.dart';
import 'package:crowdfans/utils/email_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class RegisterFanEmailScreen extends ConsumerWidget {
  const RegisterFanEmailScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final email = ref.watch(fanRegisterProvider).email;
    return RegisterFanScaffold(
      onBack: () => context.pop(),
      footer: AppButton(
        label: 'Próximo',
        disabled: !isEmailValid(email),
        onPressed: () => context.push(Pages.registerFanPassword),
      ),
      child: ListView(
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        children: [
          const RegisterStepHeader(
            title: 'Crie seu acesso',
            subtitle:
                'Insira seu e-mail abaixo ou conecte-se com uma conta social.',
          ),
          const SizedBox(height: 32),
          AppTextField(
            key: const Key('register-email-input'),
            initialValue: email,
            hint: 'E-mail',
            keyboardType: TextInputType.emailAddress,
            onChanged: (value) {
              ref
                  .read(fanRegisterProvider.notifier)
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
