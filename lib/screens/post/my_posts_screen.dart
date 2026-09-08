import 'package:crowdfans/components/post/my_post_options_sheet.dart';
import 'package:crowdfans/components/post/my_post_row.dart';
import 'package:crowdfans/components/post/my_posts_header.dart';
import 'package:crowdfans/components/profile/profile_state.dart';
import 'package:crowdfans/components/toolbar/toolbar_back_button.dart';
import 'package:crowdfans/constants/pages.dart';
import 'package:crowdfans/constants/theme.dart';
import 'package:crowdfans/services/post_service.dart';
import 'package:crowdfans/utils/app_alert.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Lista, edita e apaga os posts do usuário autenticado.
class MyPostsScreen extends StatefulWidget {
  const MyPostsScreen({super.key});

  @override
  State<MyPostsScreen> createState() => _MyPostsScreenState();
}

class _MyPostsScreenState extends State<MyPostsScreen> {
  var _posts = <UserPost>[];
  var _loading = true;
  String? _error;
  String? _menuPostId;

  @override
  void initState() {
    super.initState();
    handleLoad();
  }

  Future<void> handleLoad() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final posts = await PostService.getMyPosts();
      if (!mounted) {
        return;
      }
      setState(() {
        _posts = posts;
        _loading = false;
      });
    } catch (error) {
      if (!mounted) {
        return;
      }
      setState(() {
        _loading = false;
        _error = error.toString();
      });
    }
  }

  Future<void> handleRefresh() async {
    try {
      final posts = await PostService.getMyPosts();
      if (!mounted) {
        return;
      }
      setState(() {
        _posts = posts;
        _error = null;
      });
    } catch (error) {
      if (!mounted) {
        return;
      }
      setState(() => _error = error.toString());
    }
  }

  void handleCreate() {
    context.push(Pages.createPost);
  }

  void handleEdit(String postId) {
    setState(() => _menuPostId = null);
    context.push(Pages.createPostEdit(postId));
  }

  Future<void> handleDelete(String postId) async {
    setState(() => _menuPostId = null);
    final ok = await AppAlert.confirm(
      context,
      title: 'Deletar Post',
      message: 'Tem certeza que deseja deletar este post?',
      confirmLabel: 'Deletar',
      cancelLabel: 'Cancelar',
    );
    if (!ok) {
      return;
    }
    try {
      await PostService.deletePost(postId);
      if (!mounted) {
        return;
      }
      setState(() {
        _posts = [
          for (final post in _posts)
            if (post.id != postId) post,
        ];
      });
      await AppAlert.show(
        context,
        title: 'Sucesso',
        message: 'Post deletado com sucesso',
      );
    } catch (error) {
      if (!mounted) {
        return;
      }
      await AppAlert.show(context, title: 'Erro', message: error.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = CrowdFansTheme.of(context);
    return Scaffold(
      backgroundColor: colors.background,
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: context.canPop()
                        ? ToolbarBackButton(onPressed: () => context.pop())
                        : const SizedBox(height: 44),
                  ),
                ),
                MyPostsHeader(onCreate: handleCreate),
                Expanded(child: _body()),
              ],
            ),
            MyPostOptionsSheet(
              visible: _menuPostId != null,
              onClose: () => setState(() => _menuPostId = null),
              onEdit: () {
                final id = _menuPostId;
                if (id != null) {
                  handleEdit(id);
                }
              },
              onDelete: () {
                final id = _menuPostId;
                if (id != null) {
                  handleDelete(id);
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _body() {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_error != null) {
      return ProfileState(
        title: 'Erro ao carregar posts',
        message: _error,
        actionLabel: 'Tentar Novamente',
        onAction: handleLoad,
      );
    }
    if (_posts.isEmpty) {
      return ProfileState(
        title: 'Nenhum post publicado',
        message: 'Comece a compartilhar seu conteúdo com seus fãs!',
        actionLabel: 'Criar Primeiro Post',
        onAction: handleCreate,
      );
    }
    return RefreshIndicator(
      onRefresh: handleRefresh,
      child: ListView.separated(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
        itemCount: _posts.length,
        separatorBuilder: (context, index) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final post = _posts[index];
          return MyPostRow(
            post: post,
            onOpenMenu: () => setState(() => _menuPostId = post.id),
          );
        },
      ),
    );
  }
}
