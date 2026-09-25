import 'package:crowdfans/constants/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// Ação compacta de share no sheet dos 3 pontinhos (CF-176).
///
/// Referência: tile branco arredondado com ícone + rótulo.
class PostOptionsShareAction extends StatelessWidget {
  const PostOptionsShareAction({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.asset,
    this.iconColor,
  });

  final String label;
  final VoidCallback onPressed;
  final IconData? icon;
  final String? asset;
  final Color? iconColor;

  @override
  Widget build(BuildContext context) {
    final colors = CrowdFansTheme.of(context);
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: Material(
          color: colors.surface,
          borderRadius: BorderRadius.circular(12),
          child: InkWell(
            onTap: onPressed,
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Column(
                children: [
                  if (asset != null)
                    asset!.endsWith('.svg')
                        ? SvgPicture.asset(
                            asset!,
                            width: 26,
                            height: 26,
                            colorFilter: iconColor == null
                                ? null
                                : ColorFilter.mode(
                                    iconColor!,
                                    BlendMode.srcIn,
                                  ),
                          )
                        : Image.asset(asset!, width: 26, height: 26)
                  else
                    Icon(
                      icon ?? Icons.link,
                      color: iconColor ?? colors.primary,
                      size: 26,
                    ),
                  const SizedBox(height: 6),
                  Text(
                    label,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: colors.textPrimary,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
