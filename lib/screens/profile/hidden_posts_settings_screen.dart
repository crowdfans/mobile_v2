import 'package:crowdfans/components/profile/profile_screen_header.dart';
import 'package:crowdfans/components/profile/profile_state.dart';
import 'package:crowdfans/components/profile/settings_restore_row.dart';
import 'package:crowdfans/constants/theme.dart';
import 'package:crowdfans/services/hidden_post_service.dart';
import 'package:crowdfans/utils/app_alert.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Posts ocultos pelo viewer, com opção de reexibir.
class HiddenPostsSettingsScreen extends StatefulWidget {
  const HiddenPostsSettingsScreen({super.key});

  @override
  State<HiddenPostsSettingsScreen> createState() =>
      _HiddenPostsSettingsScreenState();
}

class _HiddenPostsSettingsScreenState extends State<HiddenPostsSettingsScreen> {
  var _posts = <HiddenPost>[];
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
      final posts = await HiddenPostService.listHiddenPosts();
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
        _error = 'Não foi possível carregar os posts ocultos.';
      });
    }
  }

  Future<void> handleRestore(HiddenPost post) async {
    final ok = await AppAlert.confirm(
      context,
      title: 'Reexibir post',
      message: 'Voltar a mostrar este post nos feeds?',
      confirmLabel: 'Reexibir',
    );
    if (!ok) {
      return;
    }
    setState(() => _busyId = post.postId);
    try {
      await HiddenPostService.unhidePost(post.postId);
      await handleLoad();
    } catch (error) {
      if (mounted) {
        await AppAlert.show(
          context,
          title: 'Posts ocultos',
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
            ProfileScreenHeader(
              title: 'Posts ocultos',
              onBack: () => context.pop(),
            ),
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
                      title: 'Nenhum post oculto',
                      message: 'Os posts que você ocultar aparecem aqui.',
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.fromLTRB(16, 12, 16, 40),
                      itemCount: _posts.length,
                      separatorBuilder: (context, index) =>
                          const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final post = _posts[index];
                        return SettingsRestoreRow(
                          title: post.authorName,
                          subtitle: post.excerpt,
                          actionLabel: 'Reexibir',
                          busy: _busyId == post.postId,
                          onRestore: () => handleRestore(post),
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
