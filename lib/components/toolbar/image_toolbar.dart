import 'package:crowdfans/constants/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// Toolbar com logo CrowdFans (espelho do `ImageToolbarComponent`).
class ImageToolbar extends StatelessWidget {
  const ImageToolbar({super.key, this.trailing});

  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final colors = CrowdFansTheme.of(context);
    return SizedBox(
      height: 56,
      child: Row(
        children: [
          SvgPicture.asset(
            'assets/logo/crowdfans-logo.svg',
            height: 28,
            colorFilter: ColorFilter.mode(colors.textPrimary, BlendMode.srcIn),
          ),
          const Spacer(),
          ?trailing,
        ],
      ),
    );
  }
}
