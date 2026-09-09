import 'package:crowdfans/components/buttons/app_icon_button.dart';
import 'package:crowdfans/components/toolbar/toolbar_menu_button.dart';
import 'package:crowdfans/constants/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// Toolbar com logo CrowdFans (espelho do `ImageToolbarComponent`).
class ImageToolbar extends StatelessWidget {
  const ImageToolbar({
    super.key,
    this.leading,
    this.trailing,
    this.onMenu,
    this.onNotifications,
  });

  final Widget? leading;
  final Widget? trailing;
  final VoidCallback? onMenu;
  final VoidCallback? onNotifications;

  @override
  Widget build(BuildContext context) {
    final colors = CrowdFansTheme.of(context);
    final left =
        leading ??
        (onMenu == null
            ? const SizedBox(width: 40)
            : ToolbarMenuButton(
                key: const Key('home-menu'),
                onPressed: onMenu!,
              ));
    final right =
        trailing ??
        (onNotifications == null
            ? const SizedBox(width: 40)
            : AppIconButton(
                key: const Key('home-notifications'),
                asset: 'assets/icons/alerts_and_feedbacks/bell-01.svg',
                onPressed: onNotifications!,
                color: colors.icon,
                size: 32,
                iconSize: 22,
                semanticLabel: 'Abrir notificações',
              ));
    return SizedBox(
      height: 56,
      child: Row(
        children: [
          left,
          Expanded(
            child: Center(
              child: SvgPicture.asset(
                'assets/logo/crowdfans-logo.svg',
                width: 112,
                height: 24,
                colorFilter: ColorFilter.mode(
                  colors.textPrimary,
                  BlendMode.srcIn,
                ),
              ),
            ),
          ),
          right,
        ],
      ),
    );
  }
}
