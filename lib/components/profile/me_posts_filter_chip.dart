import 'package:crowdfans/constants/theme.dart';
import 'package:flutter/material.dart';

/// Chip Todos / Posts / Media do Meu Perfil (seleção escura no mock).
class MePostsFilterChip extends StatelessWidget {
  const MePostsFilterChip({
    super.key,
    required this.label,
    required this.selected,
    required this.onPressed,
  });

  final String label;
  final bool selected;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final colors = CrowdFansTheme.of(context);
    // CF-178 print: selecionado charcoal; não selecionado borda fina escura.
    final unselectedBorder = colors.textPrimary.withValues(alpha: 0.55);
    return Material(
      color: selected ? AppPalette.platinum900 : colors.surface,
      shape: StadiumBorder(
        side: BorderSide(
          color: selected ? AppPalette.platinum900 : unselectedBorder,
          width: 1,
        ),
      ),
      child: InkWell(
        onTap: onPressed,
        customBorder: const StadiumBorder(),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: selected ? Colors.white : colors.textPrimary,
            ),
          ),
        ),
      ),
    );
  }
}
