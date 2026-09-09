import 'package:crowdfans/constants/theme.dart';
import 'package:flutter/material.dart';

/// Tile grande de discovery na Search (prints Artista).
class SearchDiscoveryTile extends StatelessWidget {
  const SearchDiscoveryTile({
    super.key,
    required this.title,
    required this.onPressed,
    this.accent,
  });

  final String title;
  final VoidCallback onPressed;
  final Color? accent;

  @override
  Widget build(BuildContext context) {
    final colors = CrowdFansTheme.of(context);
    return Expanded(
      child: Material(
        color: accent ?? colors.surfaceAlt,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(16),
          child: SizedBox(
            height: 110,
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Align(
                alignment: Alignment.topLeft,
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: colors.textPrimary,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
