import 'package:crowdfans/components/buttons/app_button.dart';
import 'package:crowdfans/components/fan_letter/fan_letter_card.dart';
import 'package:crowdfans/components/feed/feed_item.dart';
import 'package:crowdfans/components/profile/artist_me_cover.dart';
import 'package:crowdfans/components/profile/artist_me_feed_filter_chip.dart';
import 'package:crowdfans/components/profile/artist_me_tab_bar.dart';
import 'package:crowdfans/components/profile/artist_profile_about_card.dart';
import 'package:crowdfans/components/profile/me_followed_artists_section.dart';
import 'package:crowdfans/components/profile/me_posts_filter_chip.dart';
import 'package:crowdfans/components/profile/me_profile_actions_row.dart';
import 'package:crowdfans/components/profile/me_profile_toolbar.dart';
import 'package:crowdfans/components/profile/profile_identity_block.dart';
import 'package:crowdfans/components/profile/profile_state.dart';
import 'package:crowdfans/constants/pages.dart';
import 'package:crowdfans/constants/theme.dart';
import 'package:crowdfans/models/fan_profile.dart';
import 'package:crowdfans/models/feed_post.dart';
import 'package:crowdfans/models/profile.dart';
import 'package:crowdfans/services/fan_club_service.dart';
import 'package:crowdfans/services/fan_letter_service.dart';
import 'package:crowdfans/services/profile_service.dart';
import 'package:crowdfans/services/search_service.dart';
import 'package:crowdfans/state/auth_session.dart';
import 'package:crowdfans/utils/exclusive_content_access.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

enum _MePostsFilter { all, media }

enum _ArtistFeedFilter { all, posts, media }

/// Aba Perfil — identidade, atalhos, artistas, filtros e publicações.
class MeScreen extends ConsumerStatefulWidget {
  const MeScreen({super.key});

  @override
  ConsumerState<MeScreen> createState() => _MeScreenState();
}

