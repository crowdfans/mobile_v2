import 'package:crowdfans/components/profile/fan_club_moderation_community_row.dart';
import 'package:crowdfans/components/profile/profile_screen_header.dart';
import 'package:crowdfans/constants/pages.dart';
import 'package:crowdfans/constants/theme.dart';
import 'package:crowdfans/services/fan_club_viewer_service.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Lista clubs que o viewer pode moderar.
class FanClubModerationListScreen extends StatefulWidget {
  const FanClubModerationListScreen({super.key});

  @override
  State<FanClubModerationListScreen> createState() =>
      _FanClubModerationListScreenState();
}

class _FanClubModerationListScreenState
    extends State<FanClubModerationListScreen> {
  var _items = <FanClubModerationCommunity>[];
  var _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    handleLoad();
  }

  void handleBack() {
    if (context.canPop()) {
      context.pop();
      return;
    }
    context.go(Pages.profileModeration);
  }

  Future<void> handleLoad() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final items = await FanClubViewerService.listMyModerationCommunities();
      if (!mounted) {
        return;
      }
      setState(() {
        _items = items;
        _loading = false;
      });
    } catch (_) {
      if (!mounted) {
        return;
      }
      setState(() {
        _loading = false;
        _error = 'Não foi possível carregar os clubs.';
      });
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
            ProfileScreenHeader(title: 'Moderação', onBack: handleBack),
            Expanded(
              child: _loading
                  ? const Center(child: CircularProgressIndicator())
                  : RefreshIndicator(
                      onRefresh: handleLoad,
                      child: ListView(
                        padding: const EdgeInsets.fromLTRB(16, 8, 16, 40),
                        children: [
                          if (_error != null)
                            Text(
                              _error!,
                              textAlign: TextAlign.center,
                              style: TextStyle(color: colors.textSecondary),
                            )
                          else if (_items.isEmpty)
                            Padding(
                              padding: const EdgeInsets.only(top: 40),
                              child: Text(
                                'Você ainda não modera nenhum fã clube.',
                                textAlign: TextAlign.center,
                                style: TextStyle(color: colors.textSecondary),
                              ),
                            )
                          else
                            for (final item in _items) ...[
                              FanClubModerationCommunityRow(
                                community: item,
                                onTap: () => context.push(
                                  Pages.fanClubModerationOf(
                                    artistId: item.artistUid,
                                    name: item.artistName,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 12),
                            ],
                        ],
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
