import 'package:crowdfans/components/profile/notification_preference_section.dart';
import 'package:crowdfans/components/profile/notification_quiet_mode_note.dart';
import 'package:crowdfans/components/profile/profile_screen_header.dart';
import 'package:crowdfans/components/profile/profile_state.dart';
import 'package:crowdfans/constants/theme.dart';
import 'package:crowdfans/services/notification_preferences_service.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Página de uma categoria detalhada de notificações (CF-166).
class ProfileNotificationCategoryScreen extends StatefulWidget {
  const ProfileNotificationCategoryScreen({
    super.key,
    required this.categoryId,
  });

  final String categoryId;

  @override
  State<ProfileNotificationCategoryScreen> createState() =>
      _ProfileNotificationCategoryScreenState();
}

class _ProfileNotificationCategoryScreenState
    extends State<ProfileNotificationCategoryScreen> {
  var _preferences = Map<String, bool>.from(notificationPreferenceDefaults);
  var _loading = true;
  var _saving = false;
  String? _error;

  NotificationPreferenceGroup? get _group =>
      notificationGroupById(widget.categoryId);

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
    final group = _group;
    final quiet =
        _preferences[NotificationPreferenceKeys.quietModeEnabled] == true;
    return Scaffold(
      backgroundColor: colors.background,
      body: SafeArea(
        child: Column(
          children: [
            ProfileScreenHeader(
              title: group?.title ?? 'Notificações',
              onBack: () => context.pop(),
            ),
            Expanded(
              child: group == null
                  ? const ProfileState(
                      title: 'Categoria indisponível',
                      message: 'Esta categoria de notificações não existe.',
                    )
                  : _loading
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
                        if ((group.pageIntro ?? '').trim().isNotEmpty) ...[
                          Text(
                            group.pageIntro!,
                            style: TextStyle(
                              fontSize: 14,
                              height: 1.4,
                              color: colors.textSecondary,
                            ),
                          ),
                          const SizedBox(height: 20),
                        ],
                        NotificationPreferenceSection(
                          group: group,
                          preferences: _preferences,
                          saving: _saving,
                          onChanged: handleChange,
                          showTitle: false,
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