class _MeScreenState extends ConsumerState<MeScreen> {
  var _posts = <FeedPost>[];
  var _artists = <FollowedArtist>[];
  var _letters = <FanLetter>[];
  var _filter = _MePostsFilter.all;
  var _artistTab = 'feed';
  var _artistFeedFilter = _ArtistFeedFilter.all;
  var _loading = true;
  int? _memberCount;
  int? _fanClubRank;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      handleLoad();
    });
  }

  String profileHandle(Profile profile) {
    return ProfileService.normalizeFanHandle(
      profile.name.trim().isNotEmpty ? profile.name : profile.displayName,
    );
  }

  String displayName(Profile profile) {
    final name = profile.displayName.trim().isNotEmpty
        ? profile.displayName.trim()
        : profile.name.trim();
    return name.isEmpty ? 'Artista' : name;
  }

  bool isMediaPost(FeedPost post) {
    return post.type == PostType.image ||
        post.type == PostType.carousel ||
        post.type == PostType.video;
  }

  bool isTextPost(FeedPost post) {
    return post.type == PostType.text;
  }

  List<FeedPost> visibleFanPosts() {
    if (_filter == _MePostsFilter.media) {
      return [for (final post in _posts) if (isMediaPost(post)) post];
    }
    return _posts;
  }

  List<FeedPost> visibleArtistPosts() {
    final base = _artistTab == 'exclusivo'
        ? [for (final post in _posts) if (isExclusivePost(post)) post]
        : _posts;
    if (_artistTab != 'feed') {
      return base;
    }
    return switch (_artistFeedFilter) {
      _ArtistFeedFilter.all => base,
      _ArtistFeedFilter.posts => [
        for (final post in base)
          if (isTextPost(post)) post,
      ],
      _ArtistFeedFilter.media => [
        for (final post in base)
          if (isMediaPost(post)) post,
      ],
    };
  }

  Future<void> handleLoad() async {
    final profile = ref.read(authSessionProvider).profile;
    if (profile == null || profile.userUid.isEmpty) {
      setState(() => _loading = false);
      return;
    }
    setState(() => _loading = true);
    try {
      final handle = profileHandle(profile);
      ProfileOverview? overview;
      if (handle.isNotEmpty) {
        try {
          overview = await ProfileService.getProfileOverview(handle);
        } catch (_) {
          overview = null;
        }
      }
      List<FeedPost> posts = overview?.posts ?? const [];
      if (posts.isEmpty) {
        final items = await ProfileService.getPostsByUserUid(profile.userUid);
        posts = [for (final item in items) item.toFeedPost(owner: profile)];
      }

      var letters = <FanLetter>[];
      int? memberCount;
      int? rank;
      if (profile.isArtist) {
        letters = await FanLetterService.listArtistFanLetters(
          profile.userUid,
        ).then((value) => value, onError: (_) => <FanLetter>[]);
        final club = await FanClubService.getArtistFanClub(profile.userUid)
            .then((value) => value, onError: (_) => null);
        memberCount = club?.memberCount;
        try {
          final rankings = await SearchService.rankArtists(
            'fan-clubs',
            limit: 500,
          );
          for (final item in rankings.artists) {
            if (item.id == profile.userUid) {
              rank = item.rank;
              break;
            }
          }
        } catch (_) {}
      }

      if (!mounted) {
        return;
      }
      setState(() {
        _posts = posts;
        _artists = overview?.followedArtists ?? const [];
        _letters = letters;
        _memberCount = memberCount;
        _fanClubRank = rank;
        _loading = false;
      });
    } catch (_) {
      if (!mounted) {
        return;
      }
      setState(() {
        _posts = [];
        _artists = [];
        _letters = [];
        _loading = false;
      });
    }
  }

  void handleOpenArtists(Profile profile) {
    context.push(
      Pages.profileArtistsOf(
        handle: profile.name.isNotEmpty ? profile.name : profile.displayName,
      ),
    );
  }

  void handleOpenArtist(FollowedArtist artist) {
    final id = artist.id.trim();
    if (id.isEmpty) {
      return;
    }
    context.push(Pages.artistProfile.replaceAll(':artistId', id));
  }

  void handleOpenFanClub(Profile profile) {
    context.push(
      Pages.fanClubCommunityOf(
        profile.userUid,
        name: displayName(profile),
        avatarUrl: profile.photoUrl,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = CrowdFansTheme.of(context);
    final profile = ref.watch(authSessionProvider).profile;
    ref.listen(authSessionProvider, (previous, next) {
      if (previous?.profile?.userUid != next.profile?.userUid ||
          previous?.profile?.isArtist != next.profile?.isArtist) {
        handleLoad();
      }
    });

    if (profile?.isArtist == true) {
      return buildArtistProfile(context, colors, profile!);
    }
    return buildFanProfile(context, colors, profile);
  }

  Widget buildArtistProfile(
    BuildContext context,
    AppColors colors,
    Profile profile,
  ) {
    final posts = visibleArtistPosts();
    return Scaffold(
      backgroundColor: colors.background,
      body: RefreshIndicator(
        onRefresh: () async {
          await ref.read(authSessionProvider.notifier).refreshSession();
          await handleLoad();
        },
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            ArtistMeCover(
              imageUrl: profile.photoUrl,
              displayName: displayName(profile),
              membersLabel: ArtistMeCover.formatMembers(_memberCount),
              rank: _fanClubRank,
              onEditProfile: () => context.push(Pages.profileAccount),
              onJams: () => context.push(Pages.profileWallet),
              onSettings: () => context.push(Pages.profileSettings),
            ),
            ArtistMeTabBar(
              selectedId: _artistTab,
              onSelected: (id) => setState(() => _artistTab = id),
            ),
            if (_artistTab == 'feed')
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                child: Wrap(
                  spacing: 8,
                  children: [
                    ArtistMeFeedFilterChip(
                      label: 'Todos',
                      selected: _artistFeedFilter == _ArtistFeedFilter.all,
                      onPressed: () {
                        setState(() => _artistFeedFilter = _ArtistFeedFilter.all);
                      },
                    ),
                    ArtistMeFeedFilterChip(
                      label: 'Posts',
                      selected: _artistFeedFilter == _ArtistFeedFilter.posts,
                      onPressed: () {
                        setState(
                          () => _artistFeedFilter = _ArtistFeedFilter.posts,
                        );
                      },
                    ),
                    ArtistMeFeedFilterChip(
                      label: 'Media',
                      selected: _artistFeedFilter == _ArtistFeedFilter.media,
                      onPressed: () {
                        setState(
                          () => _artistFeedFilter = _ArtistFeedFilter.media,
                        );
                      },
                    ),
                  ],
                ),
              ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
              child: buildArtistTabBody(colors, profile, posts),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildArtistTabBody(
    AppColors colors,
    Profile profile,
    List<FeedPost> posts,
  ) {
    if (_loading) {
      return const ProfileState(loading: true);
    }
    if (_artistTab == 'cartas') {
      if (_letters.isEmpty) {
        return const ProfileState(
          title: 'Fan letters',
          message: 'Nenhuma fan letter ainda.',
        );
      }
      return Column(
        children: [
          for (final letter in _letters) ...[
            FanLetterCard(letter: letter),
            const SizedBox(height: 12),
          ],
        ],
      );
    }
    if (_artistTab == 'sobre') {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ArtistProfileAboutCard(
            label: 'Bio',
            body: profile.description.trim().isNotEmpty
                ? profile.description
                : 'Você ainda não escreveu uma bio.',
          ),
          const SizedBox(height: 12),
          const ArtistProfileAboutCard(
            label: 'Spotify',
            body:
                'Preview do Spotify vem do cadastro do artista e não é editável aqui.',
          ),
          const SizedBox(height: 12),
          ArtistProfileAboutCard(
            label: 'Fã Clube',
            body: _memberCount != null
                ? '$_memberCount membros'
                : 'Comunidade do artista',
          ),
          const SizedBox(height: 10),
          AppButton(
            label: 'Abrir fã clube',
            variant: AppButtonVariant.outline,
            onPressed: () => handleOpenFanClub(profile),
          ),
        ],
      );
    }
    if (_artistTab == 'fanclub') {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ArtistProfileAboutCard(
            label: 'Fã Clube',
            body: _memberCount != null
                ? '$_memberCount membros'
                : 'Comunidade do artista',
          ),
          const SizedBox(height: 10),
          AppButton(
            label: 'Abrir fã clube',
            onPressed: () => handleOpenFanClub(profile),
          ),
        ],
      );
    }
    if (posts.isEmpty) {
      return ProfileState(
        title: 'Nenhum post',
        message: _artistTab == 'exclusivo'
            ? 'Nenhum post exclusivo ainda.'
            : 'Suas publicações aparecerão aqui.',
      );
    }
    return Column(
      children: [
        for (final post in posts)
          FeedItem(post: post, canAccessExclusive: true),
      ],
    );
  }

  Widget buildFanProfile(
    BuildContext context,
    AppColors colors,
    Profile? profile,
  ) {
    final posts = visibleFanPosts();
    return Scaffold(
      backgroundColor: colors.background,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            await ref.read(authSessionProvider.notifier).refreshSession();
            await handleLoad();
          },
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
            children: [
              MeProfileToolbar(
                onMyPosts: () => context.push(Pages.myPosts),
                onSettings: () => context.push(Pages.profileSettings),
              ),
              const SizedBox(height: 4),
              if (profile == null)
                const ProfileState(
                  title: 'Perfil',
                  message: 'Perfil ainda não carregou.',
                )
              else ...[
                ProfileIdentityBlock(
                  profile: profile,
                  onArtistsTap: () => handleOpenArtists(profile),
                ),
                const SizedBox(height: 18),
                MeProfileActionsRow(
                  onEditProfile: () => context.push(Pages.profileAccount),
                  onMyPosts: () => context.push(Pages.myPosts),
                ),
                if (_artists.isNotEmpty) ...[
                  const SizedBox(height: 20),
                  MeFollowedArtistsSection(
                    artists: _artists,
                    onSeeAll: () => handleOpenArtists(profile),
                    onPressArtist: handleOpenArtist,
                  ),
                ],
              ],
              const SizedBox(height: 28),
              Text(
                'Publicações',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: colors.textPrimary,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  MePostsFilterChip(
                    label: 'Todos',
                    selected: _filter == _MePostsFilter.all,
                    onPressed: () {
                      setState(() => _filter = _MePostsFilter.all);
                    },
                  ),
                  const SizedBox(width: 8),
                  MePostsFilterChip(
                    label: 'Mídia',
                    selected: _filter == _MePostsFilter.media,
                    onPressed: () {
                      setState(() => _filter = _MePostsFilter.media);
                    },
                  ),
                ],
              ),
              const SizedBox(height: 8),
              if (_loading)
                const ProfileState(loading: true)
              else if (posts.isEmpty)
                const ProfileState(
                  title: 'Nenhuma publicação',
                  message: 'As publicações deste perfil aparecerão aqui.',
                )
              else
                for (final post in posts)
                  FeedItem(post: post, canAccessExclusive: true),
            ],
          ),
        ),
      ),
    );
  }
}
