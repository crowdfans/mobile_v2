import 'package:crowdfans/components/toolbar/toolbar_back_button.dart';
import 'package:crowdfans/constants/theme.dart';
import 'package:flutter/material.dart';

/// Cabeçalho compacto das telas de perfil público.
class ProfileScreenHeader extends StatelessWidget {
  const ProfileScreenHeader({
    super.key,
    required this.title,
    required this.onBack,
    this.action,
  });

  final String title;
  final VoidCallback onBack;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    final colors = CrowdFansTheme.of(context);
    return SizedBox(
      height: 56,
      child: Row(
        children: [
          ToolbarBackButton(onPressed: onBack),
          Expanded(
            child: Text(
              title,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w700,
                color: colors.textPrimary,
              ),
            ),
          ),
          SizedBox(width: 44, child: action),
        ],
      ),
    );
  }
}
