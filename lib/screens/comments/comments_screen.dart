import 'dart:async';

import 'package:crowdfans/components/comments/comment_composer.dart';
import 'package:crowdfans/components/comments/comment_gif_picker.dart';
import 'package:crowdfans/components/comments/comment_post_context_header.dart';
import 'package:crowdfans/components/comments/comment_replies_toggle.dart';
import 'package:crowdfans/components/comments/comment_row.dart';
import 'package:crowdfans/components/comments/comment_sort_chip.dart';
import 'package:crowdfans/components/comments/comment_thread_header.dart';
import 'package:crowdfans/constants/pages.dart';
import 'package:crowdfans/constants/theme.dart';
import 'package:crowdfans/mocks/cf_temp_mocks.dart';
import 'package:crowdfans/services/comment_gif_service.dart';
import 'package:crowdfans/services/comment_service.dart';
import 'package:crowdfans/services/profile_service.dart';
import 'package:crowdfans/services/vote_service.dart';
import 'package:crowdfans/state/auth_session.dart';
import 'package:crowdfans/utils/app_alert.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

const _pageSize = 20;

/// Comentários de um post (`/comments/:postId`).
class CommentsScreen extends ConsumerStatefulWidget {
  const CommentsScreen({
    super.key,
    required this.postId,
    this.postAuthor,
    this.postHandle,
    this.postText,
    this.clubName,
    this.postAvatarUrl,
    this.clubAvatarUrl,
    this.postMinutesAgo,
    this.postVotes,
    this.postShares,
  });

  final String postId;
  final String? postAuthor;
  final String? postHandle;
  final String? postText;
  final String? clubName;
  final String? postAvatarUrl;
  final String? clubAvatarUrl;
  final int? postMinutesAgo;
  final int? postVotes;
  final int? postShares;

  @override
  ConsumerState<CommentsScreen> createState() => _CommentsScreenState();
}

class _CommentsScreenState extends ConsumerState<CommentsScreen> {
  var _comments = <CommentItem>[];
  var _sortPopular = true;
  var _draft = '';
  /// Comentário raiz usado como `parentCommentId` (sem cadeia Twitter).
  CommentItem? _replyTo;
  /// Autor exibido no banner (pode ser resposta aninhada; CF-69 Instagram).
  String? _replyBannerAuthor;
  String? _replyBannerHandle;
  CommentItem? _editing;
  String? _selectedGifUrl;
  var _gifPickerOpen = false;
  var _gifQuery = '';
  var _gifItems = <CommentGifItem>[];
  var _loadingGifs = false;
  String? _gifError;
  String? _gifAnnouncement;
  var _loading = true;
  var _loadingMore = false;
  var _page = 1;
  var _hasMore = true;
  var _submitting = false;
  var _composerNonce = 0;
  String? _error;
  Timer? _gifDebounce;
  final _expandedReplyIds = <String>{};
  late int _postVotes = widget.postVotes ?? 0;
  late int _postMyVote = 0;
  final int _postShares = widget.postShares ?? 0;

  bool get _isFanClubContext => (widget.clubName ?? '').trim().isNotEmpty;

  @override
  void initState() {
    super.initState();
    handleLoad();
  }

  @override
  void dispose() {
    _gifDebounce?.cancel();
    super.dispose();
  }

