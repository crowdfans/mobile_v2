import 'package:crowdfans/constants/theme.dart';
import 'package:flutter/material.dart';

/// Toolbar só com título (espelho do `TextToolbar`).
class TextToolbar extends StatelessWidget {
  const TextToolbar({
    super.key,
    required this.title,
    this.leading,
    this.trailing,
  });

  final String title;
  final Widget? leading;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final colors = CrowdFansTheme.of(context);
    return SizedBox(
      height: 56,
      child: Row(
        children: [
          ?leading,
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: colors.textPrimary,
              ),
            ),
          ),
          ?trailing,
        ],
      ),
    );
  }
}
