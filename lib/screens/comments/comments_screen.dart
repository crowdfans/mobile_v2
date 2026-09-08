import 'dart:async';

import 'package:crowdfans/components/comments/comment_composer.dart';
import 'package:crowdfans/components/comments/comment_gif_picker.dart';
import 'package:crowdfans/components/comments/comment_row.dart';
import 'package:crowdfans/constants/pages.dart';
import 'package:crowdfans/constants/theme.dart';
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
  const CommentsScreen({super.key, required this.postId});

  final String postId;

  @override
  ConsumerState<CommentsScreen> createState() => _CommentsScreenState();
}

class _CommentsScreenState extends ConsumerState<CommentsScreen> {
  var _comments = <CommentItem>[];
  var _draft = '';
  CommentItem? _replyTo;
  CommentItem? _editing;
  String? _selectedGifUrl;
  var _gifPickerOpen = false;
  var _gifQuery = '';
  var _gifItems = <CommentGifItem>[];
  var _loadingGifs = false;
  var _loading = true;
  var _loadingMore = false;
  var _page = 1;
  var _hasMore = true;
  var _submitting = false;
  var _composerNonce = 0;
  String? _error;
  Timer? _gifDebounce;

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
          _error = 'Não foi possível carregar os comentários.';
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
    setState(() => _loadingGifs = true);
    try {
      final items = await CommentGifService.fetchCommentGifs(query);
      if (!mounted) {
        return;
      }
      setState(() {
        _gifItems = items;
        _loadingGifs = false;
      });
    } catch (_) {
      if (!mounted) {
        return;
      }
      setState(() => _loadingGifs = false);
      await AppAlert.show(
        context,
        title: 'GIF',
        message: 'Não foi possível carregar GIFs.',
      );
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
            _comments = [
              for (final item in _comments)
                item.id == _replyTo!.id
                    ? item.copyWith(replies: [...item.replies, created])
                    : item,
            ];
          } else {
            _comments = [created, ..._comments];
          }
          _replyTo = null;
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
    context.push(
      Pages.fanProfile.replaceAll(':fanHandle', Uri.encodeComponent(handle)),
    );
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
        onQueryChanged: handleGifQueryChanged,
        onClose: () => setState(() => _gifPickerOpen = false),
        onSelect: (item) {
          setState(() {
            _selectedGifUrl = item.originalUrl;
            _gifPickerOpen = false;
          });
        },
      );
    }
    return Scaffold(
      backgroundColor: colors.background,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  TextButton(
                    onPressed: () {
                      if (context.canPop()) {
                        context.pop();
                        return;
                      }
                      context.go(Pages.home);
                    },
                    child: Text(
                      'Voltar',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: colors.primary,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      'Comentários',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: colors.textPrimary,
                      ),
                    ),
                  ),
                  const SizedBox(width: 72),
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
                            : _comments.length + (_loadingMore ? 1 : 0),
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
                          if (index >= _comments.length) {
                            return const Padding(
                              padding: EdgeInsets.symmetric(vertical: 16),
                              child: Center(child: CircularProgressIndicator()),
                            );
                          }
                          final item = _comments[index];
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
                                  _editing = null;
                                }),
                                onReport: () => handleReport(item),
                                onEdit: () => setState(() {
                                  _editing = item;
                                  _replyTo = null;
                                  _draft = item.text;
                                  _selectedGifUrl = item.gifUrl;
                                  _composerNonce++;
                                }),
                                onDelete: () => handleDelete(item),
                                onVoteApplied: (result) =>
                                    handleVoteApplied(item.id, result),
                              ),
                              for (final reply in item.replies)
                                CommentRow(
                                  comment: reply,
                                  isOwn: isOwnComment(reply),
                                  isReply: true,
                                  onOpenProfile: () => handleOpenProfile(reply),
                                  onReply: () {},
                                  onReport: () => handleReport(reply),
                                  onEdit: () => setState(() {
                                    _editing = reply;
                                    _replyTo = null;
                                    _draft = reply.text;
                                    _selectedGifUrl = reply.gifUrl;
                                    _composerNonce++;
                                  }),
                                  onDelete: () => handleDelete(reply),
                                  onVoteApplied: (result) =>
                                      handleVoteApplied(reply.id, result),
                                ),
                            ],
                          );
                        },
                      ),
                    ),
            ),
            CommentComposer(
              key: ValueKey(_composerNonce),
              draft: _draft,
              replyAuthor: _replyTo?.author,
              editing: _editing != null,
              selectedGifUrl: _selectedGifUrl,
              submitting: _submitting,
              onDraftChanged: (value) => setState(() => _draft = value),
              onCancelEdit: () => setState(() {
                _editing = null;
                _draft = '';
                _selectedGifUrl = null;
                _composerNonce++;
              }),
              onCancelReply: () => setState(() => _replyTo = null),
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
