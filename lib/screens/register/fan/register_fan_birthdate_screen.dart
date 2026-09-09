import 'package:crowdfans/components/buttons/app_button.dart';
import 'package:crowdfans/components/register/register_birthdate_picker.dart';
import 'package:crowdfans/components/register/register_fan_scaffold.dart';
import 'package:crowdfans/components/register/register_step_header.dart';
import 'package:crowdfans/constants/pages.dart';
import 'package:crowdfans/state/fan_register_store.dart';
import 'package:crowdfans/utils/birthday_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class RegisterFanBirthdateScreen extends ConsumerWidget {
  const RegisterFanBirthdateScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final form = ref.watch(fanRegisterProvider);
    final maxDate = maxAllowedBirthDate();
    final date = form.birthdate.isAfter(maxDate) ? maxDate : form.birthdate;
    final canProceed = !date.isAfter(maxDate);

    void handleChanged(DateTime picked) {
      final next = picked.isAfter(maxDate) ? maxDate : picked;
      ref
          .read(fanRegisterProvider.notifier)
          .setFields(
            (current) => current.copyWith(
              birthDay: next.day,
              birthMonth: next.month,
              birthYear: next.year,
            ),
          );
    }

    return RegisterFanScaffold(
      onBack: () => context.pop(),
      footer: AppButton(
        label: 'Próximo',
        disabled: !canProceed,
        onPressed: () => context.push(Pages.registerFanProfile),
      ),
      child: ListView(
        children: [
          const RegisterStepHeader(
            title: 'Data de nascimento',
            subtitle: 'Sem mentir ein? hehe 🎂',
          ),
          const SizedBox(height: 24),
          RegisterBirthdatePicker(
            value: date,
            maxDate: maxDate,
            onChanged: handleChanged,
          ),
        ],
      ),
    );
  }
}
