import 'package:crowdfans/components/profile/profile_screen_header.dart';
import 'package:crowdfans/components/profile/profile_settings_section.dart';
import 'package:crowdfans/constants/pages.dart';
import 'package:crowdfans/constants/theme.dart';
import 'package:crowdfans/state/auth_session.dart';
import 'package:crowdfans/utils/app_alert.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// Hub de configurações alinhado aos prints CF-108.
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

    void openInformation({required String tab}) {
      context.push('${Pages.profileInformation}?tab=$tab');
    }

    final howYouUse = ProfileSettingsSection(
      title: 'Como você usa a Crowd Fans',
      items: [
        ProfileSettingItem(
          id: 'memberships',
          label: 'Meus Memberships',
          asset: 'assets/icons/Shapes/star-01.svg',
          onTap: () => context.push(Pages.profileMemberships),
        ),
        ProfileSettingItem(
          id: 'fan-score',
          label: 'FanScore',
          asset: 'assets/icons/Charts/chart-breakout-circle.svg',
          onTap: () => context.push(Pages.profileFanScore),
        ),
        ProfileSettingItem(
          id: 'memories',
          label: 'Memórias',
          asset: 'assets/icons/General/bookmark.svg',
          onTap: () => context.push(Pages.profileMemories),
        ),
        if (!isArtist)
          ProfileSettingItem(
            id: 'notifications',
            label: 'Notificações',
            asset: 'assets/icons/alerts_and_feedbacks/bell-01.svg',
            onTap: () => context.push(Pages.profileNotifications),
          ),
        if (!isArtist)
          ProfileSettingItem(
            id: 'moderation',
            label: 'Fã Clube',
            asset: 'assets/icons/alerts_and_feedbacks/announcement-03.svg',
            onTap: () => context.push(Pages.profileModeration),
          ),
      ],
    );

    final account = ProfileSettingsSection(
      title: 'Sua Conta',
      items: [
        ProfileSettingItem(
          id: 'profile',
          label: 'Seu Perfil',
          asset: 'assets/icons/Users/user-01.svg',
          onTap: () => context.push(Pages.profileAccount),
        ),
        ProfileSettingItem(
          id: 'security',
          label: 'Segurança e Login',
          asset: 'assets/icons/Security/passcode-lock.svg',
          onTap: () => context.push(Pages.profileSecurity),
        ),
        ProfileSettingItem(
          id: 'appearance',
          label: 'Aparência',
          asset: 'assets/icons/Media & devices/monitor-01.svg',
          onTap: () => context.push(Pages.profileAppearance),
        ),
      ],
    );

    final content = ProfileSettingsSection(
      title: 'Conteúdos',
      items: [
        ProfileSettingItem(
          id: 'blocked-users',
          label: 'Usuários Bloqueados',
          asset: 'assets/icons/General/slash-octagon.svg',
          onTap: () => context.push(Pages.profileBlockedUsers),
        ),
        ProfileSettingItem(
          id: 'hidden-posts',
          label: 'Posts Ocultados',
          asset: 'assets/icons/General/eye-off.svg',
          onTap: () => context.push(Pages.profileHiddenPosts),
        ),
      ],
    );

    final support = ProfileSettingsSection(
      title: 'Mais informações e suporte',
      items: [
        ProfileSettingItem(
          id: 'help',
          label: 'Ajuda',
          asset: 'assets/icons/General/info-square.svg',
          onTap: () => openInformation(tab: 'help'),
        ),
        ProfileSettingItem(
          id: 'terms',
          label: 'Termos de Uso',
          asset: 'assets/icons/Files/file-06.svg',
          onTap: () => openInformation(tab: 'terms'),
        ),
        ProfileSettingItem(
          id: 'privacy',
          label: 'Política de Privacidade',
          asset: 'assets/icons/Security/file-lock-02.svg',
          onTap: () => openInformation(tab: 'privacy'),
        ),
      ],
    );

    final session = ProfileSettingsSection(
      title: 'Sessão',
      showDivider: false,
      items: [
        ProfileSettingItem(
          id: 'logout',
          label: 'Sair da conta',
          asset: 'assets/icons/General/log-out-01.svg',
          showChevron: false,
          danger: true,
          onTap: handleLogout,
        ),
      ],
    );

    return Scaffold(
      backgroundColor: colors.background,
      body: SafeArea(
        child: Column(
          children: [
            ProfileScreenHeader(
              title: 'Configurações',
              onBack: () {
                if (context.canPop()) {
                  context.pop();
                  return;
                }
                context.go(Pages.me);
              },
            ),
            Expanded(
              child: ListView(
                children: [
                  if (isArtist)
                    ProfileSettingsSection(
                      title: 'Ferramentas do artista',
                      items: [
                        ProfileSettingItem(
                          id: 'insights',
                          label: 'Insights',
                          asset: 'assets/icons/Charts/bar-chart-square-02.svg',
                          onTap: () =>
                              context.push(Pages.profileArtistInsights),
                        ),
                        ProfileSettingItem(
                          id: 'audience',
                          label: 'Público',
                          asset: 'assets/icons/Users/users-01.svg',
                          onTap: () =>
                              context.push(Pages.profileArtistAudience),
                        ),
                        ProfileSettingItem(
                          id: 'artist-fan-club',
                          label: 'Fã Clube',
                          asset: 'assets/icons/Users/users-plus.svg',
                          onTap: () =>
                              context.push(Pages.profileArtistFanClub),
                        ),
                        ProfileSettingItem(
                          id: 'artist-notifications',
                          label: 'Notificações',
                          asset:
                              'assets/icons/alerts_and_feedbacks/bell-01.svg',
                          onTap: () =>
                              context.push(Pages.profileNotifications),
                        ),
                      ],
                    ),
                  howYouUse,
                  account,
                  content,
                  support,
                  session,
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
