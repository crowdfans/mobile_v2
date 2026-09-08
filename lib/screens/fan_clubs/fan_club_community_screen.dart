import 'package:crowdfans/components/feed/feed_item.dart';
import 'package:crowdfans/components/fan_club/fan_club_community_hero.dart';
import 'package:crowdfans/components/toolbar/text_toolbar.dart';
import 'package:crowdfans/components/toolbar/toolbar_back_button.dart';
import 'package:crowdfans/constants/theme.dart';
import 'package:crowdfans/models/feed_post.dart';
import 'package:crowdfans/services/community_service.dart';
import 'package:crowdfans/services/fan_club_service.dart';
import 'package:crowdfans/services/follow_service.dart';
import 'package:crowdfans/utils/exclusive_content_access.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Comunidade do fan club de um artista.
class FanClubCommunityScreen extends StatefulWidget {
  const FanClubCommunityScreen({super.key, required this.artistId});

  final String artistId;

  @override
  State<FanClubCommunityScreen> createState() => _FanClubCommunityScreenState();
}

class _FanClubCommunityScreenState extends State<FanClubCommunityScreen> {
  ArtistFanClub? _club;
  var _posts = <FeedPost>[];
  var _loading = true;
  var _following = false;
  String? _error;
  String _avatarUrl = '';

  @override
  void initState() {
    super.initState();
    handleLoad();
  }

  FeedPost mapClubPost(FanClubFeedPost post, ArtistFanClub club) {
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
      avatarUri: _avatarUrl,
      text: post.content.isEmpty ? (post.title ?? '') : post.content,
      imageUri: post.imageUrl,
      votes: post.likesCount,
      comments: post.commentsCount,
      shares: 0,
      isExclusive: post.isExclusive,
      exclusiveLocked: post.isExclusive,
    );
  }

  List<FeedPost> mergePosts(List<FeedPost> fromFeed, List<FeedPost> extra) {
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

  Future<void> handleLoad() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final results = await Future.wait([
        FanClubService.getArtistFanClubFeed(widget.artistId),
        CommunityService.getCommunityPosts(page: 1, pageSize: 50),
        FollowService.checkFollow(widget.artistId)
            .then((value) => value, onError: (_) => false),
      ]);
      final feed = results[0] as ArtistFanClubFeed?;
      final community = results[1] as List<CommunityPost>;
      final following = results[2] as bool;
      final club = feed?.fanClub;
      final fromFeed = [
        if (club != null)
          for (final post in feed?.posts ?? const <FanClubFeedPost>[])
            mapClubPost(post, club),
      ];
      final fromCommunity = [
        for (final post in community)
          if (post.targetArtistId == widget.artistId) post.toFeedPost(),
      ];
      setState(() {
        _club = club;
        _following = following || (club?.isMember ?? false);
        _posts = mergePosts(fromFeed, fromCommunity);
        _avatarUrl = fromCommunity.isNotEmpty
            ? fromCommunity.first.avatarUri
            : '';
      });
    } catch (_) {
      setState(() => _error = 'Não foi possível carregar a comunidade.');
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
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
    } catch (_) {
      // Mantém o estado atual se a API recusar.
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = CrowdFansTheme.of(context);
    final club = _club;
    return Scaffold(
      backgroundColor: colors.background,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: TextToolbar(
                title: club?.name ?? 'Comunidade',
                leading: ToolbarBackButton(onPressed: () => context.pop()),
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
                      child: ListView.builder(
                        padding: const EdgeInsets.only(bottom: 24),
                        itemCount: _posts.length + 1,
                        itemBuilder: (context, index) {
                          if (index == 0) {
                            if (club == null) {
                              return Padding(
                                padding: const EdgeInsets.all(24),
                                child: Text(
                                  'Este artista ainda não tem fã clube.',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(color: colors.textSecondary),
                                ),
                              );
                            }
                            return FanClubCommunityHero(
                              club: club,
                              avatarUrl: _avatarUrl,
                              following: _following,
                              onToggleFollow: handleToggleFollow,
                            );
                          }
                          return Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            child: FeedItem(
                              post: _posts[index - 1],
                              canAccessExclusive: canAccessExclusivePost(
                                _posts[index - 1],
                                const ExclusiveAccessContext(),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
