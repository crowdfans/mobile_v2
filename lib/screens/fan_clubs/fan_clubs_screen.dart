import 'package:crowdfans/components/post/post_avatar.dart';
import 'package:crowdfans/constants/pages.dart';
import 'package:crowdfans/constants/theme.dart';
import 'package:crowdfans/services/follow_service.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Lista de fan clubs (artistas seguidos).
class FanClubsScreen extends StatefulWidget {
  const FanClubsScreen({super.key});

  @override
  State<FanClubsScreen> createState() => _FanClubsScreenState();
}

class _FanClubsScreenState extends State<FanClubsScreen> {
  var _follows = <ArtistFollow>[];
  var _loading = true;
  String? _error;

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
      final follows = await FollowService.listFollows();
      setState(() => _follows = follows);
    } catch (_) {
      setState(() => _error = 'Não foi possível carregar os clubes.');
    } finally {
      if (mounted) {
        setState(() => _loading = false);
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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              child: Text(
                'Clubes',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  color: colors.textPrimary,
                ),
              ),
            ),
            if (_error != null)
              Padding(
                padding: const EdgeInsets.all(16),
                child: Text(_error!, style: TextStyle(color: colors.danger)),
              ),
            Expanded(
              child: _loading
                  ? const Center(child: CircularProgressIndicator())
                  : RefreshIndicator(
                      onRefresh: handleLoad,
                      child: _follows.isEmpty
                          ? ListView(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(top: 48),
                                  child: Text(
                                    'Você ainda não segue nenhum artista.',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      color: colors.textSecondary,
                                    ),
                                  ),
                                ),
                              ],
                            )
                          : ListView.builder(
                              itemCount: _follows.length,
                              itemBuilder: (context, index) {
                                final club = _follows[index];
                                return ListTile(
                                  leading: PostAvatar(
                                    url: club.avatarUrl,
                                    size: 48,
                                  ),
                                  title: Text(club.artistName),
                                  onTap: () => context.push(
                                    Pages.fanClubCommunity.replaceAll(
                                      ':artistId',
                                      club.artistUid,
                                    ),
                                  ),
                                );
                              },
                            ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
