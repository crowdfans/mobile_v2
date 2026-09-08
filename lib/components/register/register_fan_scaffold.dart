import 'package:crowdfans/components/toolbar/register_top_bar.dart';
import 'package:crowdfans/constants/theme.dart';
import 'package:flutter/material.dart';

/// Shell das etapas de cadastro Superfã.
class RegisterFanScaffold extends StatelessWidget {
  const RegisterFanScaffold({
    super.key,
    required this.onBack,
    required this.child,
    this.footer,
  });

  final VoidCallback onBack;
  final Widget child;
  final Widget? footer;

  @override
  Widget build(BuildContext context) {
    final colors = CrowdFansTheme.of(context);
    return Scaffold(
      backgroundColor: colors.background,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: RegisterTopBar(onBack: onBack),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 0),
                child: child,
              ),
            ),
            if (footer != null)
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
                child: footer,
              ),
          ],
        ),
      ),
    );
  }
}
