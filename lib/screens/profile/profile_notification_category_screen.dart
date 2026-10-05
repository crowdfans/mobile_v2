import 'package:crowdfans/components/profile/notification_preference_error_banner.dart';
import 'package:crowdfans/components/profile/notification_preference_section.dart';
import 'package:crowdfans/components/profile/notification_quiet_mode_note.dart';
import 'package:crowdfans/components/profile/profile_screen_header.dart';
import 'package:crowdfans/components/profile/profile_state.dart';
import 'package:crowdfans/constants/theme.dart';
import 'package:crowdfans/mocks/cf_temp_mocks.dart';
import 'package:crowdfans/services/notification_preferences_service.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Página de uma categoria detalhada de notificações (CF-166 / CF-208+).
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
  var _loaded = false;
  var _saving = false;
  String? _error;

  NotificationPreferenceGroup? get _group =>
      notificationGroupById(widget.categoryId);

  /// Fixtures de print só quando a flag da categoria está ligada.
  bool get _usePrintFixtures {
    if (!kUseCfTempMocks) {
      return false;
    }
    if (CfTempMocks.useNotificationCategoryPrintFixtures) {
      return true;
    }
    // CF-209 — Meet & Greet (não liga hub CF-166 / CF-211).
    if (widget.categoryId == 'meet' &&
        CfTempMocks.useMeetGreetNotifPrintFixtures) {
      return true;
    }
    // CF-211 — Membership e Jam Coins (não liga CF-208/209).
    return widget.categoryId == 'wallet' &&
        CfTempMocks.useMembershipNotifPrintFixtures;
  }

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
        _preferences = _usePrintFixtures
            ? Cf208209211NotificationPrintFixtures.preferences()
            : next;
        _loading = false;
        _loaded = true;
        _error = null;
      });
    } catch (error) {
      if (!mounted) {
        return;
      }
      if (_usePrintFixtures) {
        setState(() {
          _preferences = Cf208209211NotificationPrintFixtures.preferences();
          _loading = false;
          _loaded = true;
          _error = null;
        });
        return;
      }
      setState(() {
        _loading = false;
        _loaded = false;
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
        _preferences = _usePrintFixtures
            ? {...saved, key: value}
            : saved;
        _saving = false;
      });
    } catch (error) {
      if (!mounted) {
        return;
      }
      if (_usePrintFixtures) {
        // TEMP: mantém o valor do print localmente sem fingir sucesso remoto.
        setState(() {
          _saving = false;
        });
        return;
      }
      setState(() {
        _preferences = previous;
        _saving = false;
        _error =
            'Não foi possível salvar. As preferências voltaram ao estado anterior.';
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
                  : !_loaded
                  ? ProfileState(
                      title: 'Não foi possível carregar',
                      message: _error ??
                          'Tente novamente para ver e ajustar as preferências.',
                      actionLabel: 'Tentar de novo',
                      onAction: handleLoad,
                    )
                  : ListView(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 36),
                      children: [
                        if (_error != null) ...[
                          NotificationPreferenceErrorBanner(message: _error!),
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
