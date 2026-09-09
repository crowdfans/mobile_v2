import 'package:crowdfans/api/api_error.dart';
import 'package:crowdfans/components/buttons/app_button.dart';
import 'package:crowdfans/components/fan_letter/fan_letter_card.dart';
import 'package:crowdfans/components/feed/feed_item.dart';
import 'package:crowdfans/components/profile/artist_profile_about_card.dart';
import 'package:crowdfans/components/profile/artist_profile_cover.dart';
import 'package:crowdfans/components/profile/artist_profile_cta_pill.dart';
import 'package:crowdfans/components/profile/artist_profile_feed_filter_chip.dart';
import 'package:crowdfans/components/profile/artist_profile_hero.dart';
import 'package:crowdfans/components/profile/artist_profile_tab_chip.dart';
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

enum _ArtistTab { feed, sobre, exclusive, fanclub, cartas }

enum _FeedFilter { all, posts, media }

/// Perfil público do artista — espelho Expo `origin/prod` CF-74.
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
  var _tab = _ArtistTab.feed;
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

  String handleLabel() {
    final slug = displayName().toLowerCase().replaceAll(RegExp(r'\s+'), '');
    return 'artist/$slug';
  }

  String metaLabel() {
    final members = _memberCount;
    if (members != null) {
      return '$members membros';
    }
    final posts = _profile?.stats.postsCount ?? _posts.length;
    return '$posts posts';
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

  /// Espelho Expo: o pill “+ Seguir” liga/desliga membership.
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

  void handleReport() {
    context.push(
      '${Pages.report}?context=artist-profile&targetId=${Uri.encodeComponent(widget.artistId)}&displayName=${Uri.encodeComponent(displayName())}',
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
    final base = _tab == _ArtistTab.exclusive
        ? [
            for (final post in _posts)
              if (isExclusivePost(post)) post,
          ]
        : _posts;
    if (_tab != _ArtistTab.feed) {
      return base;
    }
    return switch (_feedFilter) {
      _FeedFilter.all => base,
      _FeedFilter.posts => [for (final post in base) if (isTextPost(post)) post],
      _FeedFilter.media => [for (final post in base) if (isMediaPost(post)) post],
    };
  }

  @override
  Widget build(BuildContext context) {
    final colors = CrowdFansTheme.of(context);
    final access = exclusiveContext();
    final name = displayName();
    final avatar = avatarUrl();
    final posts = feedPosts();
    return Scaffold(
      backgroundColor: colors.background,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  TextButton(
                    onPressed: () {
                      if (context.canPop()) {
                        context.pop();
                        return;
                      }
                      context.go(Pages.home);
                    },
                    child: Text(
                      'Voltar',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: colors.primary,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      'Artista',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: colors.textPrimary,
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: handleReport,
                    child: Text(
                      'Denunciar',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: colors.primary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: _loading
                  ? const Center(child: CircularProgressIndicator())
                  : RefreshIndicator(
                      onRefresh: handleLoad,
                      child: ListView(
                        padding: const EdgeInsets.fromLTRB(16, 8, 16, 40),
                        children: [
                          if (_error != null) ...[
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
                            const SizedBox(height: 16),
                          ],
                          ArtistProfileCover(imageUrl: avatar),
                          const SizedBox(height: 16),
                          ArtistProfileHero(
                            displayName: name,
                            handle: handleLabel(),
                            avatarUrl: avatar,
                            meta: metaLabel(),
                            rank: _fanClubRank,
                          ),
                          const SizedBox(height: 16),
                          ArtistProfileCtaPill(
                            subscribed: _subscribed,
                            busy: _togglingMembership,
                            onPressed: handleToggleMembership,
                          ),
                          const SizedBox(height: 16),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: [
                              for (final entry in const [
                                (_ArtistTab.feed, 'Feed'),
                                (_ArtistTab.sobre, 'Sobre'),
                                (_ArtistTab.exclusive, 'Exclusivo'),
                                (_ArtistTab.fanclub, 'Fã Clube'),
                                (_ArtistTab.cartas, 'Cartas'),
                              ])
                                ArtistProfileTabChip(
                                  label: entry.$2,
                                  selected: _tab == entry.$1,
                                  onPressed: () {
                                    setState(() => _tab = entry.$1);
                                  },
                                ),
                            ],
                          ),
                          if (_tab == _ArtistTab.feed) ...[
                            const SizedBox(height: 12),
                            Wrap(
                              spacing: 8,
                              children: [
                                ArtistProfileFeedFilterChip(
                                  label: 'Todos',
                                  selected: _feedFilter == _FeedFilter.all,
                                  onPressed: () {
                                    setState(() => _feedFilter = _FeedFilter.all);
                                  },
                                ),
                                ArtistProfileFeedFilterChip(
                                  label: 'Posts',
                                  selected: _feedFilter == _FeedFilter.posts,
                                  onPressed: () {
                                    setState(
                                      () => _feedFilter = _FeedFilter.posts,
                                    );
                                  },
                                ),
                                ArtistProfileFeedFilterChip(
                                  label: 'Mídia',
                                  selected: _feedFilter == _FeedFilter.media,
                                  onPressed: () {
                                    setState(
                                      () => _feedFilter = _FeedFilter.media,
                                    );
                                  },
                                ),
                              ],
                            ),
                          ],
                          const SizedBox(height: 16),
                          if (_tab == _ArtistTab.cartas)
                            if (_letters.isEmpty)
                              const ProfileState(
                                title: 'Fan letters',
                                message: 'Nenhuma fan letter ainda.',
                              )
                            else
                              for (final letter in _letters) ...[
                                FanLetterCard(letter: letter),
                                const SizedBox(height: 12),
                              ]
                          else if (_tab == _ArtistTab.sobre) ...[
                            ArtistProfileAboutCard(
                              label: 'Bio',
                              body:
                                  _profile?.description.trim().isNotEmpty ==
                                      true
                                  ? _profile!.description
                                  : 'Este artista ainda não escreveu uma bio.',
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
                              onPressed: handleOpenFanClub,
                            ),
                          ] else if (_tab == _ArtistTab.fanclub) ...[
                            ArtistProfileAboutCard(
                              label: 'Fã Clube',
                              body: _memberCount != null
                                  ? '$_memberCount membros'
                                  : 'Comunidade do artista',
                            ),
                            const SizedBox(height: 10),
                            AppButton(
                              label: 'Abrir fã clube',
                              onPressed: handleOpenFanClub,
                            ),
                          ] else ...[
                            if (_tab == _ArtistTab.exclusive && !_subscribed) ...[
                              ArtistProfileAboutCard(
                                label: 'Conteúdo exclusivo',
                                body:
                                    'Assine a membership para ver posts exclusivos deste artista.',
                              ),
                              const SizedBox(height: 10),
                              AppButton(
                                label: 'Assinar membership',
                                onPressed: handleToggleMembership,
                              ),
                              const SizedBox(height: 16),
                            ],
                            if (posts.isEmpty)
                              ProfileState(
                                title: 'Nenhum post',
                                message: _tab == _ArtistTab.exclusive
                                    ? 'Nenhum post exclusivo ainda.'
                                    : 'Este artista ainda não publicou posts.',
                              )
                            else
                              for (final post in posts)
                                FeedItem(
                                  post: post,
                                  canAccessExclusive: canAccessExclusivePost(
                                    post,
                                    access,
                                  ),
                                  onPressUnlock: _subscribed
                                      ? null
                                      : handleToggleMembership,
                                  onVoteApplied: handleVoteApplied,
                                ),
                          ],
                        ],
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
