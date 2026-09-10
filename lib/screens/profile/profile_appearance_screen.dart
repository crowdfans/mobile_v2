import 'package:crowdfans/components/profile/appearance_theme_option_row.dart';
import 'package:crowdfans/components/profile/profile_screen_header.dart';
import 'package:crowdfans/constants/theme.dart';
import 'package:crowdfans/state/appearance_settings.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// Aparência: CrowdFans é somente tema claro.
class ProfileAppearanceScreen extends ConsumerWidget {
  const ProfileAppearanceScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = CrowdFansTheme.of(context);
    return Scaffold(
      backgroundColor: colors.background,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ProfileScreenHeader(
              title: 'Aparência',
              onBack: () => context.pop(),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 18),
              child: Text(
                'A CrowdFans usa apenas o tema claro neste dispositivo.',
                style: TextStyle(
                  fontSize: 14,
                  height: 1.5,
                  color: colors.textSecondary,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: colors.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: colors.border),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: AppearanceThemeOptionRow(
                    preference: AppearanceThemePreference.light,
                    selected: true,
                    onPressed: () {
                      ref
                          .read(appearanceSettingsProvider.notifier)
                          .setThemePreference(AppearanceThemePreference.light);
                    },
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
