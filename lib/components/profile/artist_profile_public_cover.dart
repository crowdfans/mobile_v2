import 'package:crowdfans/components/profile/artist_me_cover.dart';
import 'package:flutter/material.dart';

/// Cover overlay do perfil público do artista (print Perfil Artista).
class ArtistProfilePublicCover extends StatelessWidget {
  const ArtistProfilePublicCover({
    super.key,
    required this.imageUrl,
    required this.displayName,
    required this.membersLabel,
    required this.subscribed,
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
  final bool subscribed;
  final bool busy;
  final VoidCallback onBack;
  final VoidCallback onMore;
  final VoidCallback onToggleFollow;

  static String formatMembers(int? count) => ArtistMeCover.formatMembers(count);

  @override
  Widget build(BuildContext context) {
    final topInset = MediaQuery.paddingOf(context).top;
    final url = imageUrl.trim();
    final ctaLabel = busy
        ? 'Aguarde...'
        : (subscribed ? 'Membership' : '+ Seguir');
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
                  icon: Icons.arrow_back_ios_new_rounded,
                  onPressed: onBack,
                ),
                const Spacer(),
                _CoverIconButton(
                  key: const Key('artist-profile-more'),
                  icon: Icons.more_horiz,
                  onPressed: onMore,
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
                    color: subscribed
                        ? const Color(0xCC3A2418)
                        : Colors.white,
                    shape: StadiumBorder(
                      side: BorderSide(
                        color: subscribed
                            ? const Color(0xFFE8A05C)
                            : Colors.transparent,
                        width: subscribed ? 1.5 : 0,
                      ),
                    ),
                    child: InkWell(
                      key: const Key('artist-profile-follow'),
                      onTap: busy ? null : onToggleFollow,
                      customBorder: const StadiumBorder(),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        child: Center(
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                ctaLabel,
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700,
                                  color: subscribed
                                      ? const Color(0xFFE8A05C)
                                      : const Color(0xFF1C1C1E),
                                ),
                              ),
                              if (subscribed && !busy) ...[
                                const SizedBox(width: 6),
                                const Icon(
                                  Icons.music_note,
                                  size: 16,
                                  color: Color(0xFFE8A05C),
                                ),
                              ],
                            ],
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
    required this.icon,
    required this.onPressed,
  });

  final IconData icon;
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
          child: Icon(icon, color: Colors.white, size: 20),
        ),
      ),
    );
  }
}
