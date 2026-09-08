import 'package:crowdfans/components/feed/feed_item.dart';
import 'package:crowdfans/components/feed/stories_row.dart';
import 'package:crowdfans/components/post/post_options_sheet.dart';
import 'package:crowdfans/components/post/post_share_sheet.dart';
import 'package:crowdfans/components/toolbar/image_toolbar.dart';
import 'package:crowdfans/constants/theme.dart';
import 'package:crowdfans/models/feed_post.dart';
import 'package:crowdfans/models/home_feed.dart';
import 'package:crowdfans/services/home_feed_service.dart';
import 'package:crowdfans/services/subscription_service.dart';
import 'package:crowdfans/state/auth_session.dart';
import 'package:crowdfans/utils/exclusive_content_access.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Home / feed autenticado.
class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  final _posts = <FeedPost>[];
  var _stories = <StoryItem>[];
  var _page = 1;
  var _hasMore = true;
  var _loading = true;
  var _loadingMore = false;
  String? _error;
  FeedPost? _optionsPost;
  FeedPost? _sharePost;
  var _subscribedUids = <String>{};
  var _subscribedNames = <String>{};

  @override
  void initState() {
    super.initState();
    handleLoad(page: 1);
  }

  Future<void> handleLoad({required int page, bool append = false}) async {
    if (append) {
      setState(() => _loadingMore = true);
    }
    try {
      final data = await HomeFeedService.load(page: page);
      if (!append) {
        try {
          final subscriptions = await SubscriptionService.listSubscriptions();
          final uids = <String>{};
          final names = <String>{};
          for (final item in subscriptions) {
            if (!item.isActive) {
              continue;
            }
            uids.add(item.artistUid);
            final nameKey = normalizeExclusiveIdentity(item.artistName);
            if (nameKey.isNotEmpty) {
              names.add(nameKey);
            }
          }
          _subscribedUids = uids;
          _subscribedNames = names;
        } catch (_) {
          _subscribedUids = {};
          _subscribedNames = {};
        }
      }
      setState(() {
        _page = page;
        _hasMore = data.hasMore;
        _error = null;
        if (append) {
          final seen = _posts.map((post) => post.id).toSet();
          for (final post in data.feedPosts) {
            if (!seen.contains(post.id)) {
              _posts.add(post);
            }
          }
        } else {
          _posts
            ..clear()
            ..addAll(data.feedPosts);
          _stories = data.stories;
        }
      });
    } catch (_) {
      setState(() => _error = 'Não foi possível carregar o feed.');
    } finally {
      if (mounted) {
        setState(() {
          _loading = false;
          _loadingMore = false;
        });
      }
    }
  }

  Future<void> handleRefresh() async {
    await handleLoad(page: 1);
  }

  @override
  Widget build(BuildContext context) {
    final colors = CrowdFansTheme.of(context);
    final viewer = ref.watch(authSessionProvider).profile;
    final exclusiveContext = ExclusiveAccessContext(
      subscribedArtistUids: _subscribedUids,
      subscribedArtistNames: _subscribedNames,
      viewerDisplayName: viewer?.displayName ?? viewer?.name,
      viewerIsArtist: viewer?.isArtist ?? false,
    );

    return Scaffold(
      backgroundColor: colors.background,
      body: Stack(
        children: [
          SafeArea(
            child: Column(
              children: [
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 12),
                  child: ImageToolbar(),
                ),
                if (_error != null)
                  Padding(
                    padding: const EdgeInsets.all(12),
                    child: Text(
                      _error!,
                      style: TextStyle(color: colors.danger),
                    ),
                  ),
                Expanded(
                  child: _loading
                      ? const Center(child: CircularProgressIndicator())
                      : RefreshIndicator(
                          onRefresh: handleRefresh,
                          child: ListView.builder(
                            padding: const EdgeInsets.fromLTRB(12, 0, 12, 24),
                            itemCount: _posts.length + 2,
                            itemBuilder: (context, index) {
                              if (index == 0) {
                                return StoriesRow(stories: _stories);
                              }
                              if (index == _posts.length + 1) {
                                if (_hasMore && !_loadingMore) {
                                  handleLoad(page: _page + 1, append: true);
                                }
                                if (_loadingMore) {
                                  return const Padding(
                                    padding: EdgeInsets.all(16),
                                    child: Center(
                                      child: CircularProgressIndicator(),
                                    ),
                                  );
                                }
                                if (_posts.isEmpty) {
                                  return Padding(
                                    padding: const EdgeInsets.only(top: 48),
                                    child: Text(
                                      'Nada por aqui ainda. Siga artistas para ver o feed.',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        color: colors.textSecondary,
                                      ),
                                    ),
                                  );
                                }
                                return const SizedBox(height: 24);
                              }
                              final post = _posts[index - 1];
                              return FeedItem(
                                post: post,
                                canAccessExclusive: canAccessExclusivePost(
                                  post,
                                  exclusiveContext,
                                ),
                                onVoteApplied: (result) {
                                  setState(() {
                                    final voteIndex = _posts.indexWhere(
                                      (item) => item.id == result.id,
                                    );
                                    if (voteIndex >= 0) {
                                      _posts[voteIndex] = _posts[voteIndex]
                                          .copyWith(
                                            votes: result.votes,
                                            myVote: result.myVote,
                                          );
                                    }
                                  });
                                },
                                onPressOptions: () {
                                  setState(() => _optionsPost = post);
                                },
                              );
                            },
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
            onPostHidden: (postId) {
              setState(() {
                _posts.removeWhere((item) => item.id == postId);
              });
            },
            onOpenShare: (post) {
              setState(() => _sharePost = post);
            },
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
