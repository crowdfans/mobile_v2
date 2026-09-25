import 'package:crowdfans/components/fan_clubs/fan_club_search_result_row.dart';
import 'package:crowdfans/components/fan_clubs/fan_clubs_feed_header.dart';
import 'package:crowdfans/components/fan_clubs/fan_clubs_search_chrome.dart';
import 'package:crowdfans/components/feed/feed_item.dart';
import 'package:crowdfans/components/home/scroll_to_top_fab.dart';
import 'package:crowdfans/components/sidebar/sidebar_menu.dart';
import 'package:crowdfans/constants/pages.dart';
import 'package:crowdfans/constants/theme.dart';
import 'package:crowdfans/mocks/cf_temp_mocks.dart';
import 'package:crowdfans/models/home_feed.dart';
import 'package:crowdfans/services/community_service.dart';
import 'package:crowdfans/services/follow_service.dart';
import 'package:crowdfans/services/subscription_service.dart';
import 'package:crowdfans/services/vote_service.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

const _pageSize = 20;
const _scrollToTopThreshold = 420.0;

enum _ClubsContentFilter { all, posts, media }

class _ClubArtist {
  const _ClubArtist({
    required this.artistUid,
    required this.artistName,
    this.avatarUrl = '',
  });

  final String artistUid;
  final String artistName;
  final String avatarUrl;
}

/// Aba Clubes: chrome do mock Feed Fã Clubes + posts da comunidade.
class FanClubsScreen extends StatefulWidget {
  const FanClubsScreen({super.key});

  @override
  State<FanClubsScreen> createState() => _FanClubsScreenState();
}

class _FanClubsScreenState extends State<FanClubsScreen> {
  final _scrollController = ScrollController();
  var _artists = <_ClubArtist>[];
  var _posts = <CommunityPost>[];
  var _page = 1;
  var _hasMore = true;
  var _loading = true;
  var _loadingMore = false;
  var _sortPopular = true;
  var _contentFilter = _ClubsContentFilter.all;
  var _sidebarVisible = false;
  var _searchOpen = false;
  var _searchQuery = '';
  var _showScrollToTop = false;
  String? _error;

  bool isMediaPost(CommunityPost post) {
    final type = post.type.toLowerCase();
    return type == 'image' ||
        type == 'carousel' ||
        type == 'video' ||
        (post.imageUri?.trim().isNotEmpty ?? false);
  }

  List<CommunityPost> visiblePosts() {
    final sorted = [..._posts];
    if (_sortPopular) {
      sorted.sort((a, b) => b.votes.compareTo(a.votes));
    } else {
      sorted.sort((a, b) => a.minutesAgo.compareTo(b.minutesAgo));
    }
    return switch (_contentFilter) {
      _ClubsContentFilter.all => sorted,
      _ClubsContentFilter.posts => [
        for (final post in sorted)
          if (!isMediaPost(post)) post,
      ],
      _ClubsContentFilter.media => [
        for (final post in sorted)
          if (isMediaPost(post)) post,
      ],
    };
  }

  List<_ClubArtist> searchArtists() {
    final query = _searchQuery.trim().toLowerCase();
    if (query.isEmpty) {
      return _artists;
    }
    return [
      for (final artist in _artists)
        if (artist.artistName.toLowerCase().contains(query)) artist,
    ];
  }

