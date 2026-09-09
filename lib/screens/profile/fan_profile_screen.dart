import 'package:crowdfans/components/buttons/app_button.dart';
import 'package:crowdfans/components/feed/feed_item.dart';
import 'package:crowdfans/components/profile/fan_profile_actions_sheet.dart';
import 'package:crowdfans/components/profile/fan_profile_header.dart';
import 'package:crowdfans/components/profile/fan_profile_stats_row.dart';
import 'package:crowdfans/components/profile/me_followed_artists_section.dart';
import 'package:crowdfans/components/profile/profile_screen_header.dart';
import 'package:crowdfans/components/profile/profile_state.dart';
import 'package:crowdfans/constants/pages.dart';
import 'package:crowdfans/constants/theme.dart';
import 'package:crowdfans/models/fan_profile.dart';
import 'package:crowdfans/models/feed_post.dart';
import 'package:crowdfans/services/block_service.dart';
import 'package:crowdfans/services/profile_service.dart';
import 'package:crowdfans/state/auth_session.dart';
import 'package:crowdfans/utils/app_alert.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// Perfil público de outro fã (`GET /profiles/:handle/overview`).
class FanProfileScreen extends ConsumerStatefulWidget {
  const FanProfileScreen({super.key, required this.fanHandle});

  final String fanHandle;

  @override
  ConsumerState<FanProfileScreen> createState() => _FanProfileScreenState();
}

class _FanProfileScreenState extends ConsumerState<FanProfileScreen> {
  ProfileOverview? _overview;
  var _loading = true;
  String? _error;

