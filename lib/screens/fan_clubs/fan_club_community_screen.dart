import 'package:crowdfans/components/comments/comment_sort_chip.dart';
import 'package:crowdfans/components/fan_club/fan_club_community_hero.dart';
import 'package:crowdfans/components/feed/feed_item.dart';
import 'package:crowdfans/components/post/post_options_sheet.dart';
import 'package:crowdfans/components/post/post_share_sheet.dart';
import 'package:crowdfans/components/toolbar/text_toolbar.dart';
import 'package:crowdfans/components/toolbar/toolbar_back_button.dart';
import 'package:crowdfans/constants/pages.dart';
import 'package:crowdfans/constants/theme.dart';
import 'package:crowdfans/models/feed_post.dart';
import 'package:crowdfans/services/community_service.dart';
import 'package:crowdfans/services/fan_club_service.dart';
import 'package:crowdfans/services/follow_service.dart';
import 'package:crowdfans/services/vote_service.dart';
import 'package:crowdfans/utils/exclusive_content_access.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

const _pageSize = 20;

/// Comunidade do fan club de um artista.
class FanClubCommunityScreen extends StatefulWidget {
  const FanClubCommunityScreen({
    super.key,
    required this.artistId,
    this.seedName,
    this.seedAvatarUrl,
  });

  final String artistId;
  final String? seedName;
  final String? seedAvatarUrl;

  @override
  State<FanClubCommunityScreen> createState() => _FanClubCommunityScreenState();
}

class _FanClubCommunityScreenState extends State<FanClubCommunityScreen> {
  ArtistFanClub? _club;
  var _posts = <FeedPost>[];
  var _sortPopular = false;
  var _page = 1;
  var _hasMore = true;
  var _loading = true;
  var _loadingMore = false;
  var _following = false;
  String? _error;
  String _avatarUrl = '';
  FeedPost? _optionsPost;
  FeedPost? _sharePost;