  List<HomeFollowedArtist> sidebarArtists() {
    return [
      for (final artist in _artists)
        HomeFollowedArtist(
          id: artist.artistUid,
          username: artist.artistName,
          avatarUrl: artist.avatarUrl,
        ),
    ];
  }

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(handleScroll);
    handleLoad();
  }

  @override
  void dispose() {
    _scrollController.removeListener(handleScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void handleScroll() {
    final shouldShow =
        _scrollController.hasClients &&
        _scrollController.offset >= _scrollToTopThreshold;
    if (shouldShow != _showScrollToTop) {
      setState(() => _showScrollToTop = shouldShow);
    }
  }

  void handleScrollToTop() {
    if (!_scrollController.hasClients) {
      return;
    }
    _scrollController.animateTo(
      0,
      duration: const Duration(milliseconds: 320),
      curve: Curves.easeOutCubic,
    );
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
          SubscriptionService.listSubscriptions().then(
            (value) => value,
            onError: (_) => <Subscription>[],
          ),
          FollowService.listFollows().then(
            (value) => value,
            onError: (_) => <ArtistFollow>[],
          ),
          CommunityService.getCommunityPosts(page: 1, pageSize: _pageSize),
        ]);
        final subs = results[0] as List<Subscription>;
        final follows = results[1] as List<ArtistFollow>;
        final posts = results[2] as List<CommunityPost>;
        final feedPosts =
            posts.isEmpty &&
                kUseCfTempMocks &&
                kUseCf178FanClubsFeedMocks
            ? Cf178FanClubsFeedMock.posts()
            : posts;
        final merged = <_ClubArtist>[];
        for (final item in subs) {
          if (item.isActive && item.artistUid.trim().isNotEmpty) {
            merged.add(
              _ClubArtist(
                artistUid: item.artistUid,
                artistName: item.artistName,
              ),
            );
          }
        }
        for (final item in follows) {
          if (item.artistUid.trim().isEmpty) {
            continue;
          }
          if (merged.any((artist) => artist.artistUid == item.artistUid)) {
            continue;
          }
          merged.add(
            _ClubArtist(
              artistUid: item.artistUid,
              artistName: item.artistName,
              avatarUrl: item.avatarUrl,
            ),
          );
        }
        if (!mounted) {
          return;
        }
        setState(() {
          _artists = merged;
          _posts = feedPosts;
          _page = 1;
          _hasMore = posts.length >= _pageSize;
          _loading = false;
          _error = null;
        });
        return;
      }
      final posts = await CommunityService.getCommunityPosts(
        page: page,
        pageSize: _pageSize,
      );
      if (!mounted) {
        return;
      }
      setState(() {
        final seen = _posts.map((item) => item.id).toSet();
        for (final item in posts) {
          if (!seen.contains(item.id)) {
            _posts.add(item);
          }
        }
        _page = page;
        _hasMore = posts.length >= _pageSize;
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

  Future<void> handleRefresh() async {
    await handleLoad(page: 1);
  }

  Future<void> handleLoadMore() async {
    if (_loadingMore || _loading || !_hasMore || _searchOpen) {
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

  void handleOpenCommunity(_ClubArtist artist) {
    context.push(
      Pages.fanClubCommunityOf(
        artist.artistUid,
        name: artist.artistName,
        avatarUrl: artist.avatarUrl,
      ),
    );
  }

  void handleOpenMenu() {
    setState(() => _sidebarVisible = !_sidebarVisible);
  }

  void handleCloseSidebar() {
    setState(() => _sidebarVisible = false);
  }

  void handlePressSidebarArtist(HomeFollowedArtist artist) {
    handleCloseSidebar();
    handleOpenCommunity(
      _ClubArtist(
        artistUid: artist.id,
        artistName: artist.username,
        avatarUrl: artist.avatarUrl,
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

  void handleVoteApplied(VoteResult result) {
    setState(() {
      _posts = [
        for (final item in _posts)
          if (item.id == result.id)
            CommunityPost(
              id: item.id,
              type: item.type,
              author: item.author,
              handle: item.handle,
              minutesAgo: item.minutesAgo,
              avatarUri: item.avatarUri,
              text: item.text,
              imageUri: item.imageUri,
              votes: result.votes,
              myVote: result.myVote,
              comments: item.comments,
              shares: item.shares,
              targetArtistId: item.targetArtistId,
              isExclusive: item.isExclusive,
              exclusiveLocked: item.exclusiveLocked,
            )
          else
            item,
      ];
    });
  }

  @override
  Widget build(BuildContext context) {
    final colors = CrowdFansTheme.of(context);
    final posts = visiblePosts();
    final artists = searchArtists();
    return PopScope(
      canPop: !_sidebarVisible,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop && _sidebarVisible) {
          handleCloseSidebar();
        }
      },
      child: Scaffold(
      backgroundColor: colors.background,
      body: Stack(
        children: [
          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (_searchOpen)
                  FanClubsSearchChrome(
                    onBack: handleToggleSearch,
                    onChanged: (value) {
                      setState(() => _searchQuery = value);
                    },
                  )
                else
                  FanClubsFeedHeader(
                    sortPopular: _sortPopular,
                    filterAll: _contentFilter == _ClubsContentFilter.all,
                    filterPosts: _contentFilter == _ClubsContentFilter.posts,
                    filterMedia: _contentFilter == _ClubsContentFilter.media,
                    onOpenMenu: handleOpenMenu,
                    onOpenSearch: handleToggleSearch,
                    onSortPopular: () => setState(() => _sortPopular = true),
                    onSortNew: () => setState(() => _sortPopular = false),
                    onFilterAll: () {
                      setState(() => _contentFilter = _ClubsContentFilter.all);
                    },
                    onFilterPosts: () {
                      setState(
                        () => _contentFilter = _ClubsContentFilter.posts,
                      );
                    },
                    onFilterMedia: () {
                      setState(
                        () => _contentFilter = _ClubsContentFilter.media,
                      );
                    },
                  ),
                if (_error != null)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      _error!,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 13,
                        color: colors.textSecondary,
                      ),
                    ),
                  ),
                Expanded(
                  child: _loading
                      ? const Center(child: CircularProgressIndicator())
                      : _searchOpen
                      ? ListView.separated(
                          padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                          itemCount: artists.isEmpty ? 1 : artists.length,
                          separatorBuilder: (_, _) => Divider(
                            height: 1,
                            thickness: 1,
                            color: colors.border,
                          ),
                          itemBuilder: (context, index) {
                            if (artists.isEmpty) {
                              return Padding(
                                padding: const EdgeInsets.only(top: 40),
                                child: Text(
                                  _artists.isEmpty
                                      ? 'Siga artistas para buscar fã clubes.'
                                      : 'Nenhum fã clube encontrado.',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: colors.textSecondary,
                                  ),
                                ),
                              );
                            }
                            final artist = artists[index];
                            return FanClubSearchResultRow(
                              name: artist.artistName,
                              avatarUrl: artist.avatarUrl,
                              onPressed: () => handleOpenCommunity(artist),
                            );
                          },
                        )
                      : NotificationListener<ScrollNotification>(
                          onNotification: (notification) {
                            if (notification.metrics.extentAfter < 240) {
                              handleLoadMore();
                            }
                            return false;
                          },
                          child: RefreshIndicator(
                            onRefresh: handleRefresh,
                            child: ListView.builder(
                              controller: _scrollController,
                              padding: const EdgeInsets.fromLTRB(12, 0, 12, 24),
                              itemCount: posts.isEmpty
                                  ? 1
                                  : posts.length + (_loadingMore ? 1 : 0),
                              itemBuilder: (context, index) {
                                if (posts.isEmpty) {
                                  return Padding(
                                    padding: const EdgeInsets.only(top: 40),
                                    child: Text(
                                      key: const Key('fan-clubs-empty'),
                                      _artists.isEmpty
                                          ? 'Siga artistas para ver posts da comunidade aqui.'
                                          : 'Nenhum post na comunidade ainda.',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: colors.textSecondary,
                                      ),
                                    ),
                                  );
                                }
                                if (index >= posts.length) {
                                  return const Padding(
                                    padding: EdgeInsets.symmetric(vertical: 16),
                                    child: Center(
                                      child: CircularProgressIndicator(),
                                    ),
                                  );
                                }
                                final post = posts[index].toFeedPost();
                                return FeedItem(
                                  post: post,
                                  canAccessExclusive: false,
                                  onVoteApplied: handleVoteApplied,
                                );
                              },
                            ),
                          ),
                        ),
                ),
              ],
            ),
          ),
          ScrollToTopFab(
            visible: _showScrollToTop && !_loading && !_searchOpen,
            onPressed: handleScrollToTop,
          ),
          SidebarMenu(
            visible: _sidebarVisible,
            artists: sidebarArtists(),
            onClose: handleCloseSidebar,
            onPressArtist: handlePressSidebarArtist,
          ),
        ],
      ),
    ),
    );
  }
}
