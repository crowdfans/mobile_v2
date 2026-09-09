import 'package:crowdfans/components/profile/profile_settings_section.dart';
import 'package:crowdfans/components/toolbar/toolbar_back_button.dart';
import 'package:crowdfans/constants/pages.dart';
import 'package:crowdfans/constants/theme.dart';
import 'package:crowdfans/state/auth_session.dart';
import 'package:crowdfans/utils/app_alert.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// Hub de configurações (espelho do `ProfileSettingsScreen`).
class ProfileSettingsScreen extends ConsumerWidget {
  const ProfileSettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = CrowdFansTheme.of(context);
    final isArtist = ref.watch(authSessionProvider).profile?.isArtist ?? false;

    Future<void> handleLogout() async {
      final ok = await AppAlert.confirm(
        context,
        title: 'Sair',
        message: 'Deseja encerrar a sessão?',
        confirmLabel: 'Sair',
      );
      if (!ok) {
        return;
      }
      await ref.read(authSessionProvider.notifier).logout();
    }

    return Scaffold(
      backgroundColor: colors.background,
      body: SafeArea(
        child: ListView(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Row(
                children: [
                  ToolbarBackButton(onPressed: () => context.pop()),
                  Text(
                    'Ajustes',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: colors.textPrimary,
                    ),
                  ),
                ],
              ),
            ),
            ProfileSettingsSection(
              title: 'Conta',
              items: [
                ProfileSettingItem(
                  label: 'Conta',
                  onTap: () => context.push(Pages.profileAccount),
                ),
                ProfileSettingItem(
                  label: 'Segurança',
                  onTap: () => context.push(Pages.profileSecurity),
                ),
                ProfileSettingItem(
                  label: 'Aparência',
                  onTap: () => context.push(Pages.profileAppearance),
                ),
                ProfileSettingItem(
                  label: 'Notificações',
                  onTap: () => context.push(Pages.profileNotifications),
                ),
                ProfileSettingItem(
                  label: 'Ajuda e documentos',
                  onTap: () => context.push(Pages.profileInformation),
                ),
              ],
            ),
            ProfileSettingsSection(
              title: 'Superfã',
              items: [
                ProfileSettingItem(
                  label: 'Carteira',
                  onTap: () => context.push(Pages.profileWallet),
                ),
                ProfileSettingItem(
                  label: 'CrowdFans Pro',
                  onTap: () => context.push(Pages.profilePro),
                ),
                ProfileSettingItem(
                  label: 'Memberships',
                  onTap: () => context.push(Pages.profileMemberships),
                ),
                ProfileSettingItem(
                  label: 'Indicações',
                  onTap: () => context.push(Pages.profileReferral),
                ),
              ],
            ),
            if (isArtist)
              ProfileSettingsSection(
                title: 'Artista',
                items: [
                  ProfileSettingItem(
                    label: 'Ganhos',
                    onTap: () => context.push(Pages.profileEarnings),
                  ),
                  ProfileSettingItem(
                    label: 'Insights',
                    onTap: () => context.push(Pages.profileArtistInsights),
                  ),
                ],
              ),
            ProfileSettingsSection(
              title: 'Privacidade e conteúdo',
              items: [
                ProfileSettingItem(
                  label: 'Posts ocultos',
                  onTap: () => context.push(Pages.profileHiddenPosts),
                ),
                ProfileSettingItem(
                  label: 'Memórias',
                  onTap: () => context.push(Pages.profileMemories),
                ),
                ProfileSettingItem(
                  label: 'Bloqueados',
                  onTap: () => context.push(Pages.profileBlockedUsers),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(24),
              child: OutlinedButton(
                onPressed: handleLogout,
                child: const Text('Sair'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
