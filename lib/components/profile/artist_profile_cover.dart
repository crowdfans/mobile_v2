import 'package:crowdfans/constants/theme.dart';
import 'package:flutter/material.dart';

/// Cover do perfil do artista (reusa `photoUrl`).
class ArtistProfileCover extends StatelessWidget {
  const ArtistProfileCover({super.key, required this.imageUrl});

  final String imageUrl;

  @override
  Widget build(BuildContext context) {
    final colors = CrowdFansTheme.of(context);
    final url = imageUrl.trim();
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: SizedBox(
        height: 160,
        width: double.infinity,
        child: url.isEmpty
            ? ColoredBox(color: colors.surfaceAlt)
            : Image.network(
                url,
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) => ColoredBox(color: colors.surfaceAlt),
              ),
      ),
    );
  }
}
