import 'package:crowdfans/components/buttons/app_button.dart';
import 'package:crowdfans/components/register/register_fan_scaffold.dart';
import 'package:crowdfans/constants/pages.dart';
import 'package:crowdfans/constants/theme.dart';
import 'package:crowdfans/state/fan_register_store.dart';
import 'package:crowdfans/utils/birthday_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class RegisterFanBirthdateScreen extends ConsumerWidget {
  const RegisterFanBirthdateScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = CrowdFansTheme.of(context);
    final form = ref.watch(fanRegisterProvider);
    final date = form.birthdate;

    Future<void> handlePick() async {
      final picked = await showDatePicker(
        context: context,
        initialDate: date.isAfter(maxAllowedBirthDate())
            ? maxAllowedBirthDate()
            : date,
        firstDate: DateTime(1920),
        lastDate: maxAllowedBirthDate(),
      );
      if (picked == null) {
        return;
      }
      ref
          .read(fanRegisterProvider.notifier)
          .setFields(
            (current) => current.copyWith(
              birthDay: picked.day,
              birthMonth: picked.month,
              birthYear: picked.year,
            ),
          );
    }

    return RegisterFanScaffold(
      onBack: () => context.pop(),
      footer: AppButton(
        label: 'Continuar',
        onPressed: () => context.push(Pages.registerFanUsername),
      ),
      child: ListView(
        children: [
          const SizedBox(height: 32),
          Text(
            'Quando você nasceu?',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w800,
              color: colors.textPrimary,
            ),
          ),
          const SizedBox(height: 24),
          OutlinedButton(
            onPressed: handlePick,
            child: Text(
              '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}',
              style: TextStyle(fontSize: 18, color: colors.textPrimary),
            ),
          ),
        ],
      ),
    );
  }
}
