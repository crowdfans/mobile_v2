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
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const Spacer(),
              Text(
                'Você é Superfã.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.w800,
                  color: colors.textPrimary,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Conta criada. Bora acompanhar seus artistas.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: colors.textSecondary),
              ),
              const Spacer(),
              AppButton(
                label: 'Começar',
                onPressed: () => context.go(Pages.home),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
