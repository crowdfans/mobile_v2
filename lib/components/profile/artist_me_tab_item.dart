import 'package:crowdfans/constants/theme.dart';
import 'package:flutter/material.dart';

/// Item de aba com underline do Meu Perfil Artista.
class ArtistMeTabItem extends StatelessWidget {
  const ArtistMeTabItem({
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
    return InkWell(
      onTap: onPressed,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                color: selected ? colors.textPrimary : colors.textSecondary,
              ),
            ),
            const SizedBox(height: 10),
            Container(
              height: 2.5,
              width: 28,
              color: selected ? colors.textPrimary : Colors.transparent,
            ),
          ],
        ),
      ),
    );
  }
}
