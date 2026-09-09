import 'package:crowdfans/components/feed/feed_item.dart';
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
import 'package:crowdfans/services/profile_service.dart';
import 'package:crowdfans/state/auth_session.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

enum _MePostsFilter { all, media }

/// Aba Perfil — identidade, atalhos, artistas, filtros e publicações.
class MeScreen extends ConsumerStatefulWidget {
  const MeScreen({super.key});

  @override
  ConsumerState<MeScreen> createState() => _MeScreenState();
}

class _MeScreenState extends ConsumerState<MeScreen> {
  var _posts = <FeedPost>[];
  var _artists = <FollowedArtist>[];
  var _filter = _MePostsFilter.all;
  var _loading = true;

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

  bool isMediaPost(FeedPost post) {
    return post.type == PostType.image ||
        post.type == PostType.carousel ||
        post.type == PostType.video;
  }

  List<FeedPost> visiblePosts() {
    if (_filter == _MePostsFilter.media) {
      return [for (final post in _posts) if (isMediaPost(post)) post];
    }
    return _posts;
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
      if (!mounted) {
        return;
      }
      setState(() {
        _posts = posts;
        _artists = overview?.followedArtists ?? const [];
        _loading = false;
      });
    } catch (_) {
      if (!mounted) {
        return;
      }
      setState(() {
        _posts = [];
        _artists = [];
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

  @override
  Widget build(BuildContext context) {
    final colors = CrowdFansTheme.of(context);
    final profile = ref.watch(authSessionProvider).profile;
    ref.listen(authSessionProvider, (previous, next) {
      if (previous?.profile?.userUid != next.profile?.userUid) {
        handleLoad();
      }
    });
    final posts = visiblePosts();
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
