import 'package:crowdfans/api/api_error.dart';
import 'package:crowdfans/components/artists/artist_profile_options_sheet.dart';
import 'package:crowdfans/components/buttons/app_button.dart';
import 'package:crowdfans/components/feed/feed_item.dart';
import 'package:crowdfans/components/profile/artist_me_feed_filter_chip.dart';
import 'package:crowdfans/components/profile/artist_me_tab_bar.dart';
import 'package:crowdfans/components/profile/artist_profile_exclusive_teaser.dart';
import 'package:crowdfans/components/profile/artist_profile_fan_club_feed.dart';
import 'package:crowdfans/components/profile/artist_profile_fan_club_header.dart';
import 'package:crowdfans/components/profile/artist_profile_fan_club_toolbar.dart';
import 'package:crowdfans/components/profile/artist_profile_letter_tile.dart';
import 'package:crowdfans/components/profile/artist_profile_public_cover.dart';
import 'package:crowdfans/components/profile/artist_profile_social_links_card.dart';
import 'package:crowdfans/components/profile/artist_profile_spotify_card.dart';
import 'package:crowdfans/components/profile/artist_profile_stat_tile.dart';
import 'package:crowdfans/components/profile/artist_sobre_base.dart';
import 'package:crowdfans/components/profile/profile_state.dart';
import 'package:crowdfans/constants/pages.dart';
import 'package:crowdfans/constants/theme.dart';
import 'package:crowdfans/mocks/cf_temp_mocks.dart';
import 'package:crowdfans/models/feed_post.dart';
import 'package:crowdfans/models/home_feed.dart';
import 'package:crowdfans/models/profile.dart';
import 'package:crowdfans/services/community_service.dart';
import 'package:crowdfans/services/fan_club_service.dart';
import 'package:crowdfans/services/fan_letter_service.dart';
import 'package:crowdfans/services/follow_service.dart';
import 'package:crowdfans/services/profile_service.dart';
import 'package:crowdfans/services/search_service.dart';
import 'package:crowdfans/services/sidebar_artists_store.dart';
import 'package:crowdfans/services/subscription_service.dart';
import 'package:crowdfans/services/vote_service.dart';
import 'package:crowdfans/state/auth_session.dart';
import 'package:crowdfans/utils/app_alert.dart';
import 'package:crowdfans/utils/exclusive_content_access.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

enum _FeedFilter { all, posts, media }

/// Perfil público do artista — cover overlay dos prints Perfil Artista.
class ArtistProfileScreen extends ConsumerStatefulWidget {
  const ArtistProfileScreen({
    super.key,
    required this.artistId,
    this.seedName,
    this.seedAvatarUrl,
  });

  final String artistId;
  final String? seedName;
  final String? seedAvatarUrl;

  @override
  ConsumerState<ArtistProfileScreen> createState() =>
      _ArtistProfileScreenState();
}

