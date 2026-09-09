import 'package:crowdfans/api/api_error.dart';
import 'package:crowdfans/components/buttons/app_button.dart';
import 'package:crowdfans/components/fan_letter/fan_letter_card.dart';
import 'package:crowdfans/components/feed/feed_item.dart';
import 'package:crowdfans/components/post/post_avatar.dart';
import 'package:crowdfans/components/profile/artist_profile_tab_chip.dart';
import 'package:crowdfans/components/profile/profile_screen_header.dart';
import 'package:crowdfans/components/profile/profile_state.dart';
import 'package:crowdfans/constants/pages.dart';
import 'package:crowdfans/constants/theme.dart';
import 'package:crowdfans/models/feed_post.dart';
import 'package:crowdfans/models/home_feed.dart';
import 'package:crowdfans/models/profile.dart';
import 'package:crowdfans/services/fan_letter_service.dart';
import 'package:crowdfans/services/follow_service.dart';
import 'package:crowdfans/services/profile_service.dart';
import 'package:crowdfans/services/sidebar_artists_store.dart';
import 'package:crowdfans/services/subscription_service.dart';
import 'package:crowdfans/state/auth_session.dart';
import 'package:crowdfans/utils/app_alert.dart';
import 'package:crowdfans/utils/exclusive_content_access.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

enum _ArtistTab { posts, exclusive, cartas, sobre }

/// Perfil público do artista (`artists/:artistId`).
class ArtistProfileScreen extends ConsumerStatefulWidget {
  const ArtistProfileScreen({super.key, required this.artistId});

  final String artistId;

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
  var _tab = _ArtistTab.posts;
  String? _error;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      handleLoad();
    });
  }

  Future<void> handleLoad() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final profile = await ProfileService.getProfileByUserUid(widget.artistId);
      final posts = await ProfileService.getPostsByUserUid(widget.artistId);
      final following = await FollowService.checkFollow(widget.artistId)
          .then((value) => value, onError: (_) => false);
      final check = await SubscriptionService.checkSubscription(widget.artistId)
          .then(
            (value) => value,
            onError: (_) => const SubscriptionCheck(isSubscribed: false),
          );
      final letters = await FanLetterService.listArtistFanLetters(
        widget.artistId,
      ).then((value) => value, onError: (_) => <FanLetter>[]);
      setState(() {
        _profile = profile;
        _posts = [for (final item in posts) item.toFeedPost(owner: profile)];
        _letters = letters;
        _following = following;
        _subscribed = check.isSubscribed;
      });
      await SidebarArtistsStore.recordVisit(
        HomeFollowedArtist(
          id: widget.artistId,
          username: profile.name,
          avatarUrl: profile.photoUrl,
        ),
      );
    } catch (_) {
      setState(() => _error = 'Não foi possível carregar o artista.');
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  ExclusiveAccessContext exclusiveContext() {
    final viewer = ref.read(authSessionProvider).profile;
    return ExclusiveAccessContext(
      subscribedArtistUids: {if (_subscribed) widget.artistId},
      subscribedArtistNames: {
        if (_subscribed) normalizeExclusiveIdentity(_profile?.displayName),
      },
      viewerDisplayName: viewer?.displayName ?? viewer?.name,
      viewerIsArtist: viewer?.isArtist ?? false,
    );
  }

  Future<void> handleToggleFollow() async {
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
    }
  }

  Future<void> handleSubscribe() async {
    try {
      await SubscriptionService.createSubscription(widget.artistId);
      setState(() => _subscribed = true);
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
              ? 'Saldo de Jam Coins insuficiente.'
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
    final profile = _profile;
    final access = exclusiveContext();
    return Scaffold(
      backgroundColor: colors.background,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: ProfileScreenHeader(
                title: profile?.displayName ?? 'Artista',
                onBack: () => context.pop(),
              ),
            ),
            if (_error != null)
              Padding(
                padding: const EdgeInsets.all(12),
                child: Text(_error!, style: TextStyle(color: colors.danger)),
              ),
            Expanded(
              child: _loading
                  ? const Center(child: CircularProgressIndicator())
                  : RefreshIndicator(
                      onRefresh: handleLoad,
                      child: ListView(
                        padding: const EdgeInsets.fromLTRB(16, 16, 16, 40),
                        children: [
                          if (profile != null) ...[
                            Row(
                              children: [
                                PostAvatar(url: profile.photoUrl, size: 80),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        profile.displayName,
                                        style: TextStyle(
                                          fontSize: 22,
                                          fontWeight: FontWeight.w800,
                                          color: colors.textPrimary,
                                        ),
                                      ),
                                      Text(
                                        profile.name,
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: colors.textSecondary,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            AppButton(
                              label: _following ? 'Seguindo' : 'Seguir',
                              variant: _following
                                  ? AppButtonVariant.outline
                                  : AppButtonVariant.primary,
                              onPressed: handleToggleFollow,
                            ),
                            const SizedBox(height: 10),
                            AppButton(
                              label: _subscribed
                                  ? 'Membership ativa'
                                  : 'Assinar membership',
                              variant: AppButtonVariant.outline,
                              disabled: _subscribed,
                              onPressed: handleSubscribe,
                            ),
                            const SizedBox(height: 10),
                            AppButton(
                              label: 'Fã clube',
                              variant: AppButtonVariant.outline,
                              onPressed: () => context.push(
                                Pages.fanClubCommunity.replaceAll(
                                  ':artistId',
                                  widget.artistId,
                                ),
                              ),
                            ),
                            const SizedBox(height: 10),
                            AppButton(
                              label: 'Enviar Fan Letter',
                              variant: AppButtonVariant.outline,
                              onPressed: () => context.push(
                                Pages.fanLetterComposeOf(
                                  artistId: widget.artistId,
                                  name: profile.displayName,
                                  avatarUrl: profile.photoUrl,
                                ),
                              ),
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
                          ],
                          if (_tab == _ArtistTab.cartas)
                            if (_letters.isEmpty)
                              const ProfileState(
                                title: 'Fan letters',
                                message:
                                    'Nenhuma carta ainda. Envie a primeira pelo botão acima.',
                              )
                            else
                              for (final letter in _letters) ...[
                                FanLetterCard(letter: letter),
                                const SizedBox(height: 12),
                              ]
                          else if (_tab == _ArtistTab.sobre)
                            DecoratedBox(
                              decoration: BoxDecoration(
                                border: Border.all(color: colors.border),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(14),
                                child: Text(
                                  profile?.description.trim().isNotEmpty == true
                                      ? profile!.description
                                      : 'Este artista ainda não escreveu um sobre.',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: colors.textPrimary,
                                  ),
                                ),
                              ),
                            )
                          else if (visiblePosts().isEmpty)
                            const ProfileState(
                              title: 'Nenhum post',
                              message: 'Nada publicado nesta aba ainda.',
                            )
                          else
                            for (final post in visiblePosts())
                              FeedItem(
                                post: post,
                                canAccessExclusive: canAccessExclusivePost(
                                  post,
                                  access,
                                ),
                                onPressUnlock: handleSubscribe,
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
