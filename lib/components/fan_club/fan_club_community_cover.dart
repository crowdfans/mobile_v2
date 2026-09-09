import 'package:crowdfans/constants/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

const _communityCoverHeight = 198.0;

/// Cover do perfil do Fã Clube (print Perfil Fã Clube) com voltar / busca / mais.
class FanClubCommunityCover extends StatelessWidget {
  const FanClubCommunityCover({
    super.key,
    required this.imageUrl,
    required this.onBack,
    required this.onSearch,
    required this.onMore,
  });

  final String imageUrl;
  final VoidCallback onBack;
  final VoidCallback onSearch;
  final VoidCallback onMore;

  @override
  Widget build(BuildContext context) {
    final topInset = MediaQuery.paddingOf(context).top;
    final url = imageUrl.trim();
    final colors = CrowdFansTheme.of(context);
    return SizedBox(
      height: _communityCoverHeight + topInset,
      width: double.infinity,
      child: Stack(
        fit: StackFit.expand,
        children: [
          if (url.isEmpty)
            ColoredBox(color: colors.surfaceAlt)
          else
            Image.network(
              url,
              fit: BoxFit.cover,
              errorBuilder: (_, _, _) => ColoredBox(color: colors.surfaceAlt),
            ),
          Positioned(
            top: topInset + 10,
            left: 12,
            right: 12,
            child: Row(
              children: [
                _CoverChromeButton(
                  key: const Key('fan-club-cover-back'),
                  onPressed: onBack,
                  child: Icon(
                    Icons.arrow_back_ios_new_rounded,
                    size: 18,
                    color: AppPalette.platinum50,
                  ),
                ),
                const Spacer(),
                _CoverChromeButton(
                  key: const Key('fan-club-cover-search'),
                  onPressed: onSearch,
                  child: SvgPicture.asset(
                    'assets/icons/General/search-md.svg',
                    width: 22,
                    height: 22,
                    colorFilter: const ColorFilter.mode(
                      AppPalette.platinum50,
                      BlendMode.srcIn,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                _CoverChromeButton(
                  key: const Key('fan-club-cover-more'),
                  onPressed: onMore,
                  child: Icon(
                    Icons.more_horiz,
                    size: 22,
                    color: AppPalette.platinum50,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CoverChromeButton extends StatelessWidget {
  const _CoverChromeButton({
    super.key,
    required this.onPressed,
    required this.child,
  });

  final VoidCallback onPressed;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0x990F172A),
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onPressed,
        child: SizedBox(width: 44, height: 44, child: Center(child: child)),
      ),
    );
  }
}
