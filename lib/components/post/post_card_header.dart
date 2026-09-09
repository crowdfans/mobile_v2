import 'package:crowdfans/components/badges/membership_badge.dart';
import 'package:crowdfans/components/badges/secret_mode_badge.dart';
import 'package:crowdfans/components/post/post_rank_badge.dart';
import 'package:crowdfans/constants/theme.dart';
import 'package:crowdfans/models/feed_post.dart';
import 'package:crowdfans/utils/relative_time.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// Cabeçalho do post: nome, @handle, selo, membership, secreto, tempo e `...`.
class PostCardHeader extends StatelessWidget {
  const PostCardHeader({
    super.key,
    required this.displayAuthorName,
    required this.displayAuthorHandle,
    required this.minutesAgo,
    this.rank,
    this.membershipBadges = const [],
    this.showSecretBadge = false,
    this.onPressOpenProfile,
    this.onPressOpenPostOptions,
  });

  final String displayAuthorName;
  final String displayAuthorHandle;
  final String? rank;
  final int minutesAgo;
  final List<MembershipBadgeInfo> membershipBadges;
  final bool showSecretBadge;
  final VoidCallback? onPressOpenProfile;
  final VoidCallback? onPressOpenPostOptions;

  String formatDisplayHandle(String handle) {
    final cleaned = handle.trim().replaceFirst(RegExp(r'^@'), '');
    if (cleaned.isEmpty) {
      return '';
    }
    final withoutRole = cleaned.replaceFirst(RegExp(r'^(artist|fan)/', caseSensitive: false), '');
    return '@$withoutRole';
  }

  @override
  Widget build(BuildContext context) {
    final colors = CrowdFansTheme.of(context);
    final handleLabel = formatDisplayHandle(displayAuthorHandle);
    final firstBadge = membershipBadges.isEmpty ? null : membershipBadges.first;
    final rankValue = rank?.trim() ?? '';

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: GestureDetector(
            onTap: onPressOpenProfile,
            behavior: HitTestBehavior.opaque,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  crossAxisAlignment: WrapCrossAlignment.center,
                  spacing: 6,
                  runSpacing: 4,
                  children: [
                    Text(
                      displayAuthorName,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: colors.textPrimary,
                      ),
                    ),
                    if (handleLabel.isNotEmpty)
                      Text(
                        handleLabel,
                        style: TextStyle(
                          fontSize: 16,
                          color: colors.textTertiary,
                        ),
                      ),
                    if (rankValue.isNotEmpty) PostRankBadge(rank: rankValue),
                    if (firstBadge != null)
                      MembershipBadge(
                        label: firstBadge.label,
                        tier: firstBadge.tier,
                      ),
                    if (showSecretBadge) const SecretModeBadge(),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  formatMinutesAgo(minutesAgo),
                  style: TextStyle(
                    fontSize: 14,
                    color: colors.textTertiary,
                  ),
                ),
              ],
            ),
          ),
        ),
        if (onPressOpenPostOptions != null)
          IconButton(
            key: const Key('post-more'),
            onPressed: onPressOpenPostOptions,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints.tightFor(width: 28, height: 28),
            tooltip: 'Opções do post',
            icon: SvgPicture.asset(
              'assets/icons/General/dots-horizontal.svg',
              width: 18,
              height: 18,
              colorFilter: ColorFilter.mode(
                colors.textTertiary,
                BlendMode.srcIn,
              ),
            ),
          ),
      ],
    );
  }
}
