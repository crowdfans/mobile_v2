import 'package:crowdfans/components/profile/notification_category_nav_row.dart';
import 'package:crowdfans/components/profile/notification_preference_section.dart';
import 'package:crowdfans/components/profile/notification_quiet_mode_note.dart';
import 'package:crowdfans/components/profile/profile_screen_header.dart';
import 'package:crowdfans/components/profile/profile_state.dart';
import 'package:crowdfans/constants/pages.dart';
import 'package:crowdfans/constants/theme.dart';
import 'package:crowdfans/services/notification_preferences_service.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Hub de preferências de notificação com categorias (CF-166).
class ProfileNotificationsScreen extends StatefulWidget {
  const ProfileNotificationsScreen({super.key});

  @override
  State<ProfileNotificationsScreen> createState() =>
      _ProfileNotificationsScreenState();
}

class _ProfileNotificationsScreenState
    extends State<ProfileNotificationsScreen> {
  var _preferences = Map<String, bool>.from(notificationPreferenceDefaults);
  var _loading = true;
  var _saving = false;
  String? _error;

  NotificationPreferenceGroup get _generalGroup =>
      notificationPreferenceGroups.firstWhere((group) => group.id == 'general');

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
      final next =
          await NotificationPreferencesService.getNotificationPreferences();
      if (!mounted) {
        return;
      }
      setState(() {
        _preferences = next;
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

  Future<void> handleChange(String key, bool value) async {
    final previous = Map<String, bool>.from(_preferences);
    final next = {..._preferences, key: value};
    setState(() {
      _preferences = next;
      _error = null;
      _saving = true;
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
      setState(() {
        _preferences = previous;
        _saving = false;
        _error = error.toString();
      });
    }
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
              title: _saving ? 'Salvando...' : 'Notificações',
              onBack: () => context.pop(),
            ),
            Expanded(
              child: _loading
                  ? const ProfileState(loading: true)
                  : ListView(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 36),
                      children: [
                        if (_error != null) ...[
                          NotificationQuietModeNote(message: _error),
                          const SizedBox(height: 16),
                        ],
                        if (quiet) ...[
                          const NotificationQuietModeNote(),
                          const SizedBox(height: 16),
                        ],
                        NotificationPreferenceSection(
                          group: _generalGroup,
                          preferences: _preferences,
                          saving: _saving,
                          onChanged: handleChange,
                        ),
                        const SizedBox(height: 28),
                        Text(
                          'Categorias detalhadas',
                          style: TextStyle(
                            // Mesmo peso/cor de “Preferências Gerais” (CF-166).
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: colors.textTertiary,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Organizamos os controles em páginas separadas para você ajustar melhor o que quer receber e de quais artistas.',
                          style: TextStyle(
                            fontSize: 13,
                            height: 1.4,
                            color: colors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 8),
                        for (var i = 0;
                            i < notificationCategoryGroups.length;
                            i++)
                          NotificationCategoryNavRow(
                            key: Key(
                              'notification-category-${notificationCategoryGroups[i].id}',
                            ),
                            title: notificationCategoryGroups[i].title,
                            subtitle:
                                notificationCategoryGroups[i].navSubtitle!,
                            showDivider:
                                i < notificationCategoryGroups.length - 1,
                            onTap: () => context.push(
                              notificationCategoryGroups[i].id == 'artists'
                                  ? Pages.profileNotificationsArtists
                                  : Pages.profileNotificationCategory(
                                      notificationCategoryGroups[i].id,
                                    ),
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
