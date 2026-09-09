import 'package:crowdfans/components/buttons/app_button.dart';
import 'package:crowdfans/components/register/register_fan_scaffold.dart';
import 'package:crowdfans/components/register/register_step_header.dart';
import 'package:crowdfans/components/register/register_username_field.dart';
import 'package:crowdfans/constants/pages.dart';
import 'package:crowdfans/constants/theme.dart';
import 'package:crowdfans/state/fan_register_store.dart';
import 'package:crowdfans/utils/username_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class RegisterFanUsernameScreen extends ConsumerWidget {
  const RegisterFanUsernameScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = CrowdFansTheme.of(context);
    final username = ref.watch(fanRegisterProvider).username;
    final trimmed = username.trim().toLowerCase();
    final valid = isUsernameValid(username);
    final available = trimmed.isNotEmpty && valid;
    return RegisterFanScaffold(
      onBack: () => context.pop(),
      footer: AppButton(
        label: 'Próximo',
        disabled: !valid,
        onPressed: () => context.push(Pages.registerFanBirthdate),
      ),
      child: ListView(
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        children: [
          const RegisterStepHeader(
            title: 'Agora, vamos criar o seu username.',
            subtitle: 'Algum que você usa em outras redes ou algo assim?',
          ),
          const SizedBox(height: 32),
          RegisterUsernameField(
            value: username,
            onChanged: (value) {
              ref
                  .read(fanRegisterProvider.notifier)
                  .setFields(
                    (current) =>
                        current.copyWith(username: normalizeUsername(value)),
                  );
            },
          ),
          if (trimmed.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 10),
              child: Text(
                available ? 'Username disponível.' : 'Username indisponível.',
                style: TextStyle(
                  fontSize: 13,
                  color: available ? colors.success : colors.danger,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
