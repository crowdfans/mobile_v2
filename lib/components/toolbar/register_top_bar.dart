import 'package:crowdfans/components/toolbar/toolbar_back_button.dart';
import 'package:crowdfans/constants/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// Top bar de login/cadastro: voltar + símbolo CrowdFans.
class RegisterTopBar extends StatelessWidget {
  const RegisterTopBar({super.key, required this.onBack});

  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    final colors = CrowdFansTheme.of(context);
    return SizedBox(
      height: 56,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: ToolbarBackButton(onPressed: onBack),
          ),
          SvgPicture.asset(
            'assets/images/dark_symbol.svg.svg',
            width: 50,
            height: 50,
            colorFilter: ColorFilter.mode(colors.textPrimary, BlendMode.srcIn),
          ),
        ],
      ),
    );
  }
}
