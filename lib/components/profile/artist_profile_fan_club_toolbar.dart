import 'package:crowdfans/components/fan_club/fan_club_sort_tab.dart';
import 'package:crowdfans/components/profile/artist_profile_fan_club_feed.dart';
import 'package:crowdfans/components/profile/me_posts_filter_chip.dart';
import 'package:crowdfans/constants/theme.dart';
import 'package:flutter/material.dart';

/// Ordenação Novos/Populares + chips Todos/Posts/Media da aba Fã Clube.
class ArtistProfileFanClubToolbar extends StatelessWidget {
  const ArtistProfileFanClubToolbar({
    super.key,
    required this.sortPopular,
    required this.filter,
    required this.onSortPopular,
    required this.onFilter,
  });

  final bool sortPopular;
  final ArtistProfileFanClubFilter filter;
  final ValueChanged<bool> onSortPopular;
  final ValueChanged<ArtistProfileFanClubFilter> onFilter;

  @override
  Widget build(BuildContext context) {
    final colors = CrowdFansTheme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Ordenar postagens por:',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: colors.textTertiary,
          ),
        ),
        const SizedBox(height: 4),
        SizedBox(
          height: 40,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: [
              FanClubSortTab(
                label: 'Novos',
                selected: !sortPopular,
                onPressed: () => onSortPopular(false),
              ),
              FanClubSortTab(
                label: 'Populares',
                selected: sortPopular,
                onPressed: () => onSortPopular(true),
              ),
            ],
          ),
        ),
        // CF-186 redo: divisor + chips escuros como no print da comunidade.
        Divider(height: 1, thickness: 1, color: colors.border),
        const SizedBox(height: 10),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              MePostsFilterChip(
                key: const Key('artist-fan-club-filter-all'),
                label: 'Todos',
                selected: filter == ArtistProfileFanClubFilter.all,
                onPressed: () => onFilter(ArtistProfileFanClubFilter.all),
              ),
              const SizedBox(width: 8),
              MePostsFilterChip(
                key: const Key('artist-fan-club-filter-posts'),
                label: 'Posts',
                selected: filter == ArtistProfileFanClubFilter.posts,
                onPressed: () => onFilter(ArtistProfileFanClubFilter.posts),
              ),
              const SizedBox(width: 8),
              MePostsFilterChip(
                key: const Key('artist-fan-club-filter-media'),
                label: 'Media',
                selected: filter == ArtistProfileFanClubFilter.media,
                onPressed: () => onFilter(ArtistProfileFanClubFilter.media),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
