import 'package:crowdfans/constants/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// Botão de ação de mídia no compose (imagem ou música).
class CreatePostMediaActionButton extends StatelessWidget {
  const CreatePostMediaActionButton({
    super.key,
    required this.label,
    required this.asset,
    required this.onPressed,
    this.selected = false,
  });

  final String label;
  final String asset;
  final VoidCallback onPressed;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    final colors = CrowdFansTheme.of(context);
    return Material(
      color: selected ? colors.primary.withValues(alpha: 0.12) : colors.inputBackground,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: BorderSide(
          color: selected ? colors.primary : colors.inputBorder,
          width: selected ? 1.5 : 1,
        ),
      ),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(10),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SvgPicture.asset(
                asset,
                width: 20,
                height: 20,
                colorFilter: ColorFilter.mode(
                  selected ? colors.primary : colors.textSecondary,
                  BlendMode.srcIn,
                ),
              ),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  label,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: selected ? colors.primary : colors.textSecondary,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
