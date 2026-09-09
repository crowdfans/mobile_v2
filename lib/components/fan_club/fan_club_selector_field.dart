import 'package:crowdfans/components/fan_club/fan_club_compose_artist.dart';
import 'package:crowdfans/components/post/post_avatar.dart';
import 'package:crowdfans/constants/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// Campo "Selecionar Fã Clube" (ou artista já escolhido) no composer.
class FanClubSelectorField extends StatelessWidget {
  const FanClubSelectorField({
    super.key,
    required this.selected,
    required this.expanded,
    required this.onPressed,
    this.enabled = true,
  });

  final FanClubComposeArtist? selected;
  final bool expanded;
  final VoidCallback? onPressed;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final colors = CrowdFansTheme.of(context);
    final artist = selected;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        key: const Key('novo-post-club-selector'),
        onTap: enabled ? onPressed : null,
        borderRadius: BorderRadius.circular(16),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: colors.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: colors.border),
          ),
          child: SizedBox(
            height: 62,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18),
              child: Row(
                children: [
                  if (artist != null && artist.avatarUrl.trim().isNotEmpty) ...[
                    PostAvatar(url: artist.avatarUrl, size: 28),
                    const SizedBox(width: 10),
                  ],
                  Expanded(
                    child: Text(
                      artist?.name ?? 'Selecionar Fã Clube',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                        color: artist == null
                            ? colors.textTertiary
                            : colors.textPrimary,
                      ),
                    ),
                  ),
                  if (enabled)
                    AnimatedRotation(
                      turns: expanded ? 0.5 : 0,
                      duration: const Duration(milliseconds: 160),
                      child: SvgPicture.asset(
                        'assets/icons/arrows/chevron-down.svg',
                        width: 18,
                        height: 18,
                        colorFilter: ColorFilter.mode(
                          colors.textTertiary,
                          BlendMode.srcIn,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
