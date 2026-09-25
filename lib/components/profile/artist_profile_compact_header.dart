import 'package:crowdfans/constants/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// Cabeçalho compacto após scroll no perfil do artista (CF-181/185 prints).
class ArtistProfileCompactHeader extends StatelessWidget {
  const ArtistProfileCompactHeader({
    super.key,
    required this.displayName,
    required this.handle,
    required this.avatarUrl,
    required this.onBack,
    required this.onMore,
  });

  final String displayName;
  final String handle;
  final String avatarUrl;
  final VoidCallback onBack;
  final VoidCallback onMore;

  @override
  Widget build(BuildContext context) {
    final colors = CrowdFansTheme.of(context);
    final topInset = MediaQuery.paddingOf(context).top;
    final url = avatarUrl.trim();
    return Material(
      elevation: 1,
      color: colors.surface,
      child: Padding(
        padding: EdgeInsets.fromLTRB(4, topInset + 4, 4, 8),
        child: Row(
          children: [
            IconButton(
              key: const Key('artist-compact-back'),
              onPressed: onBack,
              icon: SvgPicture.asset(
                'assets/icons/arrows/chevron-left.svg',
                width: 22,
                height: 22,
                colorFilter: ColorFilter.mode(
                  colors.textPrimary,
                  BlendMode.srcIn,
                ),
              ),
            ),
            CircleAvatar(
              radius: 16,
              backgroundColor: colors.surfaceAlt,
              backgroundImage:
                  url.startsWith('http') ? NetworkImage(url) : null,
              child: url.startsWith('http')
                  ? null
                  : Icon(Icons.person, size: 16, color: colors.textTertiary),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    displayName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: colors.textPrimary,
                    ),
                  ),
                  Text(
                    handle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 12,
                      color: colors.textTertiary,
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              key: const Key('artist-compact-more'),
              onPressed: onMore,
              icon: Icon(Icons.more_horiz, color: colors.textPrimary),
            ),
          ],
        ),
      ),
    );
  }
}