class _ArtistProfileScreenState extends ConsumerState<ArtistProfileScreen> {
  Profile? _profile;
  var _posts = <FeedPost>[];
  var _letters = <FanLetter>[];
  var _loading = true;
  var _lettersError = false;
  var _subscribed = false;
  var _subscriptionResolved = false;
  var _following = false;
  var _togglingMembership = false;
  var _togglingFollow = false;
  var _tab = 'feed';
  var _feedFilter = _FeedFilter.all;
  var _clubPosts = <FeedPost>[];
  var _clubLoading = false;
  var _clubSortPopular = false;
  var _clubFilter = ArtistProfileFanClubFilter.all;
  int? _memberCount;
  int? _fanClubRank;
  String? _error;
  var _menuOpen = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      handleLoad();
    });
  }

  String displayName() {
    final profile = _profile;
    final fromProfile = profile?.displayName.trim().isNotEmpty == true
        ? profile!.displayName.trim()
        : (profile?.name.trim() ?? '');
    if (fromProfile.isNotEmpty) {
      return fromProfile;
    }
    final seed = Uri.decodeComponent(widget.seedName ?? '').trim();
    return seed.isEmpty ? 'Artista' : seed;
  }

  String avatarUrl() {
    final fromProfile = _profile?.photoUrl.trim() ?? '';
    if (fromProfile.isNotEmpty) {
      return fromProfile;
    }
    return Uri.decodeComponent(widget.seedAvatarUrl ?? '').trim();
  }

  String membersLabel() {
    return ArtistProfilePublicCover.formatMembers(_memberCount);
  }

  FeedPost mapClubFeedPost(FanClubFeedPost post, ArtistFanClub club) {
    final created = DateTime.tryParse(post.createdAt);
    final minutes = created == null
        ? 0
        : DateTime.now().difference(created).inMinutes.clamp(0, 999999);
    return FeedPost(
      id: post.postId,
      type: postTypeFrom(post.type),
      author: club.artistName,
      artistId: club.artistUid,
      handle: club.artistName.toLowerCase().replaceAll(RegExp(r'\s+'), ''),
      minutesAgo: minutes,
      avatarUri: avatarUrl(),
      text: post.content.isEmpty ? (post.title ?? '') : post.content,
      imageUri: post.imageUrl,
      votes: post.likesCount,
      comments: post.commentsCount,
      shares: 0,
      isExclusive: post.isExclusive,
      exclusiveLocked: post.isExclusive,
    );
  }

  List<FeedPost> mergeClubPosts(List<FeedPost> fromFeed, List<FeedPost> extra) {
    final seen = <String>{};
    final merged = <FeedPost>[];
    for (final post in [...fromFeed, ...extra]) {
      if (seen.contains(post.id)) {
        continue;
      }
      seen.add(post.id);
      merged.add(post);
    }
    return merged;
  }

  Future<void> handleLoadClubFeed() async {
    setState(() => _clubLoading = true);
    try {
      final results = await Future.wait([
        FanClubService.getArtistFanClubFeed(
          widget.artistId,
          page: 1,
          pageSize: 40,
        ).then((value) => value, onError: (_) => null),
        CommunityService.getCommunityPosts(page: 1, pageSize: 50)
            .then((value) => value, onError: (_) => <CommunityPost>[]),
      ]);
      final feed = results[0] as ArtistFanClubFeed?;
      final community = results[1] as List<CommunityPost>;
      final club = feed?.fanClub;
      final fromFeed = [
        if (club != null)
          for (final post in feed?.posts ?? const <FanClubFeedPost>[])
            mapClubFeedPost(post, club),
      ];
      final fromCommunity = [
        for (final post in community)
          if (post.targetArtistId == widget.artistId) post.toFeedPost(),
      ];
      if (!mounted) {
        return;
      }
      setState(() {
        _clubPosts = mergeClubPosts(fromFeed, fromCommunity);
        if (club != null) {
          _memberCount = club.memberCount;
        }
        _clubLoading = false;
      });
    } catch (_) {
      if (!mounted) {
        return;
      }
      setState(() => _clubLoading = false);
    }
  }

  Future<void> handleLoad() async {
    setState(() {
      _loading = true;
      _subscriptionResolved = false;
      _error = null;
    });
    try {
      final profile = await ProfileService.getProfileByUserUid(widget.artistId)
          .then<Profile?>((value) => value, onError: (_) => null);
      final postItems = await ProfileService.getPostsByUserUid(widget.artistId);
      final check = await SubscriptionService.checkSubscription(widget.artistId)
          .then(
            (value) => value,
            onError: (_) => const SubscriptionCheck(isSubscribed: false),
          );
      final isFollowing = await FollowService.checkFollow(widget.artistId)
          .then((value) => value, onError: (_) => false);
      final club = await FanClubService.getArtistFanClub(widget.artistId)
          .then((value) => value, onError: (_) => null);
      final lettersResult = await FanLetterService.listArtistFanLetters(
        widget.artistId,
      ).then(
        (value) => (letters: value, error: false),
        onError: (_) => (letters: <FanLetter>[], error: true),
      );
      ArtistSearchResponse? rankings;
      try {
        rankings = await SearchService.rankArtists('fan-clubs', limit: 500);
      } catch (_) {
        rankings = null;
      }
      int? rank;
      for (final item in rankings?.artists ?? const <ArtistSearchItem>[]) {
        if (item.id == widget.artistId) {
          rank = item.rank;
          break;
        }
      }
      final fallbackOwner = Profile(
        userUid: widget.artistId,
        displayName: displayName(),
        name: displayName(),
        description: '',
        photoUrl: avatarUrl(),
        isArtist: true,
      );
      final owner = profile ?? fallbackOwner;
      final posts = [
        for (final item in postItems) item.toFeedPost(owner: owner),
      ];
      if (!mounted) {
        return;
      }
      // CF-181: grade do print quando API vazia — sem mascarar erro de rede.
      var letters = lettersResult.letters;
      final lettersError = lettersResult.error;
      if (!lettersError &&
          letters.isEmpty &&
          kUseCfTempMocks &&
          kUseCf181CartasMocks) {
        letters = Cf181CartasMock.letters(artistId: widget.artistId);
      }
      setState(() {
        _profile = profile;
        _posts = posts;
        _letters = letters;
        _lettersError = lettersError;
        _subscribed = check.isSubscribed;
        _subscriptionResolved = true;
        _following = isFollowing;
        _memberCount = club?.memberCount;
        _fanClubRank = rank;
        _loading = false;
        _error = null;
      });
      await handleLoadClubFeed();
      if (profile != null) {
        await SidebarArtistsStore.recordVisit(
          HomeFollowedArtist(
            id: widget.artistId,
            username: profile.name,
            avatarUrl: profile.photoUrl,
          ),
        );
      }
    } catch (_) {
      if (!mounted) {
        return;
      }
      setState(() {
        _loading = false;
        _subscriptionResolved = true;
        _subscribed = false;
        _error = 'Não foi possível carregar o perfil do artista.';
      });
    }
  }

  ExclusiveAccessContext exclusiveContext() {
    final viewer = ref.read(authSessionProvider).profile;
    return ExclusiveAccessContext(
      subscribedArtistUids: {if (_subscribed) widget.artistId},
      subscribedArtistNames: {
        if (_subscribed) normalizeExclusiveIdentity(displayName()),
      },
      viewerDisplayName: viewer?.displayName ?? viewer?.name,
      viewerUserUid: viewer?.userUid,
      viewerIsArtist: viewer?.isArtist ?? false,
    );
  }

  Future<void> handleToggleFollow() async {
    if (_togglingFollow) {
      return;
    }
    setState(() => _togglingFollow = true);
    try {
      if (_following) {
        await FollowService.unfollowArtist(widget.artistId);
        setState(() => _following = false);
      } else {
        await FollowService.followArtist(widget.artistId);
        setState(() => _following = true);
      }
    } on ApiError catch (error) {
      if (mounted) {
        await AppAlert.show(
          context,
          title: 'Seguir',
          message: error.message,
        );
      }
    } catch (error) {
      if (mounted) {
        await AppAlert.show(
          context,
          title: 'Seguir',
          message: error.toString(),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _togglingFollow = false);
      }
    }
  }

  Future<void> handleToggleMembership() async {
    if (_togglingMembership) {
      return;
    }
    if (!_subscribed) {
      handleOpenMembershipSubscribe();
      return;
    }
    setState(() => _togglingMembership = true);
    try {
      await SubscriptionService.cancelSubscription(widget.artistId);
      setState(() => _subscribed = false);
    } on ApiError catch (error) {
      if (mounted) {
        await AppAlert.show(
          context,
          title: 'Assinatura',
          message: error.message,
        );
      }
    } catch (error) {
      if (mounted) {
        await AppAlert.show(
          context,
          title: 'Assinatura',
          message: error.toString(),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _togglingMembership = false);
      }
    }
  }

  void handleOpenMembershipSubscribe() {
    final handle = _profile?.name.trim() ?? '';
    context.push(
      Pages.profileMembershipSubscribeOf(
        artistId: widget.artistId,
        artistName: displayName(),
        artistHandle: handle,
        artistAvatarUrl: avatarUrl(),
        pricePerMonth: 100,
      ),
    );
  }

  void handleOpenMembershipManage() {
    context.push(
      Pages.profileMembershipManageOf(
        artistId: widget.artistId,
        artistName: displayName(),
        artistHandle: _profile?.name.trim() ?? '',
        artistAvatarUrl: avatarUrl(),
      ),
    );
  }

  void handleOpenFanClub() {
    context.push(
      Pages.fanClubCommunityOf(
        widget.artistId,
        name: displayName(),
        avatarUrl: avatarUrl(),
      ),
    );
  }

  void handleBack() {
    if (context.canPop()) {
      context.pop();
      return;
    }
    context.go(Pages.home);
  }

  void handleMore() {
    setState(() => _menuOpen = true);
  }

  void handleVoteApplied(VoteResult result) {
    setState(() {
      _posts = [
        for (final item in _posts)
          if (item.id == result.id)
            item.copyWith(votes: result.votes, myVote: result.myVote)
          else
            item,
      ];
      _clubPosts = [
        for (final item in _clubPosts)
          if (item.id == result.id)
            item.copyWith(votes: result.votes, myVote: result.myVote)
          else
            item,
      ];
    });
  }

  bool isTextPost(FeedPost post) {
    return post.type == PostType.text;
  }

  bool isMediaPost(FeedPost post) {
    return post.type == PostType.image ||
        post.type == PostType.carousel ||
        post.type == PostType.video;
  }

  List<FeedPost> feedPosts() {
    final base = _tab == 'exclusivo'
        ? [
            for (final post in _posts)
              if (isExclusivePost(post)) post,
          ]
        : _posts;
    if (_tab != 'feed') {
      return base;
    }
    return switch (_feedFilter) {
      _FeedFilter.all => base,
      _FeedFilter.posts => [for (final post in base) if (isTextPost(post)) post],
      _FeedFilter.media => [for (final post in base) if (isMediaPost(post)) post],
    };
  }

  Widget buildTabBody(AppColors colors, List<FeedPost> posts) {
    final access = exclusiveContext();
    final name = displayName();

    if (_tab == 'cartas') {
      if (_lettersError) {
        return const ProfileState(
          title: 'Cartas',
          message: 'Não foi possível carregar as cartas.',
        );
      }
      if (_letters.isEmpty) {
        // CF-181: vazio em PT (print); sem título EN "Fan letters".
        return const ProfileState(
          title: 'Cartas',
          message: 'Nenhuma carta ainda.',
        );
      }
      return GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: _letters.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          crossAxisSpacing: 8,
          mainAxisSpacing: 8,
          childAspectRatio: 3 / 4,
        ),
        itemBuilder: (context, index) {
          return ArtistProfileLetterTile(
            letter: _letters[index],
            position: index + 1,
          );
        },
      );
    }

    if (_tab == 'sobre') {
      final bio = _profile?.description.trim().isNotEmpty == true
          ? _profile!.description
          : 'Este artista ainda não escreveu uma bio.';
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Sobre',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: colors.textPrimary,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            bio,
            style: TextStyle(
              fontSize: 14,
              height: 1.45,
              color: colors.textSecondary,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: ArtistProfileStatTile(
                  label: 'Base',
                  value: artistSobreBaseLabel(null),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: ArtistProfileStatTile(
                  label: 'Fã Clube',
                  value: membersLabel(),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          ArtistProfileSpotifyCard(artistName: name),
          const SizedBox(height: 14),
          const ArtistProfileSocialLinksCard(),
        ],
      );
    }

    if (_tab == 'fanclub') {
      final clubPosts = artistProfileFanClubVisiblePosts(
        posts: _clubPosts,
        sortPopular: _clubSortPopular,
        filter: _clubFilter,
      );
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ArtistProfileFanClubHeader(
            artistName: name,
            avatarUrl: avatarUrl(),
            memberCount: _memberCount,
          ),
          const SizedBox(height: 12),
          ArtistProfileFanClubToolbar(
            sortPopular: _clubSortPopular,
            filter: _clubFilter,
            onSortPopular: (value) => setState(() => _clubSortPopular = value),
            onFilter: (value) => setState(() => _clubFilter = value),
          ),
          const SizedBox(height: 12),
          if (_clubLoading)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 32),
              child: Center(child: CircularProgressIndicator()),
            )
          else if (clubPosts.isEmpty)
            const ProfileState(
              title: 'Nenhum post',
              message: 'Ainda não há publicações neste fã-clube.',
            )
          else
            for (final post in clubPosts)
              FeedItem(
                post: post,
                canAccessExclusive: canAccessExclusivePost(post, access),
                onPressUnlock: _subscribed ? null : handleToggleMembership,
                onVoteApplied: handleVoteApplied,
              ),
        ],
      );
    }

    if (_tab == 'exclusivo') {
      if (!_subscriptionResolved) {
        return const Padding(
          padding: EdgeInsets.symmetric(vertical: 40),
          child: Center(child: CircularProgressIndicator()),
        );
      }
      if (!_subscribed) {
        // Um único card de membership — sem posts bloqueados redundantes (CF-184).
        return ArtistProfileExclusiveTeaser(
          artistName: name,
          onSubscribe: handleToggleMembership,
        );
      }
      // Assinante: posts exclusivos sem CTA de compra.
      if (posts.isEmpty) {
        return const ProfileState(
          title: 'Nenhum post',
          message: 'Nenhum post exclusivo ainda.',
        );
      }
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (final post in posts)
            FeedItem(
              post: post,
              canAccessExclusive: true,
              onVoteApplied: handleVoteApplied,
            ),
        ],
      );
    }

    if (posts.isEmpty) {
      return ProfileState(
        title: 'Nenhum post',
        message: 'Este artista ainda não publicou posts.',
      );
    }

    return Column(
      children: [
        for (final post in posts)
          FeedItem(
            post: post,
            canAccessExclusive: canAccessExclusivePost(post, access),
            onPressUnlock: _subscribed ? null : handleToggleMembership,
            onVoteApplied: handleVoteApplied,
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = CrowdFansTheme.of(context);
    final name = displayName();
    final avatar = avatarUrl();
    final posts = feedPosts();
    return Stack(
      children: [
        Scaffold(
          backgroundColor: colors.background,
          body: _loading
              ? const Center(child: CircularProgressIndicator())
              : RefreshIndicator(
                  onRefresh: handleLoad,
                  child: ListView(
                    padding: EdgeInsets.zero,
                    children: [
                      ArtistProfilePublicCover(
                        imageUrl: avatar,
                        displayName: name,
                        membersLabel: membersLabel(),
                        rank: _fanClubRank,
                        following: _following,
                        subscribed: _subscribed,
                        busy: _togglingFollow || _togglingMembership,
                        onBack: handleBack,
                        onMore: handleMore,
                        onToggleFollow: handleToggleFollow,
                        onMembership: () {
                          if (_subscribed) {
                            handleOpenMembershipManage();
                          } else {
                            handleOpenMembershipSubscribe();
                          }
                        },
                      ),
                      if (_error != null)
                        Padding(
                          padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                          child: Column(
                            children: [
                              Text(
                                _error!,
                                textAlign: TextAlign.center,
                                style: TextStyle(color: colors.textSecondary),
                              ),
                              const SizedBox(height: 12),
                              AppButton(
                                label: 'Tentar novamente',
                                onPressed: handleLoad,
                              ),
                            ],
                          ),
                        ),
                      ArtistMeTabBar(
                        selectedId: _tab,
                        onSelected: (id) => setState(() => _tab = id),
                      ),
                      if (_tab == 'feed')
                        Padding(
                          padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                          child: Wrap(
                            spacing: 8,
                            children: [
                              ArtistMeFeedFilterChip(
                                label: 'Todos',
                                selected: _feedFilter == _FeedFilter.all,
                                onPressed: () {
                                  setState(() => _feedFilter = _FeedFilter.all);
                                },
                              ),
                              ArtistMeFeedFilterChip(
                                label: 'Posts',
                                selected: _feedFilter == _FeedFilter.posts,
                                onPressed: () {
                                  setState(
                                    () => _feedFilter = _FeedFilter.posts,
                                  );
                                },
                              ),
                              ArtistMeFeedFilterChip(
                                label: 'Media',
                                selected: _feedFilter == _FeedFilter.media,
                                onPressed: () {
                                  setState(
                                    () => _feedFilter = _FeedFilter.media,
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 12, 16, 40),
                        child: buildTabBody(colors, posts),
                      ),
                    ],
                  ),
                ),
        ),
        ArtistProfileOptionsSheet(
          visible: _menuOpen,
          artistId: widget.artistId,
          artistName: name,
          onClose: () => setState(() => _menuOpen = false),
          onOpenFanClub: handleOpenFanClub,
        ),
      ],
    );
  }
}
