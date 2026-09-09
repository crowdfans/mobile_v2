import 'package:crowdfans/components/buttons/app_button.dart';
import 'package:crowdfans/constants/pages.dart';
import 'package:crowdfans/constants/theme.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class RegisterFanSuccessScreen extends StatelessWidget {
  const RegisterFanSuccessScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = CrowdFansTheme.of(context);
    return Scaffold(
      backgroundColor: colors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
          child: Column(
            children: [
              const Spacer(),
              Text(
                'Parabéns! 🥳',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.w800,
                  color: colors.textPrimary,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Agora você faz parte da Crowd Fans.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: colors.textSecondary),
              ),
              const Spacer(),
              AppButton(
                label: 'Concluir',
                onPressed: () => context.go(Pages.home),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
