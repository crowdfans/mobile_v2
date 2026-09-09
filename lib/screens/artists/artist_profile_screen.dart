import 'package:crowdfans/api/api_error.dart';
import 'package:crowdfans/components/buttons/app_button.dart';
import 'package:crowdfans/components/fan_letter/fan_letter_card.dart';
import 'package:crowdfans/components/feed/feed_item.dart';
import 'package:crowdfans/components/profile/artist_profile_about_card.dart';
import 'package:crowdfans/components/profile/artist_profile_actions.dart';
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
import 'package:crowdfans/services/sidebar_artists_store.dart';
import 'package:crowdfans/services/subscription_service.dart';
import 'package:crowdfans/services/vote_service.dart';
import 'package:crowdfans/state/auth_session.dart';
import 'package:crowdfans/utils/app_alert.dart';
import 'package:crowdfans/utils/exclusive_content_access.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

enum _ArtistTab { posts, exclusive, cartas, sobre }

/// Perfil público do artista (`artists/:artistId`) — espelho Expo CF-74.
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
  var _following = false;
  var _subscribed = false;
  var _togglingFollow = false;
  var _tab = _ArtistTab.posts;
  int? _memberCount;
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
    final posts = _profile?.stats.postsCount ?? _posts.length;
    final members = _memberCount;
    if (members == null) {
      return '$posts posts';
    }
    return '$posts posts · $members membros';
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
      final following = await FollowService.checkFollow(widget.artistId)
          .then((value) => value, onError: (_) => false);
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
        _following = following;
        _subscribed = check.isSubscribed;
        _memberCount = club?.memberCount;
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

  Future<void> handleSubscribe() async {
    try {
      await SubscriptionService.createSubscription(widget.artistId);
      setState(() => _subscribed = true);
      if (!_following) {
        try {
          await FollowService.followArtist(widget.artistId);
          if (mounted) {
            setState(() => _following = true);
          }
        } catch (_) {}
      }
      if (mounted) {
        await AppAlert.show(
          context,
          title: 'Membership',
          message: 'Assinatura ativa. Posts exclusivos foram liberados.',
        );
      }
    } on ApiError catch (error) {
      if (mounted) {
        await AppAlert.show(
          context,
          title: 'Membership',
          message: error.status == 402
              ? 'Saldo de Jam Coins insuficiente para a membership (100). Recarregue em Jam Coins.'
              : error.message,
        );
      }
    } catch (error) {
      if (mounted) {
        await AppAlert.show(
          context,
          title: 'Membership',
          message: error.toString(),
        );
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

  void handleFanLetter() {
    context.push(
      Pages.fanLetterComposeOf(
        artistId: widget.artistId,
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

  List<FeedPost> visiblePosts() {
    if (_tab == _ArtistTab.exclusive) {
      return [
        for (final post in _posts)
          if (isExclusivePost(post)) post,
      ];
    }
    return _posts;
  }

  @override
  Widget build(BuildContext context) {
    final colors = CrowdFansTheme.of(context);
    final access = exclusiveContext();
    final name = displayName();
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
                        padding: const EdgeInsets.fromLTRB(16, 16, 16, 40),
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
                          ArtistProfileHero(
                            displayName: name,
                            handle: handleLabel(),
                            avatarUrl: avatarUrl(),
                            meta: metaLabel(),
                          ),
                          const SizedBox(height: 16),
                          ArtistProfileActions(
                            following: _following,
                            subscribed: _subscribed,
                            togglingFollow: _togglingFollow,
                            onToggleFollow: handleToggleFollow,
                            onOpenFanClub: handleOpenFanClub,
                            onFanLetter: handleFanLetter,
                            onSubscribe: handleSubscribe,
                          ),
                          const SizedBox(height: 16),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: [
                              ArtistProfileTabChip(
                                label: 'Posts',
                                selected: _tab == _ArtistTab.posts,
                                onPressed: () {
                                  setState(() => _tab = _ArtistTab.posts);
                                },
                              ),
                              ArtistProfileTabChip(
                                label: 'Exclusivo',
                                selected: _tab == _ArtistTab.exclusive,
                                onPressed: () {
                                  setState(() => _tab = _ArtistTab.exclusive);
                                },
                              ),
                              ArtistProfileTabChip(
                                label: 'Cartas',
                                selected: _tab == _ArtistTab.cartas,
                                onPressed: () {
                                  setState(() => _tab = _ArtistTab.cartas);
                                },
                              ),
                              ArtistProfileTabChip(
                                label: 'Sobre',
                                selected: _tab == _ArtistTab.sobre,
                                onPressed: () {
                                  setState(() => _tab = _ArtistTab.sobre);
                                },
                              ),
                            ],
                          ),
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
                            ArtistProfileAboutCard(
                              label: 'Fã Clube',
                              body: _memberCount != null
                                  ? '$_memberCount membros'
                                  : 'Sem dados de membros ainda.',
                            ),
                            const SizedBox(height: 10),
                            AppButton(
                              label: 'Abrir comunidade',
                              variant: AppButtonVariant.outline,
                              onPressed: handleOpenFanClub,
                            ),
                          ] else if (visiblePosts().isEmpty)
                            ProfileState(
                              title: 'Nenhum post',
                              message: _tab == _ArtistTab.exclusive
                                  ? 'Nenhum post exclusivo ainda.'
                                  : 'Este artista ainda não publicou posts.',
                            )
                          else
                            for (final post in visiblePosts())
                              FeedItem(
                                post: post,
                                canAccessExclusive: canAccessExclusivePost(
                                  post,
                                  access,
                                ),
                                onPressUnlock: _subscribed
                                    ? null
                                    : handleSubscribe,
                                onVoteApplied: handleVoteApplied,
                              ),
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