  Future<void> handleLoad({int page = 1, bool append = false}) async {
    if (widget.postId.isEmpty) {
      setState(() {
        _error = 'Post inválido.';
        _loading = false;
      });
      return;
    }
    if (!append) {
      setState(() {
        _loading = true;
        _error = null;
      });
    }
    try {
      final response = await CommentService.getCommentsByPostId(
        widget.postId,
        page: page,
        pageSize: _pageSize,
      );
      if (!mounted) {
        return;
      }
      setState(() {
        _page = page;
        _hasMore = response.totalCount > 0
            ? page * _pageSize < response.totalCount
            : response.comments.length >= _pageSize;
        if (append) {
          final seen = _comments.map((item) => item.id).toSet();
          for (final item in response.comments) {
            if (!seen.contains(item.id)) {
              _comments.add(item);
            }
          }
        } else {
          _comments = response.comments;
          // CF-194: sem dados reais no fã-clube → mock do print (arquivo único).
          if (_comments.isEmpty &&
              _isFanClubContext &&
              kUseCf194CommentMocks) {
            _comments = Cf194FanClubCommentsMock.comments();
            _hasMore = false;
          } else if (_comments.isEmpty &&
              !_isFanClubContext &&
              kUseCf195CommentMocks) {
            // CF-195: Home sem dados → mock do print expandido.
            _comments = Cf195HomeCommentsMock.comments();
            _hasMore = false;
            _expandedReplyIds.add(_comments.first.id);
          }
        }
        _loading = false;
        _error = null;
      });
    } catch (_) {
      if (!mounted) {
        return;
      }
      setState(() {
        _loading = false;
        if (!append) {
          if (_isFanClubContext && kUseCf194CommentMocks) {
            _comments = Cf194FanClubCommentsMock.comments();
            _hasMore = false;
            _error = null;
          } else if (!_isFanClubContext && kUseCf195CommentMocks) {
            _comments = Cf195HomeCommentsMock.comments();
            _hasMore = false;
            _expandedReplyIds.add(_comments.first.id);
            _error = null;
          } else {
            _error = 'Não foi possível carregar os comentários.';
          }
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

  Future<void> handleLoadGifs([String query = '']) async {
    setState(() {
      _loadingGifs = true;
      _gifError = null;
      _gifAnnouncement = null;
    });
    try {
      final items = await CommentGifService.fetchCommentGifs(query);
      if (!mounted) {
        return;
      }
      final trimmed = query.trim();
      setState(() {
        _gifItems = items;
        _loadingGifs = false;
        _gifError = null;
        _gifAnnouncement = trimmed.isEmpty
            ? '${items.length} GIFs em destaque'
            : '${items.length} resultados para “$trimmed”';
      });
    } catch (_) {
      if (!mounted) {
        return;
      }
      // Mensagem recuperável — nunca expor API key ou detalhes internos.
      setState(() {
        _loadingGifs = false;
        _gifItems = const [];
        _gifAnnouncement = null;
        _gifError =
            'Não foi possível carregar os GIFs. Verifique sua conexão e tente novamente.';
      });
    }
  }

  void handleGifQueryChanged(String value) {
    setState(() => _gifQuery = value);
    _gifDebounce?.cancel();
    _gifDebounce = Timer(const Duration(milliseconds: 350), () {
      handleLoadGifs(value);
    });
  }

  bool isOwnComment(CommentItem comment) {
    final profile = ref.read(authSessionProvider).profile;
    if (profile == null) {
      return false;
    }
    final displayName = profile.displayName.trim().toLowerCase();
    final name = profile.name.trim().toLowerCase();
    final author = comment.author.trim().toLowerCase();
    return (displayName.isNotEmpty && author == displayName) ||
        (name.isNotEmpty && author == name);
  }

  Future<void> handleSubmit() async {
    final content = _draft.trim();
    if (content.isEmpty &&
        (_selectedGifUrl == null || _selectedGifUrl!.isEmpty)) {
      await AppAlert.show(
        context,
        title: 'Comentário',
        message: 'Digite um texto ou escolha um GIF.',
      );
      return;
    }
    setState(() => _submitting = true);
    try {
      if (_editing != null) {
        final updated = await CommentService.updateComment(
          commentId: _editing!.id,
          content: content,
          gifUrl: _selectedGifUrl,
        );
        setState(() {
          _comments = _mapComments(
            _comments,
            (item) => item.id == updated.id
                ? updated.copyWith(replies: item.replies)
                : item.copyWith(
                    replies: [
                      for (final reply in item.replies)
                        reply.id == updated.id ? updated : reply,
                    ],
                  ),
          );
          _editing = null;
        });
      } else {
        final created = await CommentService.createComment(
          postId: widget.postId,
          content: content,
          gifUrl: _selectedGifUrl,
          parentCommentId: _replyTo?.id,
        );
        setState(() {
          if (_replyTo != null) {
            final parentId = _replyTo!.id;
            _expandedReplyIds.add(parentId);
            _comments = [
              for (final item in _comments)
                item.id == parentId
                    ? item.copyWith(replies: [...item.replies, created])
                    : item,
            ];
          } else {
            _comments = [created, ..._comments];
          }
          _replyTo = null;
          _replyBannerAuthor = null;
          _replyBannerHandle = null;
        });
      }
      setState(() {
        _draft = '';
        _selectedGifUrl = null;
        _submitting = false;
        _composerNonce++;
      });
    } catch (_) {
      if (!mounted) {
        return;
      }
      setState(() => _submitting = false);
      await AppAlert.show(
        context,
        title: 'Comentário',
        message: 'Não foi possível publicar. Tente novamente.',
      );
    }
  }

  List<CommentItem> _mapComments(
    List<CommentItem> items,
    CommentItem Function(CommentItem item) map,
  ) {
    return [for (final item in items) map(item)];
  }

  Future<void> handleDelete(CommentItem comment) async {
    final ok = await AppAlert.confirm(
      context,
      title: 'Excluir comentário',
      message: 'Tem certeza que deseja excluir este comentário?',
      confirmLabel: 'Excluir',
    );
    if (!ok) {
      return;
    }
    try {
      await CommentService.deleteComment(comment.id);
      if (!mounted) {
        return;
      }
      setState(() {
        _comments = [
          for (final item in _comments)
            if (item.id != comment.id)
              item.copyWith(
                replies: [
                  for (final reply in item.replies)
                    if (reply.id != comment.id) reply,
                ],
              ),
        ];
      });
    } catch (_) {
      if (!mounted) {
        return;
      }
      await AppAlert.show(
        context,
        title: 'Comentário',
        message: 'Não foi possível excluir. Tente novamente.',
      );
    }
  }

  void handleOpenProfile(CommentItem comment) {
    final handle = ProfileService.normalizeFanHandle(
      comment.handle.isNotEmpty ? comment.handle : comment.author,
    );
    if (handle.isEmpty) {
      return;
    }
    context.push(Pages.fanProfileOf(handle));
  }

  List<CommentItem> visibleComments() {
    final list = [..._comments];
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

  void handleVoteApplied(String commentId, VoteResult result) {
    setState(() {
      _comments = [
        for (final item in _comments)
          item.id == commentId
              ? item.copyWith(votes: result.votes, myVote: result.myVote)
              : item.copyWith(
                  replies: [
                    for (final reply in item.replies)
                      reply.id == commentId
                          ? reply.copyWith(
                              votes: result.votes,
                              myVote: result.myVote,
                            )
                          : reply,
                  ],
                ),
      ];
    });
  }

  void handleReport(CommentItem comment) {
    context.push(
      '${Pages.report}?context=comment'
      '&targetId=${Uri.encodeQueryComponent(comment.id)}'
      '&displayName=${Uri.encodeQueryComponent(comment.author)}',
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = CrowdFansTheme.of(context);
    if (_gifPickerOpen) {
      return CommentGifPicker(
        query: _gifQuery,
        items: _gifItems,
        loading: _loadingGifs,
        errorMessage: _gifError,
        resultAnnouncement: _gifAnnouncement,
        onQueryChanged: handleGifQueryChanged,
        onClose: () => setState(() {
          _gifPickerOpen = false;
          _gifError = null;
          _gifAnnouncement = null;
        }),
        onSelect: (item) {
          // Selecionar só volta ao rascunho — não publica sozinho.
          setState(() {
            _selectedGifUrl = item.originalUrl;
            _gifPickerOpen = false;
            _gifError = null;
            _gifAnnouncement = null;
          });
        },
      );
    }
    return Scaffold(
      backgroundColor: colors.background,
      resizeToAvoidBottomInset: false,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            CommentThreadHeader(
              onBack: () {
                if (context.canPop()) {
                  context.pop();
                  return;
                }
                context.go(Pages.home);
              },
              author: widget.postAuthor,
              handle: widget.postHandle,
              avatarUrl: widget.postAvatarUrl,
              clubAvatarUrl: widget.clubAvatarUrl,
              clubName: widget.clubName,
            ),
            if ((widget.postAuthor ?? '').trim().isNotEmpty ||
                (widget.clubName ?? '').trim().isNotEmpty ||
                (widget.postText ?? '').trim().isNotEmpty ||
                widget.postMinutesAgo != null)
              CommentPostContextHeader(
                author: widget.postAuthor,
                handle: widget.postHandle,
                text: widget.postText,
                clubName: widget.clubName,
                minutesAgo: widget.postMinutesAgo,
                votes: _postVotes,
                myVote: _postMyVote,
                shares: _postShares,
                onVote: (direction) =>
                    VoteService.votePost(widget.postId, direction),
                onVoteApplied: (result) => setState(() {
                  _postVotes = result.votes;
                  _postMyVote = result.myVote;
                }),
                onShare: () {},
              )
            else
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                child: Text(
                  'Comentários',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: colors.textPrimary,
                  ),
                ),
              ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
              child: Row(
                children: [
                  CommentSortChip(
                    label: 'Populares',
                    selected: _sortPopular,
                    onPressed: () => setState(() => _sortPopular = true),
                  ),
                  const SizedBox(width: 8),
                  CommentSortChip(
                    label: 'Novos',
                    selected: !_sortPopular,
                    onPressed: () => setState(() => _sortPopular = false),
                  ),
                ],
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
                      child: ListView.builder(
                        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                        itemCount: _comments.isEmpty
                            ? 1
                            : visibleComments().length + (_loadingMore ? 1 : 0),
                        itemBuilder: (context, index) {
                          if (_comments.isEmpty) {
                            return Padding(
                              padding: const EdgeInsets.only(top: 40),
                              child: Text(
                                _error ??
                                    'Nenhum comentário ainda. Seja o primeiro!',
                                textAlign: TextAlign.center,
                                style: TextStyle(color: colors.textSecondary),
                              ),
                            );
                          }
                          final sorted = visibleComments();
                          if (index >= sorted.length) {
                            return const Padding(
                              padding: EdgeInsets.symmetric(vertical: 16),
                              child: Center(child: CircularProgressIndicator()),
                            );
                          }
                          final item = sorted[index];
                          final replyCount = item.replies.length;
                          final expanded = _expandedReplyIds.contains(item.id);
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              CommentRow(
                                comment: item,
                                isOwn: isOwnComment(item),
                                isReply: false,
                                onOpenProfile: () => handleOpenProfile(item),
                                onReply: () => setState(() {
                                  _replyTo = item;
                                  _replyBannerAuthor = item.author;
                                  _replyBannerHandle = item.handle;
                                  _editing = null;
                                }),
                                onReport: () => handleReport(item),
                                onEdit: () => setState(() {
                                  _editing = item;
                                  _replyTo = null;
                                  _replyBannerAuthor = null;
                                  _replyBannerHandle = null;
                                  _draft = item.text;
                                  _selectedGifUrl = item.gifUrl;
                                  _composerNonce++;
                                }),
                                onDelete: () => handleDelete(item),
                                onVoteApplied: (result) =>
                                    handleVoteApplied(item.id, result),
                              ),
                              if (replyCount > 0) ...[
                                if (expanded)
                                  for (final reply in item.replies)
                                    CommentRow(
                                      comment: reply,
                                      isOwn: isOwnComment(reply),
                                      isReply: true,
                                      replyToHandle: item.handle,
                                      onOpenProfile: () =>
                                          handleOpenProfile(reply),
                                      onReply: () => setState(() {
                                        // Resposta aninhada → ainda sob o raiz.
                                        _replyTo = item;
                                        _replyBannerAuthor = reply.author;
                                        _replyBannerHandle = reply.handle;
                                        _editing = null;
                                      }),
                                      onReport: () => handleReport(reply),
                                      onEdit: () => setState(() {
                                        _editing = reply;
                                        _replyTo = null;
                                        _replyBannerAuthor = null;
                                        _replyBannerHandle = null;
                                        _draft = reply.text;
                                        _selectedGifUrl = reply.gifUrl;
                                        _composerNonce++;
                                      }),
                                      onDelete: () => handleDelete(reply),
                                      onVoteApplied: (result) =>
                                          handleVoteApplied(reply.id, result),
                                    ),
                                CommentRepliesToggle(
                                  replyCount: replyCount,
                                  expanded: expanded,
                                  onToggle: () {
                                    // Recolher não apaga o rascunho do compositor.
                                    setState(() {
                                      if (expanded) {
                                        _expandedReplyIds.remove(item.id);
                                      } else {
                                        _expandedReplyIds.add(item.id);
                                      }
                                    });
                                  },
                                ),
                              ],
                            ],
                          );
                        },
                      ),
                    ),
            ),
            CommentComposer(
              key: ValueKey(_composerNonce),
              draft: _draft,
              replyAuthor: _replyBannerAuthor ?? _replyTo?.author,
              replyHandle: _replyBannerHandle ?? _replyTo?.handle,
              editing: _editing != null,
              selectedGifUrl: _selectedGifUrl,
              submitting: _submitting,
              avatarUrl: ref.watch(authSessionProvider).profile?.photoUrl,
              onDraftChanged: (value) => setState(() => _draft = value),
              onCancelEdit: () => setState(() {
                _editing = null;
                _draft = '';
                _selectedGifUrl = null;
                _composerNonce++;
              }),
              onCancelReply: () => setState(() {
                _replyTo = null;
                _replyBannerAuthor = null;
                _replyBannerHandle = null;
              }),
              onRemoveGif: () => setState(() => _selectedGifUrl = null),
              onPickGif: () {
                setState(() => _gifPickerOpen = true);
                handleLoadGifs(_gifQuery);
              },
              onSubmit: handleSubmit,
            ),
          ],
        ),
      ),
    );
  }
}
