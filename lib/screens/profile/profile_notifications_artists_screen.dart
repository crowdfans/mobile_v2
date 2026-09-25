import 'package:crowdfans/components/profile/notification_preference_row.dart';
import 'package:crowdfans/components/profile/notification_preference_section.dart';
import 'package:crowdfans/components/profile/profile_screen_header.dart';
import 'package:crowdfans/components/profile/profile_state.dart';
import 'package:crowdfans/constants/theme.dart';
import 'package:crowdfans/mocks/cf_temp_mocks.dart';
import 'package:crowdfans/services/follow_service.dart';
import 'package:crowdfans/services/notification_artist_alerts_store.dart';
import 'package:crowdfans/services/notification_preferences_service.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Subpágina Notificações → Artistas e Fã Clubes (dois níveis visuais).
class ProfileNotificationsArtistsScreen extends StatefulWidget {
  const ProfileNotificationsArtistsScreen({super.key});

  @override
  State<ProfileNotificationsArtistsScreen> createState() =>
      _ProfileNotificationsArtistsScreenState();
}

class _ProfileNotificationsArtistsScreenState
    extends State<ProfileNotificationsArtistsScreen> {
  var _preferences = Map<String, bool>.from(notificationPreferenceDefaults);
  var _artistAlerts = <String, bool>{};
  var _artists = <ArtistFollow>[];
  var _loading = true;
  var _saving = false;
  String? _error;

  static const _alertTypes = <NotificationPreferenceItem>[
    NotificationPreferenceItem(
      keyName: NotificationPreferenceKeys.clubPosts,
      title: 'Posts de fã clubes',
      description:
          'Novos posts e movimento nos fã clubes que você acompanha.',
    ),
    NotificationPreferenceItem(
      keyName: NotificationPreferenceKeys.exclusiveContent,
      title: 'Conteúdo exclusivo',
      description:
          'Quando artistas liberarem conteúdo exclusivo para membros.',
    ),
    NotificationPreferenceItem(
      keyName: NotificationPreferenceKeys.fanLetterReceived,
      title: 'Novas Cartas de Fã',
      description:
          'Quando você receber cartas novas ou quando houver atividade nelas.',
    ),
    NotificationPreferenceItem(
      keyName: NotificationPreferenceKeys.artistHighlights,
      title: 'Destaques do artista',
      description:
          'Quando o artista destacar algo seu, como comentário, carta ou post.',
    ),
  ];

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
      final prefs =
          await NotificationPreferencesService.getNotificationPreferences();
      var artists = await FollowService.listFollows();
      artists = [for (final a in artists) if (a.isFollowing) a];
      if (artists.isEmpty &&
          kUseCfTempMocks &&
          CfTempMocks.useNotificationPrefFixtures) {
        artists = Cf213NotificationPrefFixtures.followedArtists();
      }
      final artistAlerts = await NotificationArtistAlertsStore.load();
      final usePrintDefaults = kUseCfTempMocks &&
          CfTempMocks.useNotificationPrefFixtures;
      if (!mounted) {
        return;
      }
      setState(() {
        _preferences = usePrintDefaults
            ? Cf213NotificationPrefFixtures.alertTypeDefaultsOff()
            : prefs;
        _artists = artists;
        _artistAlerts = {
          for (final a in _artists)
            a.artistUid: usePrintDefaults
                ? false
                : (artistAlerts[a.artistUid] ?? true),
        };
        _loading = false;
      });
    } catch (error) {
      if (!mounted) {
        return;
      }
      if (kUseCfTempMocks && CfTempMocks.useNotificationPrefFixtures) {
        final artists = Cf213NotificationPrefFixtures.followedArtists();
        setState(() {
          _preferences = Cf213NotificationPrefFixtures.alertTypeDefaultsOff();
          _artists = artists;
          _artistAlerts = {for (final a in artists) a.artistUid: false};
          _loading = false;
          _error = null;
        });
        return;
      }
      setState(() {
        _loading = false;
        _error = error.toString();
      });
    }
  }

  Future<void> handleTypeChange(String key, bool value) async {
    final previous = Map<String, bool>.from(_preferences);
    final next = {..._preferences, key: value};
    setState(() {
      _preferences = next;
      _saving = true;
      _error = null;
    });
    try {
      final saved =
          await NotificationPreferencesService.updateNotificationPreferences(
            next,
          );
      if (!mounted) {
        return;
      }
      setState(() {
        _preferences = saved;
        _saving = false;
      });
    } catch (error) {
      if (!mounted) {
        return;
      }
      // Com fixtures: mantém o estado local e não reverte (API pode falhar).
      if (kUseCfTempMocks && CfTempMocks.useNotificationPrefFixtures) {
        setState(() {
          _saving = false;
        });
        return;
      }
      setState(() {
        _preferences = previous;
        _saving = false;
        _error = error.toString();
      });
    }
  }

  Future<void> handleArtistChange(String artistId, bool value) async {
    setState(() {
      _artistAlerts = {..._artistAlerts, artistId: value};
    });
    await NotificationArtistAlertsStore.setEnabled(artistId, value);
  }

  String artistSubtitle(ArtistFollow artist, int index) {
    final samples = Cf213NotificationPrefFixtures.artistSubtitles;
    return samples[index % samples.length];
  }

  @override
  Widget build(BuildContext context) {
    final colors = CrowdFansTheme.of(context);
    final quiet =
        _preferences[NotificationPreferenceKeys.quietModeEnabled] == true;
    return Scaffold(
      backgroundColor: colors.background,
      body: SafeArea(
        child: Column(
          children: [
            ProfileScreenHeader(
              title: _saving ? 'Salvando...' : 'Artistas e Fã Clubes',
              onBack: () => context.pop(),
            ),
            Expanded(
              child: _loading
                  ? const ProfileState(loading: true)
                  : ListView(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 36),
                      children: [
                        if (_error != null) ...[
                          Text(
                            _error!,
                            style: TextStyle(color: colors.danger, fontSize: 13),
                          ),
                          const SizedBox(height: 16),
                        ],
                        Text(
                          'Tipos de alerta',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: colors.textTertiary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        for (var i = 0; i < _alertTypes.length; i++)
                          NotificationPreferenceRow(
                            title: _alertTypes[i].title,
                            description: _alertTypes[i].description,
                            value:
                                _preferences[_alertTypes[i].keyName] ?? false,
                            enabled: !(
                              _saving ||
                              (quiet && !_alertTypes[i].critical)
                            ),
                            showDivider: i > 0,
                            onChanged: (value) => handleTypeChange(
                              _alertTypes[i].keyName,
                              value,
                            ),
                          ),
                        const SizedBox(height: 28),
                        Text(
                          'Por artista',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: colors.textTertiary,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Defina de quais artistas você quer receber alertas de posts, cartas, fã clube, conteúdo exclusivo e destaques.',
                          style: TextStyle(
                            fontSize: 13,
                            height: 1.4,
                            color: colors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 8),
                        if (_artists.isEmpty)
                          Text(
                            'Siga artistas para personalizar alertas por pessoa.',
                            style: TextStyle(
                              fontSize: 13,
                              color: colors.textSecondary,
                            ),
                          )
                        else
                          for (var i = 0; i < _artists.length; i++)
                            NotificationPreferenceRow(
                              title: _artists[i].artistName,
                              description: artistSubtitle(_artists[i], i),
                              value:
                                  _artistAlerts[_artists[i].artistUid] ?? false,
                              enabled: !_saving && !quiet,
                              showDivider: i > 0,
                              onChanged: (value) => handleArtistChange(
                                _artists[i].artistUid,
                                value,
                              ),
                            ),
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
