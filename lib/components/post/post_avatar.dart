import 'package:crowdfans/constants/theme.dart';
import 'package:flutter/material.dart';

/// Avatar circular com fallback de cor.
class PostAvatar extends StatelessWidget {
  const PostAvatar({super.key, required this.url, this.size = 40});

  final String url;
  final double size;

  Widget _fallback(AppColors colors) {
    return ColoredBox(
      color: colors.surfaceAlt,
      child: SizedBox(
        width: size,
        height: size,
        child: Icon(
          Icons.person,
          size: size * 0.5,
          color: colors.textTertiary,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = CrowdFansTheme.of(context);
    final trimmed = url.trim();
    final hasNetwork = trimmed.startsWith('http');
    final isAsset = trimmed.startsWith('assets/');
    return ClipOval(
      child: hasNetwork
          ? Image.network(
              trimmed,
              width: size,
              height: size,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stack) => _fallback(colors),
            )
          : isAsset
              ? Image.asset(
                  trimmed,
                  width: size,
                  height: size,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stack) => _fallback(colors),
                )
              : _fallback(colors),
    );
  }
}
