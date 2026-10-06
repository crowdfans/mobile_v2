import 'package:crowdfans/components/post/my_post_row.dart';
import 'package:crowdfans/components/profile/profile_state.dart';
import 'package:crowdfans/services/post_service.dart';
import 'package:flutter/material.dart';

const myPostsEmptyTitle = 'Nenhum post publicado';
const myPostsEmptyMessage = 'Comece a compartilhar seu conteúdo com seus fãs!';
const myPostsEmptyActionLabel = 'Criar Primeiro Post';
const myPostsErrorTitle = 'Erro ao carregar posts';
const myPostsErrorActionLabel = 'Tentar Novamente';

/// Corpo da lista Meus posts: loading, erro de rede, vazio (zero) ou itens.
class MyPostsBody extends StatelessWidget {
  const MyPostsBody({
    super.key,
    required this.loading,
    required this.posts,
    required this.onRetry,
    required this.onCreate,
    required this.onOpenMenu,
    this.error,
    this.onRefresh,
  });

  final bool loading;
  final String? error;
  final List<UserPost> posts;
  final VoidCallback onRetry;
  final VoidCallback onCreate;
  final ValueChanged<String> onOpenMenu;
  final Future<void> Function()? onRefresh;

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (error != null) {
      return ProfileState(
        title: myPostsErrorTitle,
        message: error,
        actionLabel: myPostsErrorActionLabel,
        onAction: onRetry,
      );
    }
    if (posts.isEmpty) {
      return ProfileState(
        title: myPostsEmptyTitle,
        message: myPostsEmptyMessage,
        actionLabel: myPostsEmptyActionLabel,
        onAction: onCreate,
      );
    }
    final list = ListView.separated(
      key: const Key('my-posts-list'),
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
      itemCount: posts.length,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final post = posts[index];
        return MyPostRow(
          post: post,
          onOpenMenu: () => onOpenMenu(post.id),
        );
      },
    );
    final refresh = onRefresh;
    if (refresh == null) {
      return list;
    }
    return RefreshIndicator(onRefresh: refresh, child: list);
  }
}