  @override
  void initState() {
    super.initState();
    _avatarUrl = widget.seedAvatarUrl?.trim() ?? '';
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

  List<FeedPost> sortedPosts() {
    final list = [..._posts];
    if (_sortPopular) {
      list.sort((a, b) {
        final byVotes = b.votes.compareTo(a.votes);
        if (byVotes != 0) {
          return byVotes;
        }
        return a.minutesAgo.compareTo(b.minutesAgo);
      });
    } else {
      list.sort((a, b) => a.minutesAgo.compareTo(b.minutesAgo));
    }
    return list;
  }

  Future<void> handleLoad({int page = 1, bool append = false}) async {
    if (!append) {
      setState(() {
        _loading = true;
        _error = null;
      });
    }
    try {
      if (!append) {
        final results = await Future.wait([
          FanClubService.getArtistFanClubFeed(
            widget.artistId,
            page: 1,
            pageSize: _pageSize,
          ),
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
        final avatar = _avatarUrl.isNotEmpty
            ? _avatarUrl
            : (fromCommunity.isNotEmpty ? fromCommunity.first.avatarUri : '');
        if (!mounted) {
          return;
        }
        setState(() {
          _club = club;
          _following = following || (club?.isMember ?? false);
          _posts = mergePosts(fromFeed, fromCommunity);
          _avatarUrl = avatar;
          _page = 1;
          _hasMore = (feed?.posts.length ?? 0) >= _pageSize;
          _loading = false;
          _error = null;
        });
        return;
      }
      final feed = await FanClubService.getArtistFanClubFeed(
        widget.artistId,
        page: page,
        pageSize: _pageSize,
      );
      final club = feed?.fanClub ?? _club;
      if (club == null || !mounted) {
        return;
      }
      final mapped = [
        for (final post in feed?.posts ?? const <FanClubFeedPost>[])
          mapClubPost(post, club),
      ];
      setState(() {
        _posts = mergePosts(_posts, mapped);
        _page = page;
        _hasMore = mapped.length >= _pageSize;
      });
    } catch (_) {
      if (!mounted) {
        return;
      }
      setState(() {
        _loading = false;
        if (!append) {
          _error = 'Não foi possível carregar a comunidade.';
        }
      });
    }
  }

  Future<void> handleLoadMore() async {
    if (_loadingMore || _loading || !_hasMore) {
      return;
    }
    setState(() => _loadingMore = true);
    try {
      await handleLoad(page: _page + 1, append: true);
    } finally {
      if (mounted) {
        setState(() => _loadingMore = false);
      }
    }
  }

  Future<void> handleCompose() async {
    final club = _club;
    context.push(
      Pages.fanClubComposeOf(
        artistId: widget.artistId,
        name: club?.artistName ?? widget.seedName,
        avatarUrl: _avatarUrl,
      ),
    );
  }

  void handleAbout() {
    final club = _club;
    context.push(
      Pages.fanClubAboutOf(
        artistId: widget.artistId,
        name: club?.artistName ?? widget.seedName,
        avatarUrl: _avatarUrl,
      ),
    );
  }

  void handleRules() {
    context.push(Pages.fanClubRules);
  }

  void handleOpenArtistProfile() {
    context.push(
      Pages.artistProfile.replaceAll(':artistId', widget.artistId),
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
    } catch (_) {
      // Mantém o estado atual se a API recusar.
    }
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

  @override
  Widget build(BuildContext context) {
    final colors = CrowdFansTheme.of(context);
    final club = _club;
    final posts = sortedPosts();
    final title = club?.name.trim().isNotEmpty == true
        ? club!.name
        : (widget.seedName?.trim().isNotEmpty == true
              ? widget.seedName!.trim()
              : 'Comunidade');
    return Scaffold(
      backgroundColor: colors.background,
      body: Stack(
        children: [
          SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: TextToolbar(
                    title: title,
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
                      : NotificationListener<ScrollNotification>(
                          onNotification: (notification) {
                            if (notification.metrics.extentAfter < 240) {
                              handleLoadMore();
                            }
                            return false;
                          },
                          child: RefreshIndicator(
                            onRefresh: () => handleLoad(page: 1),
                            child: ListView.builder(
                              padding: const EdgeInsets.only(bottom: 24),
                              itemCount: 2 +
                                  (posts.isEmpty ? 1 : posts.length) +
                                  (_loadingMore ? 1 : 0),
                              itemBuilder: (context, index) {
                                if (index == 0) {
                                  if (club == null) {
                                    return Padding(
                                      padding: const EdgeInsets.all(24),
                                      child: Text(
                                        'Este artista ainda não tem fã clube.',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          color: colors.textSecondary,
                                        ),
                                      ),
                                    );
                                  }
                                  return FanClubCommunityHero(
                                    club: club,
                                    avatarUrl: _avatarUrl,
                                    following: _following,
                                    onToggleFollow: handleToggleFollow,
                                    onCompose: handleCompose,
                                    onAbout: handleAbout,
                                    onRules: handleRules,
                                    onOpenArtist: handleOpenArtistProfile,
                                  );
                                }
                                if (index == 1) {
                                  return Padding(
                                    padding: const EdgeInsets.fromLTRB(
                                      16,
                                      4,
                                      16,
                                      8,
                                    ),
                                    child: Row(
                                      children: [
                                        CommentSortChip(
                                          label: 'Novos',
                                          selected: !_sortPopular,
                                          onPressed: () {
                                            setState(
                                              () => _sortPopular = false,
                                            );
                                          },
                                        ),
                                        const SizedBox(width: 8),
                                        CommentSortChip(
                                          label: 'Populares',
                                          selected: _sortPopular,
                                          onPressed: () {
                                            setState(
                                              () => _sortPopular = true,
                                            );
                                          },
                                        ),
                                      ],
                                    ),
                                  );
                                }
                                if (posts.isEmpty) {
                                  return Padding(
                                    padding: const EdgeInsets.all(24),
                                    child: Text(
                                      'Nenhum post na comunidade ainda.',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        color: colors.textSecondary,
                                      ),
                                    ),
                                  );
                                }
                                final postIndex = index - 2;
                                if (postIndex >= posts.length) {
                                  return const Padding(
                                    padding: EdgeInsets.symmetric(vertical: 16),
                                    child: Center(
                                      child: CircularProgressIndicator(),
                                    ),
                                  );
                                }
                                final post = posts[postIndex];
                                return Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                  ),
                                  child: FeedItem(
                                    post: post,
                                    canAccessExclusive: canAccessExclusivePost(
                                      post,
                                      const ExclusiveAccessContext(),
                                    ),
                                    onVoteApplied: handleVoteApplied,
                                    onPressOptions: () {
                                      setState(() => _optionsPost = post);
                                    },
                                    onPressShare: () {
                                      setState(() => _sharePost = post);
                                    },
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                ),
              ],
            ),
          ),
          PostOptionsSheet(
            visible: _optionsPost != null,
            post: _optionsPost,
            onClose: () => setState(() => _optionsPost = null),
          ),
          PostShareSheet(
            visible: _sharePost != null,
            post: _sharePost,
            onClose: () => setState(() => _sharePost = null),
          ),
        ],
      ),
    );
  }
}
