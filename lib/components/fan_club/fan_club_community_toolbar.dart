import 'package:crowdfans/components/post/post_avatar.dart';
import 'package:crowdfans/constants/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// Toolbar compacta da comunidade (print Fã Clube / Perfil Artista).
class FanClubCommunityToolbar extends StatelessWidget {
  const FanClubCommunityToolbar({
    super.key,
    required this.artistName,
    required this.avatarUrl,
    required this.onBack,
    required this.onMore,
  });

  final String artistName;
  final String avatarUrl;
  final VoidCallback onBack;
  final VoidCallback onMore;

  @override
  Widget build(BuildContext context) {
    final colors = CrowdFansTheme.of(context);
    final name = artistName.trim().isEmpty ? 'Artista' : artistName.trim();
    return SizedBox(
      height: 56,
      child: Row(
        children: [
          IconButton(
            key: const Key('fan-club-back'),
            onPressed: onBack,
            icon: Icon(Icons.arrow_back_ios_new_rounded, color: colors.textPrimary),
          ),
          PostAvatar(url: avatarUrl, size: 36),
          const SizedBox(width: 10),
          Expanded(
            child: RichText(
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              text: TextSpan(
                children: [
                  TextSpan(
                    text: name,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: colors.textPrimary,
                    ),
                  ),
                  TextSpan(
                    text: ' Fã Clube',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: colors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ),
          IconButton(
            key: const Key('fan-club-more'),
            onPressed: onMore,
            icon: SvgPicture.asset(
              'assets/icons/General/dots-horizontal.svg',
              width: 22,
              height: 22,
              colorFilter: ColorFilter.mode(
                colors.textPrimary,
                BlendMode.srcIn,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
