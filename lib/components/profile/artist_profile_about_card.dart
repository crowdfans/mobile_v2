import 'package:crowdfans/constants/theme.dart';
import 'package:flutter/material.dart';

/// Card de seção na aba Sobre do artista.
class ArtistProfileAboutCard extends StatelessWidget {
  const ArtistProfileAboutCard({
    super.key,
    required this.label,
    required this.body,
  });

  final String label;
  final String body;

  @override
  Widget build(BuildContext context) {
    final colors = CrowdFansTheme.of(context);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: colors.surface,
        border: Border.all(color: colors.border),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: colors.textTertiary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              body,
              style: TextStyle(
                fontSize: 14,
                height: 20 / 14,
                color: colors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
