import 'package:crowdfans/components/buttons/app_button.dart';
import 'package:crowdfans/components/input/app_text_field.dart';
import 'package:crowdfans/components/register/register_fan_scaffold.dart';
import 'package:crowdfans/components/register/register_step_header.dart';
import 'package:crowdfans/constants/pages.dart';
import 'package:crowdfans/state/fan_register_store.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class RegisterFanNameScreen extends ConsumerWidget {
  const RegisterFanNameScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final name = ref.watch(fanRegisterProvider).name;
    return RegisterFanScaffold(
      onBack: () => context.pop(),
      footer: AppButton(
        label: 'Próximo',
        disabled: name.trim().isEmpty,
        onPressed: () => context.push(Pages.registerFanUsername),
      ),
      child: ListView(
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        children: [
          const RegisterStepHeader(
            title: 'Como a gente te chama?',
            subtitle: 'Pode ser nome ou apelido mesmo.',
          ),
          const SizedBox(height: 32),
          AppTextField(
            initialValue: name,
            label: 'Nome',
            hint: 'Nome',
            textCapitalization: TextCapitalization.words,
            onChanged: (value) {
              ref
                  .read(fanRegisterProvider.notifier)
                  .setFields((current) => current.copyWith(name: value));
            },
          ),
        ],
      ),
    );
  }
}
