import 'package:crowdfans/components/input/app_text_field.dart';
import 'package:crowdfans/components/profile/profile_followed_artist_row.dart';
import 'package:crowdfans/components/profile/profile_screen_header.dart';
import 'package:crowdfans/components/profile/profile_state.dart';
import 'package:crowdfans/constants/pages.dart';
import 'package:crowdfans/constants/theme.dart';
import 'package:crowdfans/models/fan_profile.dart';
import 'package:crowdfans/services/profile_service.dart';
import 'package:crowdfans/state/auth_session.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// Artistas seguidos pelo viewer ou por outro handle.
class ProfileArtistsScreen extends ConsumerStatefulWidget {
  const ProfileArtistsScreen({super.key, this.handle});

  final String? handle;

  @override
  ConsumerState<ProfileArtistsScreen> createState() =>
      _ProfileArtistsScreenState();
}

class _ProfileArtistsScreenState extends ConsumerState<ProfileArtistsScreen> {
  FanProfileMeta? _profile;
  var _artists = <FollowedArtist>[];
  var _search = '';
  var _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    handleLoad();
  }

  Future<String> resolveHandle() async {
    final requested = widget.handle?.trim() ?? '';
    if (requested.isNotEmpty) {
      return requested;
    }
    final stored = ref.read(authSessionProvider).profile;
    if (stored != null) {
      return stored.name.isNotEmpty ? stored.name : stored.displayName;
    }
    final mine = await ProfileService.getMyProfile();
    return mine.name.isNotEmpty ? mine.name : mine.displayName;
  }

  Future<void> handleLoad() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final handle = await resolveHandle();
      final response = await ProfileService.getFollowedArtists(handle);
      if (!mounted) {
        return;
      }
      setState(() {
        _profile = response.profile;
        _artists = response.followedArtists;
        _loading = false;
      });
    } catch (_) {
      if (!mounted) {
        return;
      }
      setState(() {
        _loading = false;
        _error = 'Não foi possível carregar os artistas.';
      });
    }
  }

  void handleBack() {
    if (context.canPop()) {
      context.pop();
      return;
    }
    context.go(Pages.me);
  }

  List<FollowedArtist> get _filtered {
    final query = _search.trim().toLowerCase();
    if (query.isEmpty) {
      return _artists;
    }
    return [
      for (final artist in _artists)
        if (artist.label.toLowerCase().contains(query)) artist,
    ];
  }

  @override
  Widget build(BuildContext context) {
    final colors = CrowdFansTheme.of(context);
    final title = (_profile?.displayName ?? '').isEmpty
        ? 'Artistas'
        : 'Artistas de ${_profile!.displayName}';
    final filtered = _filtered;
    return Scaffold(
      backgroundColor: colors.background,
      body: SafeArea(
        child: Column(
          children: [
            ProfileScreenHeader(title: title, onBack: handleBack),
            if (_loading)
              const Expanded(child: ProfileState(loading: true))
            else if (_error != null)
              Expanded(
                child: ProfileState(
                  title: 'Artistas indisponíveis',
                  message: _error,
                  actionLabel: 'Tentar novamente',
                  onAction: handleLoad,
                ),
              )
            else ...[
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
                child: AppTextField(
                  hint: 'Buscar artista',
                  onChanged: (value) => setState(() => _search = value),
                ),
              ),
              Expanded(
                child: RefreshIndicator(
                  onRefresh: handleLoad,
                  child: filtered.isEmpty
                      ? ListView(
                          children: [
                            ProfileState(
                              title: _search.trim().isEmpty
                                  ? 'Nenhum artista seguido'
                                  : 'Nenhum artista encontrado',
                              message: _search.trim().isEmpty
                                  ? 'Os artistas seguidos aparecem aqui.'
                                  : 'Tente buscar por outro nome.',
                            ),
                          ],
                        )
                      : ListView.separated(
                          padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
                          itemCount: filtered.length,
                          separatorBuilder: (_, _) =>
                              Divider(height: 1, color: colors.border),
                          itemBuilder: (context, index) {
                            final artist = filtered[index];
                            return ProfileFollowedArtistRow(
                              artist: artist,
                              onTap: artist.id.isEmpty
                                  ? null
                                  : () {
                                      context.push(
                                        Pages.artistProfile.replaceAll(
                                          ':artistId',
                                          artist.id,
                                        ),
                                      );
                                    },
                            );
                          },
                        ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
