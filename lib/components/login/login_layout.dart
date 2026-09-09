import 'package:crowdfans/components/toolbar/register_top_bar.dart';
import 'package:crowdfans/constants/theme.dart';
import 'package:flutter/material.dart';

/// Layout compartilhado das telas de login (SafeArea + teclado + top bar).
class LoginLayout extends StatelessWidget {
  const LoginLayout({super.key, required this.onBack, required this.child});

  final VoidCallback onBack;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final colors = CrowdFansTheme.of(context);
    return Scaffold(
      backgroundColor: colors.background,
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(24, 0, 24, 20),
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          children: [
            RegisterTopBar(onBack: onBack),
            child,
          ],
        ),
      ),
    );
  }
}
