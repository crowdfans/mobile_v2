import 'package:crowdfans/components/profile/artist_me_cover.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// Cover overlay do perfil público do artista (print Perfil Artista).
class ArtistProfilePublicCover extends StatelessWidget {
  const ArtistProfilePublicCover({
    super.key,
    required this.imageUrl,
    required this.displayName,
    required this.membersLabel,
    required this.following,
    required this.busy,
    required this.onBack,
    required this.onMore,
    required this.onToggleFollow,
    this.rank,
  });

  final String imageUrl;
  final String displayName;
  final String membersLabel;
  final int? rank;
  final bool following;
  final bool busy;
  final VoidCallback onBack;
  final VoidCallback onMore;
  final VoidCallback onToggleFollow;

  static String formatMembers(int? count) => ArtistMeCover.formatMembers(count);

  /// Rótulo do CTA de follow gratuito (CF-140) — membership fica na aba Exclusivo.
  static String followCtaLabel({
    required bool following,
    required bool busy,
  }) {
    if (busy) {
      return 'Aguarde...';
    }
    return following ? 'Seguindo' : '+ Seguir';
  }

  @override
  Widget build(BuildContext context) {
    final topInset = MediaQuery.paddingOf(context).top;
    final url = imageUrl.trim();
    final ctaLabel = followCtaLabel(following: following, busy: busy);
    return SizedBox(
      height: 320 + topInset,
      width: double.infinity,
      child: Stack(
        fit: StackFit.expand,
        children: [
          if (url.isEmpty)
            const ColoredBox(color: Color(0xFF1C1C1E))
          else
            Image.network(
              url,
              fit: BoxFit.cover,
              errorBuilder: (_, _, _) =>
                  const ColoredBox(color: Color(0xFF1C1C1E)),
            ),
          const DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0x66000000),
                  Color(0x00000000),
                  Color(0xCC000000),
                ],
                stops: [0, 0.35, 1],
              ),
            ),
          ),
          Positioned(
            top: topInset + 8,
            left: 12,
            right: 12,
            child: Row(
              children: [
                _CoverIconButton(
                  key: const Key('artist-profile-back'),
                  onPressed: onBack,
                  child: const Icon(
                    Icons.arrow_back_ios_new_rounded,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
                const Spacer(),
                _CoverIconButton(
                  key: const Key('artist-profile-more'),
                  onPressed: onMore,
                  child: SvgPicture.asset(
                    'assets/icons/General/dots-horizontal.svg',
                    width: 20,
                    height: 20,
                    colorFilter: const ColorFilter.mode(
                      Colors.white,
                      BlendMode.srcIn,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            left: 24,
            right: 24,
            bottom: 24,
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Flexible(
                      child: Text(
                        displayName,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    if (rank != null) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          '#$rank',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF1C1C1E),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  membersLabel,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: Material(
                    // Follow gratuito ≠ Membership: branco / borda clara (print Feed).
                    color: following
                        ? Colors.white.withValues(alpha: 0.18)
                        : Colors.white,
                    shape: StadiumBorder(
                      side: BorderSide(
                        color: following
                            ? Colors.white.withValues(alpha: 0.85)
                            : Colors.transparent,
                        width: following ? 1.5 : 0,
                      ),
                    ),
                    child: InkWell(
                      key: const Key('artist-profile-follow'),
                      onTap: busy ? null : onToggleFollow,
                      customBorder: const StadiumBorder(),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        child: Center(
                          child: Text(
                            ctaLabel,
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: following
                                  ? Colors.white
                                  : const Color(0xFF1C1C1E),
                            ),
                          ),
                        ),
                      ),
                    ),
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

class _CoverIconButton extends StatelessWidget {
  const _CoverIconButton({
    super.key,
    required this.child,
    required this.onPressed,
  });

  final Widget child;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0x66000000),
      shape: const CircleBorder(),
      child: InkWell(
        onTap: onPressed,
        customBorder: const CircleBorder(),
        child: SizedBox(
          width: 40,
          height: 40,
          child: Center(child: child),
        ),
      ),
    );
  }
}
