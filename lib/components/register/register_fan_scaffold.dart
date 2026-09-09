import 'package:crowdfans/components/register/register_verification_bar.dart';
import 'package:crowdfans/components/toolbar/register_top_bar.dart';
import 'package:crowdfans/constants/theme.dart';
import 'package:flutter/material.dart';

/// Shell das etapas de cadastro Superfã / Artista.
class RegisterFanScaffold extends StatelessWidget {
  const RegisterFanScaffold({
    super.key,
    required this.onBack,
    required this.child,
    this.footer,
    this.toolbarTitle,
  });

  final VoidCallback onBack;
  final Widget child;
  final Widget? footer;
  final String? toolbarTitle;

  @override
  Widget build(BuildContext context) {
    final colors = CrowdFansTheme.of(context);
    return Scaffold(
      backgroundColor: colors.background,
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: toolbarTitle == null
                  ? RegisterTopBar(onBack: onBack)
                  : RegisterVerificationBar(
                      title: toolbarTitle!,
                      onBack: onBack,
                    ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 0),
                child: child,
              ),
            ),
            if (footer != null)
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 12, 24, 32),
                child: footer,
              ),
          ],
        ),
      ),
    );
  }
}
