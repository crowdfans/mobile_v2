import 'package:crowdfans/constants/theme.dart';
import 'package:flutter/material.dart';

/// Avatar circular com fallback de cor.
class PostAvatar extends StatelessWidget {
  const PostAvatar({super.key, required this.url, this.size = 40});

  final String url;
  final double size;

  @override
  Widget build(BuildContext context) {
    final colors = CrowdFansTheme.of(context);
    return ClipOval(
      child: url.trim().isEmpty
          ? ColoredBox(
              color: colors.surfaceAlt,
              child: SizedBox(width: size, height: size),
            )
          : Image.network(
              url,
              width: size,
              height: size,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stack) => ColoredBox(
                color: colors.surfaceAlt,
                child: SizedBox(width: size, height: size),
              ),
            ),
    );
  }
}
