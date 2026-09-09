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
                  id: 'profile',
                  label: 'Conta',
                  onTap: () => context.push(Pages.profileAccount),
                ),
                ProfileSettingItem(
                  id: 'security',
                  label: 'Segurança',
                  onTap: () => context.push(Pages.profileSecurity),
                ),
                ProfileSettingItem(
                  id: 'appearance',
                  label: 'Aparência',
                  onTap: () => context.push(Pages.profileAppearance),
                ),
                ProfileSettingItem(
                  id: 'notifications',
                  label: 'Notificações',
                  onTap: () => context.push(Pages.profileNotifications),
                ),
                ProfileSettingItem(
                  id: 'information',
                  label: 'Ajuda e documentos',
                  onTap: () => context.push(Pages.profileInformation),
                ),
              ],
            ),
            ProfileSettingsSection(
              title: 'Superfã',
              items: [
                ProfileSettingItem(
                  id: 'wallet',
                  label: 'Carteira',
                  onTap: () => context.push(Pages.profileWallet),
                ),
                ProfileSettingItem(
                  id: 'crowdfans-pro',
                  label: 'CrowdFans Pro',
                  onTap: () => context.push(Pages.profilePro),
                ),
                ProfileSettingItem(
                  id: 'memberships',
                  label: 'Memberships',
                  onTap: () => context.push(Pages.profileMemberships),
                ),
                ProfileSettingItem(
                  id: 'referral',
                  label: 'Indicações',
                  onTap: () => context.push(Pages.profileReferral),
                ),
                ProfileSettingItem(
                  id: 'fan-score',
                  label: 'Fan Score',
                  onTap: () => context.push(Pages.profileFanScore),
                ),
                ProfileSettingItem(
                  id: 'fan-letters',
                  label: 'Fan Letters',
                  onTap: () => context.push(Pages.fanLetterGallery),
                ),
              ],
            ),
            if (isArtist)
              ProfileSettingsSection(
                title: 'Artista',
                items: [
                  ProfileSettingItem(
                    id: 'earnings',
                    label: 'Ganhos',
                    onTap: () => context.push(Pages.profileEarnings),
                  ),
                  ProfileSettingItem(
                    id: 'insights',
                    label: 'Insights',
                    onTap: () => context.push(Pages.profileArtistInsights),
                  ),
                  ProfileSettingItem(
                    id: 'audience',
                    label: 'Público',
                    onTap: () => context.push(Pages.profileArtistAudience),
                  ),
                  ProfileSettingItem(
                    id: 'fan-club',
                    label: 'Gerenciar Fã Clube',
                    onTap: () => context.push(Pages.profileArtistFanClub),
                  ),
                ],
              ),
            ProfileSettingsSection(
              title: 'Privacidade e conteúdo',
              items: [
                ProfileSettingItem(
                  id: 'hidden-posts',
                  label: 'Posts ocultos',
                  onTap: () => context.push(Pages.profileHiddenPosts),
                ),
                ProfileSettingItem(
                  id: 'memories',
                  label: 'Memórias',
                  onTap: () => context.push(Pages.profileMemories),
                ),
                ProfileSettingItem(
                  id: 'blocked-users',
                  label: 'Bloqueados',
                  onTap: () => context.push(Pages.profileBlockedUsers),
                ),
                ProfileSettingItem(
                  id: 'moderation',
                  label: 'Moderação do Fã Clube',
                  onTap: () => context.push(Pages.profileModeration),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(24),
              child: OutlinedButton(
                key: const Key('settings-item-logout'),
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
