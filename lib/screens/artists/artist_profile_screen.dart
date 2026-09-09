import 'package:crowdfans/api/api_error.dart';
import 'package:crowdfans/components/buttons/app_button.dart';
import 'package:crowdfans/components/feed/feed_item.dart';
import 'package:crowdfans/components/profile/artist_me_feed_filter_chip.dart';
import 'package:crowdfans/components/profile/artist_me_tab_bar.dart';
import 'package:crowdfans/components/profile/artist_profile_exclusive_teaser.dart';
import 'package:crowdfans/components/profile/artist_profile_letter_tile.dart';
import 'package:crowdfans/components/profile/artist_profile_public_cover.dart';
import 'package:crowdfans/components/profile/artist_profile_spotify_card.dart';
import 'package:crowdfans/components/profile/artist_profile_stat_tile.dart';
import 'package:crowdfans/components/profile/profile_state.dart';
import 'package:crowdfans/constants/pages.dart';
import 'package:crowdfans/constants/theme.dart';
import 'package:crowdfans/models/feed_post.dart';
import 'package:crowdfans/models/home_feed.dart';
import 'package:crowdfans/models/profile.dart';
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
  var _subscribed = false;
  var _togglingMembership = false;
  var _tab = 'feed';
  var _feedFilter = _FeedFilter.all;
  int? _memberCount;
  int? _fanClubRank;
  String? _error;

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

  Future<void> handleLoad() async {
    setState(() {
      _loading = true;
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
      final club = await FanClubService.getArtistFanClub(widget.artistId)
          .then((value) => value, onError: (_) => null);
      final letters = await FanLetterService.listArtistFanLetters(
        widget.artistId,
      ).then((value) => value, onError: (_) => <FanLetter>[]);
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
      setState(() {
        _profile = profile;
        _posts = posts;
        _letters = letters;
        _subscribed = check.isSubscribed;
        _memberCount = club?.memberCount;
        _fanClubRank = rank;
        _loading = false;
        _error = null;
      });
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

  Future<void> handleToggleMembership() async {
    if (_togglingMembership) {
      return;
    }
    setState(() => _togglingMembership = true);
    try {
      if (_subscribed) {
        await SubscriptionService.cancelSubscription(widget.artistId);
        setState(() => _subscribed = false);
      } else {
        await SubscriptionService.createSubscription(widget.artistId);
        setState(() => _subscribed = true);
        try {
          await FollowService.followArtist(widget.artistId);
        } catch (_) {}
      }
    } on ApiError catch (error) {
      if (mounted) {
        await AppAlert.show(
          context,
          title: 'Assinatura',
          message: error.status == 402
              ? 'Saldo de Jam Coins insuficiente para a membership (100). Recarregue em Jam Coins.'
              : error.message,
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

  void handleReport() {
    context.push(
      '${Pages.report}?context=artist-profile&targetId=${Uri.encodeComponent(widget.artistId)}&displayName=${Uri.encodeComponent(displayName())}',
    );
  }

  Future<void> handleMore() async {
    final colors = CrowdFansTheme.of(context);
    await showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (sheetContext) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: Icon(Icons.flag_outlined, color: colors.textPrimary),
                title: Text(
                  'Denunciar',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: colors.textPrimary,
                  ),
                ),
                onTap: () {
                  Navigator.of(sheetContext).pop();
                  handleReport();
                },
              ),
              ListTile(
                leading: Icon(Icons.groups_outlined, color: colors.textPrimary),
                title: Text(
                  'Abrir fã clube',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: colors.textPrimary,
                  ),
                ),
                onTap: () {
                  Navigator.of(sheetContext).pop();
                  handleOpenFanClub();
                },
              ),
            ],
          ),
        );
      },
    );
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
      if (_letters.isEmpty) {
        return const ProfileState(
          title: 'Fan letters',
          message: 'Nenhuma fan letter ainda.',
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
          return ArtistProfileLetterTile(letter: _letters[index]);
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
              const Expanded(
                child: ArtistProfileStatTile(
                  label: 'Base',
                  value: 'Brasil',
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
          const ArtistProfileSpotifyCard(),
          const SizedBox(height: 14),
          AppButton(
            label: 'Abrir fã clube',
            variant: AppButtonVariant.outline,
            onPressed: handleOpenFanClub,
          ),
        ],
      );
    }

    if (_tab == 'fanclub') {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ArtistProfileStatTile(
            label: 'Fã Clube',
            value: membersLabel(),
          ),
          const SizedBox(height: 12),
          AppButton(
            label: 'Abrir fã clube',
            onPressed: handleOpenFanClub,
          ),
        ],
      );
    }

    if (_tab == 'exclusivo' && !_subscribed) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ArtistProfileExclusiveTeaser(
            artistName: name,
            onSubscribe: handleToggleMembership,
          ),
          if (posts.isNotEmpty) ...[
            const SizedBox(height: 16),
            for (final post in posts)
              FeedItem(
                post: post,
                canAccessExclusive: canAccessExclusivePost(post, access),
                onPressUnlock: handleToggleMembership,
                onVoteApplied: handleVoteApplied,
              ),
          ],
        ],
      );
    }

    if (posts.isEmpty) {
      return ProfileState(
        title: 'Nenhum post',
        message: _tab == 'exclusivo'
            ? 'Nenhum post exclusivo ainda.'
            : 'Este artista ainda não publicou posts.',
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
    return Scaffold(
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
                    subscribed: _subscribed,
                    busy: _togglingMembership,
                    onBack: handleBack,
                    onMore: handleMore,
                    onToggleFollow: handleToggleMembership,
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
                              setState(() => _feedFilter = _FeedFilter.posts);
                            },
                          ),
                          ArtistMeFeedFilterChip(
                            label: 'Media',
                            selected: _feedFilter == _FeedFilter.media,
                            onPressed: () {
                              setState(() => _feedFilter = _FeedFilter.media);
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
    );
  }
}
