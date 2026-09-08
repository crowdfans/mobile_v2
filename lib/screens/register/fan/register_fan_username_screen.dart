import 'package:crowdfans/components/buttons/app_button.dart';
import 'package:crowdfans/components/input/app_text_field.dart';
import 'package:crowdfans/components/register/register_fan_scaffold.dart';
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
    return RegisterFanScaffold(
      onBack: () => context.pop(),
      footer: AppButton(
        label: 'Continuar',
        disabled: !isUsernameValid(username),
        onPressed: () => context.push(Pages.registerFanProfile),
      ),
      child: ListView(
        children: [
          const SizedBox(height: 32),
          Text(
            'Escolha um username',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w800,
              color: colors.textPrimary,
            ),
          ),
          const SizedBox(height: 24),
          AppTextField(
            initialValue: username,
            hint: 'username',
            onChanged: (value) {
              ref
                  .read(fanRegisterProvider.notifier)
                  .setFields(
                    (current) =>
                        current.copyWith(username: normalizeUsername(value)),
                  );
            },
          ),
        ],
      ),
    );
  }
}
