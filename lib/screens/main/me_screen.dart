import 'package:crowdfans/components/feed/feed_item.dart';
import 'package:crowdfans/components/profile/profile_identity_block.dart';
import 'package:crowdfans/components/profile/profile_state.dart';
import 'package:crowdfans/components/toolbar/image_toolbar.dart';
import 'package:crowdfans/components/toolbar/toolbar_menu_button.dart';
import 'package:crowdfans/constants/pages.dart';
import 'package:crowdfans/constants/theme.dart';
import 'package:crowdfans/models/feed_post.dart';
import 'package:crowdfans/services/profile_service.dart';
import 'package:crowdfans/state/auth_session.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// Aba Perfil — identidade, stats e posts do viewer.
class MeScreen extends ConsumerStatefulWidget {
  const MeScreen({super.key});

  @override
  ConsumerState<MeScreen> createState() => _MeScreenState();
}

class _MeScreenState extends ConsumerState<MeScreen> {
  var _posts = <FeedPost>[];
  var _loadingPosts = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      handleLoadPosts();
    });
  }

  Future<void> handleLoadPosts() async {
    final profile = ref.read(authSessionProvider).profile;
    if (profile == null || profile.userUid.isEmpty) {
      setState(() => _loadingPosts = false);
      return;
    }
    setState(() => _loadingPosts = true);
    try {
      final items = await ProfileService.getPostsByUserUid(profile.userUid);
      setState(() {
        _posts = [for (final item in items) item.toFeedPost(owner: profile)];
      });
    } catch (_) {
      setState(() => _posts = []);
    } finally {
      if (mounted) {
        setState(() => _loadingPosts = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = CrowdFansTheme.of(context);
    final profile = ref.watch(authSessionProvider).profile;
    ref.listen(authSessionProvider, (previous, next) {
      if (previous?.profile?.userUid != next.profile?.userUid) {
        handleLoadPosts();
      }
    });
    return Scaffold(
      backgroundColor: colors.background,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            await ref.read(authSessionProvider.notifier).refreshSession();
            await handleLoadPosts();
          },
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
            children: [
              ImageToolbar(
                trailing: ToolbarMenuButton(
                  onPressed: () => context.push(Pages.profileSettings),
                ),
              ),
              const SizedBox(height: 12),
              if (profile == null)
                const ProfileState(
                  title: 'Perfil',
                  message: 'Perfil ainda não carregou.',
                )
              else
                ProfileIdentityBlock(profile: profile),
              const SizedBox(height: 28),
              Text(
                'Posts',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: colors.textPrimary,
                ),
              ),
              if (_loadingPosts)
                const ProfileState(loading: true)
              else if (_posts.isEmpty)
                const ProfileState(
                  title: 'Nenhum post',
                  message: 'Quando você publicar, seus posts aparecem aqui.',
                )
              else
                for (final post in _posts)
                  FeedItem(post: post, canAccessExclusive: true),
            ],
          ),
        ),
      ),
    );
  }
}
