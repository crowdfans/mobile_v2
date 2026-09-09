import 'package:crowdfans/components/profile/profile_screen_header.dart';
import 'package:crowdfans/components/profile/profile_state.dart';
import 'package:crowdfans/components/profile/settings_restore_row.dart';
import 'package:crowdfans/constants/pages.dart';
import 'package:crowdfans/constants/theme.dart';
import 'package:crowdfans/services/saved_post_service.dart';
import 'package:crowdfans/utils/app_alert.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Posts salvos nas memórias.
class ProfileMemoriesScreen extends StatefulWidget {
  const ProfileMemoriesScreen({super.key});

  @override
  State<ProfileMemoriesScreen> createState() => _ProfileMemoriesScreenState();
}

class _ProfileMemoriesScreenState extends State<ProfileMemoriesScreen> {
  var _posts = <SavedPost>[];
  var _loading = true;
  String? _error;
  String? _busyId;

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
      final posts = await SavedPostService.listSavedPosts();
      if (!mounted) {
        return;
      }
      setState(() {
        _posts = posts;
        _loading = false;
      });
    } catch (_) {
      if (!mounted) {
        return;
      }
      setState(() {
        _loading = false;
        _error = 'Não foi possível carregar as memórias.';
      });
    }
  }

  Future<void> handleUnsave(SavedPost post) async {
    final ok = await AppAlert.confirm(
      context,
      title: 'Remover memória',
      message: 'Tirar este post das memórias?',
      confirmLabel: 'Remover',
    );
    if (!ok) {
      return;
    }
    setState(() => _busyId = post.postId);
    try {
      await SavedPostService.unsavePost(post.postId);
      await handleLoad();
    } catch (error) {
      if (mounted) {
        await AppAlert.show(
          context,
          title: 'Memórias',
          message: error.toString(),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _busyId = null);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = CrowdFansTheme.of(context);
    return Scaffold(
      backgroundColor: colors.background,
      body: SafeArea(
        child: Column(
          children: [
            ProfileScreenHeader(title: 'Memórias', onBack: () => context.pop()),
            Expanded(
              child: _loading
                  ? const ProfileState(loading: true)
                  : _error != null
                  ? ProfileState(
                      title: 'Erro',
                      message: _error,
                      actionLabel: 'Tentar novamente',
                      onAction: handleLoad,
                    )
                  : _posts.isEmpty
                  ? const ProfileState(
                      title: 'Nenhuma memória',
                      message:
                          'Salve posts pelo menu de opções para vê-los aqui.',
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.fromLTRB(16, 12, 16, 40),
                      itemCount: _posts.length,
                      separatorBuilder: (context, index) =>
                          const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final post = _posts[index];
                        return GestureDetector(
                          onTap: () => context.push(
                            Pages.comments.replaceAll(':postId', post.postId),
                          ),
                          child: SettingsRestoreRow(
                            title: post.authorName,
                            subtitle: post.text,
                            actionLabel: 'Remover',
                            busy: _busyId == post.postId,
                            onRestore: () => handleUnsave(post),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
