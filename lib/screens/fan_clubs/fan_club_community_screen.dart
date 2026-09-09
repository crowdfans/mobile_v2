import 'package:crowdfans/components/fan_club/fan_club_community_cover.dart';
import 'package:crowdfans/components/fan_club/fan_club_community_hero.dart';
import 'package:crowdfans/components/fan_club/fan_club_sort_tab.dart';
import 'package:crowdfans/components/feed/feed_item.dart';
import 'package:crowdfans/components/post/post_options_sheet.dart';
import 'package:crowdfans/components/post/post_share_sheet.dart';
import 'package:crowdfans/components/profile/me_posts_filter_chip.dart';
import 'package:crowdfans/constants/pages.dart';
import 'package:crowdfans/constants/theme.dart';
import 'package:crowdfans/models/feed_post.dart';
import 'package:crowdfans/services/community_service.dart';
import 'package:crowdfans/services/fan_club_service.dart';
import 'package:crowdfans/services/follow_service.dart';
import 'package:crowdfans/services/sidebar_artists_store.dart';
import 'package:crowdfans/services/vote_service.dart';
import 'package:crowdfans/utils/exclusive_content_access.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

const _pageSize = 20;

enum _ClubFeedFilter { all, posts, media }

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
  var _feedFilter = _ClubFeedFilter.all;
  var _page = 1;
  var _hasMore = true;
  var _loading = true;
  var _loadingMore = false;
  var _following = false;
  var _favorite = false;
  var _searchOpen = false;
  var _searchQuery = '';
  String? _error;
  String _avatarUrl = '';
  FeedPost? _optionsPost;
  FeedPost? _sharePost;

  @override
  void initState() {
    super.initState();
    _avatarUrl = widget.seedAvatarUrl?.trim() ?? '';
    handleLoadFavorites();
    handleLoad();
  }

  Future<void> handleLoadFavorites() async {
    final ids = await SidebarArtistsStore.loadFavoriteIds();
    if (!mounted) {
      return;
    }
    setState(() => _favorite = ids.contains(widget.artistId));
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

  bool isMediaPost(FeedPost post) {
    return post.type == PostType.image ||
        post.type == PostType.carousel ||
        post.type == PostType.video ||
        (post.imageUri?.trim().isNotEmpty ?? false);
  }

  List<FeedPost> sortedPosts() {
    final query = _searchQuery.trim().toLowerCase();
    final list = [
      for (final post in _posts)
        if (query.isEmpty ||
            post.text.toLowerCase().contains(query) ||
            post.author.toLowerCase().contains(query) ||
            post.handle.toLowerCase().contains(query))
          post,
    ];
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
    return switch (_feedFilter) {
      _ClubFeedFilter.all => list,
      _ClubFeedFilter.posts => [
        for (final post in list)
          if (!isMediaPost(post)) post,
      ],
      _ClubFeedFilter.media => [
        for (final post in list)
          if (isMediaPost(post)) post,
      ],
    };
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
      Pages.artistProfileOf(
        widget.artistId,
        name: _club?.artistName ?? widget.seedName,
        avatarUrl: _avatarUrl,
      ),
    );
  }

  void handleToggleSearch() {
    setState(() {
      _searchOpen = !_searchOpen;
      if (!_searchOpen) {
        _searchQuery = '';
      }
    });
  }

  Future<void> handleToggleFavorite() async {
    final next = await SidebarArtistsStore.toggleFavorite(widget.artistId);
    if (!mounted) {
      return;
    }
    setState(() => _favorite = next.contains(widget.artistId));
  }

  Future<void> handleMore() async {
    final colors = CrowdFansTheme.of(context);
    final club = _club;
    await showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (sheetContext) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: Icon(Icons.person_outline, color: colors.textPrimary),
                title: const Text('Ver perfil do artista'),
                onTap: () {
                  Navigator.of(sheetContext).pop();
                  handleOpenArtistProfile();
                },
              ),
              ListTile(
                leading: Icon(
                  _following
                      ? Icons.person_remove_outlined
                      : Icons.person_add_alt,
                  color: colors.textPrimary,
                ),
                title: Text(_following ? 'Deixar de seguir' : 'Seguir'),
                onTap: () {
                  Navigator.of(sheetContext).pop();
                  handleToggleFollow();
                },
              ),
              if (club != null) ...[
                ListTile(
                  leading: Icon(Icons.edit_outlined, color: colors.textPrimary),
                  title: const Text('Publicar no clube'),
                  onTap: () {
                    Navigator.of(sheetContext).pop();
                    handleCompose();
                  },
                ),
                ListTile(
                  leading: Icon(Icons.info_outline, color: colors.textPrimary),
                  title: const Text('Ver mais'),
                  onTap: () {
                    Navigator.of(sheetContext).pop();
                    handleAbout();
                  },
                ),
                ListTile(
                  leading: Icon(Icons.rule, color: colors.textPrimary),
                  title: const Text('Regras'),
                  onTap: () {
                    Navigator.of(sheetContext).pop();
                    handleRules();
                  },
                ),
              ],
            ],
          ),
        );
      },
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
    final artistName = club?.artistName.trim().isNotEmpty == true
        ? club!.artistName.trim()
        : (widget.seedName?.trim().isNotEmpty == true
              ? widget.seedName!.trim()
              : 'Artista');
    return Scaffold(
      backgroundColor: colors.background,
      body: Stack(
        children: [
          Column(
            children: [
              if (_searchOpen)
                SafeArea(
                  bottom: false,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
                    child: Row(
                      children: [
                        IconButton(
                          onPressed: handleToggleSearch,
                          icon: Icon(
                            Icons.arrow_back_ios_new_rounded,
                            color: colors.textPrimary,
                          ),
                        ),
                        Expanded(
                          child: TextField(
                            autofocus: true,
                            onChanged: (value) {
                              setState(() => _searchQuery = value);
                            },
                            decoration: InputDecoration(
                              hintText: 'Buscar conteúdo no fã clube',
                              filled: true,
                              fillColor: colors.surfaceAlt,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide.none,
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 12,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
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
                            itemCount:
                                1 +
                                (club == null ? 0 : 3) +
                                (posts.isEmpty ? 1 : posts.length) +
                                (_loadingMore ? 1 : 0),
                            itemBuilder: (context, index) {
                              if (index == 0) {
                                if (_searchOpen) {
                                  return const SizedBox.shrink();
                                }
                                return FanClubCommunityCover(
                                  imageUrl: _avatarUrl,
                                  onBack: () => context.pop(),
                                  onSearch: handleToggleSearch,
                                  onMore: handleMore,
                                );
                              }
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
                              if (index == 1) {
                                return Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    if (_error != null)
                                      Padding(
                                        padding: const EdgeInsets.all(12),
                                        child: Text(
                                          _error!,
                                          style: TextStyle(
                                            color: colors.danger,
                                          ),
                                        ),
                                      ),
                                    FanClubCommunityHero(
                                      artistName: artistName,
                                      memberCount: club.memberCount,
                                      isFavorite: _favorite,
                                      onToggleFavorite: handleToggleFavorite,
                                      onOpenArtist: handleOpenArtistProfile,
                                      onAbout: handleAbout,
                                      onRules: handleRules,
                                    ),
                                  ],
                                );
                              }
                              if (index == 2) {
                                return Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.fromLTRB(
                                        16,
                                        4,
                                        16,
                                        0,
                                      ),
                                      child: Text(
                                        'Ordenar postagens por:',
                                        style: TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w500,
                                          color: colors.textTertiary,
                                        ),
                                      ),
                                    ),
                                    SizedBox(
                                      height: 44,
                                      child: ListView(
                                        scrollDirection: Axis.horizontal,
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                        ),
                                        children: [
                                          FanClubSortTab(
                                            label: 'Novos',
                                            selected: !_sortPopular,
                                            onPressed: () {
                                              setState(
                                                () => _sortPopular = false,
                                              );
                                            },
                                          ),
                                          FanClubSortTab(
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
                                    ),
                                  ],
                                );
                              }
                              if (index == 3) {
                                return Padding(
                                  padding: const EdgeInsets.fromLTRB(
                                    16,
                                    4,
                                    16,
                                    8,
                                  ),
                                  child: Wrap(
                                    spacing: 8,
                                    children: [
                                      MePostsFilterChip(
                                        label: 'Todos',
                                        selected:
                                            _feedFilter == _ClubFeedFilter.all,
                                        onPressed: () {
                                          setState(
                                            () => _feedFilter =
                                                _ClubFeedFilter.all,
                                          );
                                        },
                                      ),
                                      MePostsFilterChip(
                                        label: 'Posts',
                                        selected:
                                            _feedFilter ==
                                            _ClubFeedFilter.posts,
                                        onPressed: () {
                                          setState(
                                            () => _feedFilter =
                                                _ClubFeedFilter.posts,
                                          );
                                        },
                                      ),
                                      MePostsFilterChip(
                                        label: 'Media',
                                        selected:
                                            _feedFilter ==
                                            _ClubFeedFilter.media,
                                        onPressed: () {
                                          setState(
                                            () => _feedFilter =
                                                _ClubFeedFilter.media,
                                          );
                                        },
                                      ),
                                    ],
                                  ),
                                );
                              }
                              final postStart = 4;
                              if (posts.isEmpty) {
                                return Padding(
                                  padding: const EdgeInsets.all(24),
                                  child: Text(
                                    _searchQuery.trim().isEmpty
                                        ? 'Nenhum post na comunidade ainda.'
                                        : 'Nenhum resultado para esta busca.',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      color: colors.textSecondary,
                                    ),
                                  ),
                                );
                              }
                              final postIndex = index - postStart;
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
