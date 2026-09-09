import 'package:crowdfans/components/fan_clubs/fan_club_artist_chip.dart';
import 'package:crowdfans/components/feed/feed_item.dart';
import 'package:crowdfans/constants/pages.dart';
import 'package:crowdfans/constants/theme.dart';
import 'package:crowdfans/services/community_service.dart';
import 'package:crowdfans/services/follow_service.dart';
import 'package:crowdfans/services/subscription_service.dart';
import 'package:crowdfans/services/vote_service.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

const _pageSize = 20;

class _ClubArtist {
  const _ClubArtist({required this.artistUid, required this.artistName});

  final String artistUid;
  final String artistName;
}

/// Aba Clubes: chips de artistas e feed da comunidade.
class FanClubsScreen extends StatefulWidget {
  const FanClubsScreen({super.key});

  @override
  State<FanClubsScreen> createState() => _FanClubsScreenState();
}

class _FanClubsScreenState extends State<FanClubsScreen> {
  var _artists = <_ClubArtist>[];
  var _posts = <CommunityPost>[];
  var _page = 1;
  var _hasMore = true;
  var _loading = true;
  var _loadingMore = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    handleLoad();
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
            ),
          );
        }
        if (!mounted) {
          return;
        }
        setState(() {
          _artists = merged;
          _posts = posts;
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

  void handleOpenCommunity(_ClubArtist artist) {
    context.push(
      Pages.fanClubCommunityOf(artist.artistUid, name: artist.artistName),
    );
  }

  void handleOpenArtist(_ClubArtist artist) {
    context.push(
      Pages.artistProfile.replaceAll(':artistId', artist.artistUid),
    );
  }

  void handleSelectAll() {
    handleLoad();
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
    return Scaffold(
      backgroundColor: colors.background,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Fan Clubs',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                      color: colors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Toque em um artista para abrir a comunidade · segure para o perfil',
                    style: TextStyle(fontSize: 13, color: colors.textSecondary),
                  ),
                  const SizedBox(height: 10),
                  GestureDetector(
                    onTap: () => context.push(Pages.fanClubRules),
                    child: Text(
                      'Ver regras do Fã Clube',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: colors.primary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            if (_artists.isNotEmpty)
              SizedBox(
                height: 44,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                  children: [
                    FanClubArtistChip(
                      label: 'Todos',
                      selected: true,
                      onPressed: handleSelectAll,
                    ),
                    const SizedBox(width: 8),
                    for (final artist in _artists) ...[
                      FanClubArtistChip(
                        label: artist.artistName,
                        selected: false,
                        onPressed: () => handleOpenCommunity(artist),
                        onLongPressed: () => handleOpenArtist(artist),
                      ),
                      const SizedBox(width: 8),
                    ],
                  ],
                ),
              ),
            if (_error != null)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  _error!,
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 13, color: colors.textSecondary),
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
                        onRefresh: handleRefresh,
                        child: ListView.builder(
                          padding: const EdgeInsets.fromLTRB(12, 0, 12, 24),
                          itemCount: _posts.isEmpty
                              ? 1
                              : _posts.length + (_loadingMore ? 1 : 0),
                          itemBuilder: (context, index) {
                            if (_posts.isEmpty) {
                              return Padding(
                                padding: const EdgeInsets.only(top: 40),
                                child: Text(
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
                            if (index >= _posts.length) {
                              return const Padding(
                                padding: EdgeInsets.symmetric(vertical: 16),
                                child: Center(
                                  child: CircularProgressIndicator(),
                                ),
                              );
                            }
                            final post = _posts[index].toFeedPost();
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
    );
  }
}