  String get _targetHandle {
    final decoded = Uri.decodeComponent(widget.fanHandle);
    return ProfileService.normalizeFanHandle(decoded);
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      handleLoad();
    });
  }

  Future<void> handleLoad() async {
    final handle = _targetHandle;
    if (handle.isEmpty) {
      setState(() {
        _loading = false;
        _error = 'Handle inválido.';
      });
      return;
    }
    final mine = ref.read(authSessionProvider).profile;
    if (mine != null) {
      final myHandle = ProfileService.normalizeFanHandle(
        mine.name.isNotEmpty ? mine.name : mine.displayName,
      );
      final altHandle = ProfileService.normalizeFanHandle(mine.displayName);
      if (myHandle == handle || altHandle == handle) {
        context.go(Pages.me);
        return;
      }
    }
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final overview = await ProfileService.getProfileOverview(handle);
      if (!mounted) {
        return;
      }
      setState(() {
        _overview = overview;
        _loading = false;
      });
    } catch (_) {
      if (!mounted) {
        return;
      }
      setState(() {
        _loading = false;
        _error = 'Não foi possível carregar este perfil.';
      });
    }
  }

  void handleBack() {
    if (context.canPop()) {
      context.pop();
      return;
    }
    context.go(Pages.home);
  }

  void handleOpenFanScore() {
    final handle = _targetHandle;
    if (handle.isEmpty) {
      return;
    }
    context.push(Pages.fanScorePublicOf(handle));
  }

  void handleOpenArtists() {
    final handle = _targetHandle;
    if (handle.isEmpty) {
      return;
    }
    context.push(Pages.profileArtistsOf(handle: handle));
  }

  Future<void> handleReport() async {
    final uid = _overview?.profile.userUid?.trim() ?? '';
    if (uid.isEmpty) {
      return;
    }
    context.push(
      '${Pages.report}?context=fan-profile'
      '&targetId=${Uri.encodeQueryComponent(uid)}'
      '&displayName=${Uri.encodeQueryComponent(_overview?.profile.displayName ?? '')}',
    );
  }

  Future<void> handleBlock() async {
    final profile = _overview?.profile;
    final uid = profile?.userUid?.trim() ?? '';
    if (uid.isEmpty || profile == null) {
      return;
    }
    final ok = await AppAlert.confirm(
      context,
      title: 'Bloquear usuário',
      message:
          'Bloquear ${profile.displayName}? Vocês não verão os conteúdos um do outro.',
      confirmLabel: 'Bloquear',
    );
    if (!ok) {
      return;
    }
    try {
      await BlockService.blockUser(uid);
      if (mounted) {
        await AppAlert.show(
          context,
          title: 'Bloqueios',
          message: 'Usuário bloqueado.',
        );
      }
    } catch (error) {
      if (mounted) {
        await AppAlert.show(
          context,
          title: 'Bloqueios',
          message: error.toString(),
        );
      }
    }
  }

  void handleOpenActions() {
    final profile = _overview?.profile;
    if (profile?.userUid == null || profile!.userUid!.isEmpty) {
      return;
    }
    FanProfileActionsSheet.present(
      context,
      displayName: profile.displayName,
      onReport: handleReport,
      onBlock: handleBlock,
    );
  }

  void handleVoteApplied(
    FeedPost post, {
    required int votes,
    required int myVote,
  }) {
    final overview = _overview;
    if (overview == null) {
      return;
    }
    setState(() {
      _overview = ProfileOverview(
        profile: overview.profile,
        followedArtists: overview.followedArtists,
        posts: [
          for (final item in overview.posts)
            item.id == post.id
                ? item.copyWith(votes: votes, myVote: myVote)
                : item,
        ],
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final colors = CrowdFansTheme.of(context);
    final overview = _overview;
    final profile = overview?.profile;
    final posts = overview?.posts ?? const <FeedPost>[];
    final artists = overview?.followedArtists ?? const <FollowedArtist>[];
    final title = (profile?.displayName.trim().isNotEmpty ?? false)
        ? profile!.displayName.trim()
        : 'Perfil';
    return Scaffold(
      backgroundColor: colors.background,
      body: SafeArea(
        child: Column(
          children: [
            ProfileScreenHeader(
              title: title,
              onBack: handleBack,
              action: profile?.userUid == null || profile!.userUid!.isEmpty
                  ? null
                  : TextButton(
                      onPressed: handleOpenActions,
                      child: Text(
                        'Mais',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: colors.primary,
                        ),
                      ),
                    ),
            ),
            Expanded(
              child: _loading
                  ? const ProfileState(loading: true)
                  : ListView(
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 40),
                      children: [
                        if (_error != null && profile == null) ...[
                          ProfileState(
                            title: 'Perfil',
                            message: _error,
                            actionLabel: 'Tentar novamente',
                            onAction: handleLoad,
                          ),
                        ] else if (profile != null) ...[
                          FanProfileHeader(profile: profile),
                          const SizedBox(height: 16),
                          FanProfileStatsRow(
                            postsCount: profile.postsCount,
                            cardsCount: profile.cardsCount,
                            artistsCount: '${artists.length}',
                            onArtistsTap: handleOpenArtists,
                          ),
                          if (profile.bio.trim().isNotEmpty) ...[
                            const SizedBox(height: 16),
                            Text(
                              profile.bio.trim(),
                              style: TextStyle(
                                fontSize: 14,
                                height: 21 / 14,
                                color: colors.textPrimary,
                              ),
                            ),
                          ],
                          const SizedBox(height: 12),
                          AppButton(
                            label: 'Ver Fan Score',
                            variant: AppButtonVariant.outline,
                            onPressed: handleOpenFanScore,
                          ),
                          if (artists.isNotEmpty) ...[
                            const SizedBox(height: 16),
                            MeFollowedArtistsSection(
                              artists: artists,
                              onSeeAll: handleOpenArtists,
                              onPressArtist: (artist) {
                                if (artist.id.isEmpty) {
                                  return;
                                }
                                context.push(
                                  Pages.artistProfile.replaceAll(
                                    ':artistId',
                                    artist.id,
                                  ),
                                );
                              },
                            ),
                          ],
                          const SizedBox(height: 16),
                          Text(
                            'Publicações',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                              color: colors.textPrimary,
                            ),
                          ),
                          if (posts.isEmpty)
                            const ProfileState(
                              title: 'Nenhuma publicação',
                              message:
                                  'As publicações deste perfil aparecerão aqui.',
                            )
                          else
                            for (final post in posts)
                              FeedItem(
                                post: post,
                                canAccessExclusive: false,
                                onVoteApplied: (result) => handleVoteApplied(
                                  post,
                                  votes: result.votes,
                                  myVote: result.myVote,
                                ),
                              ),
                        ],
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
