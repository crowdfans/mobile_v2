import 'package:crowdfans/components/fan_club/fan_club_sort_tab.dart';
import 'package:crowdfans/components/profile/me_posts_filter_chip.dart';
import 'package:crowdfans/components/toolbar/toolbar_menu_button.dart';
import 'package:crowdfans/constants/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// Chrome do feed “Postagens dos Fã Clubes” (print Feed Fã Clubes).
class FanClubsFeedHeader extends StatelessWidget {
  const FanClubsFeedHeader({
    super.key,
    required this.sortPopular,
    required this.filterAll,
    required this.filterPosts,
    required this.filterMedia,
    required this.onOpenMenu,
    required this.onOpenSearch,
    required this.onSortPopular,
    required this.onSortNew,
    required this.onFilterAll,
    required this.onFilterPosts,
    required this.onFilterMedia,
  });

  final bool sortPopular;
  final bool filterAll;
  final bool filterPosts;
  final bool filterMedia;
  final VoidCallback onOpenMenu;
  final VoidCallback onOpenSearch;
  final VoidCallback onSortPopular;
  final VoidCallback onSortNew;
  final VoidCallback onFilterAll;
  final VoidCallback onFilterPosts;
  final VoidCallback onFilterMedia;

  @override
  Widget build(BuildContext context) {
    final colors = CrowdFansTheme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: 52,
          child: Row(
            children: [
              ToolbarMenuButton(onPressed: onOpenMenu),
              Expanded(
                child: Text(
                  'Postagens dos Fã Clubes',
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    color: colors.textPrimary,
                  ),
                ),
              ),
              IconButton(
                key: const Key('fan-clubs-search'),
                onPressed: onOpenSearch,
                tooltip: 'Buscar fã clube',
                icon: SvgPicture.asset(
                  'assets/icons/General/search-md.svg',
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
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 0),
          child: Text(
            'Ordenar postagens por:',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: colors.textTertiary,
            ),
          ),
        ),
        SizedBox(
          height: 44,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 8),
            children: [
              FanClubSortTab(
                label: 'Popularidade',
                selected: sortPopular,
                onPressed: onSortPopular,
              ),
              FanClubSortTab(
                label: 'Novos',
                selected: !sortPopular,
                onPressed: onSortNew,
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
          child: Wrap(
            spacing: 8,
            children: [
              MePostsFilterChip(
                label: 'Todos',
                selected: filterAll,
                onPressed: onFilterAll,
              ),
              MePostsFilterChip(
                label: 'Posts',
                selected: filterPosts,
                onPressed: onFilterPosts,
              ),
              MePostsFilterChip(
                label: 'Media',
                selected: filterMedia,
                onPressed: onFilterMedia,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
