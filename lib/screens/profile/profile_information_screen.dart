import 'package:crowdfans/components/buttons/app_button.dart';
import 'package:crowdfans/components/profile/information_document_view.dart';
import 'package:crowdfans/components/profile/profile_screen_header.dart';
import 'package:crowdfans/components/profile/settings_segmented_tabs.dart';
import 'package:crowdfans/constants/pages.dart';
import 'package:crowdfans/constants/theme.dart';
import 'package:crowdfans/utils/app_alert.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

enum _InformationTab { help, terms, privacy }

/// Ajuda, Termos de Uso e Política de Privacidade.
class ProfileInformationScreen extends StatefulWidget {
  const ProfileInformationScreen({super.key, this.initialTab});

  /// `help`, `terms` ou `privacy`.
  final String? initialTab;

  @override
  State<ProfileInformationScreen> createState() =>
      _ProfileInformationScreenState();
}

class _ProfileInformationScreenState extends State<ProfileInformationScreen> {
  late _InformationTab _tab;

  @override
  void initState() {
    super.initState();
    _tab = switch ((widget.initialTab ?? '').toLowerCase()) {
      'terms' => _InformationTab.terms,
      'privacy' => _InformationTab.privacy,
      _ => _InformationTab.help,
    };
  }

  Future<void> handleContactSupport() async {
    final uri = Uri.parse('mailto:support@crowdfans.app');
    final ok = await launchUrl(uri);
    if (!ok && mounted) {
      await AppAlert.show(
        context,
        title: 'Suporte',
        message: 'Não foi possível abrir o e-mail. Escreva para support@crowdfans.app.',
      );
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
            ProfileScreenHeader(
              title: 'Ajuda e documentos',
              onBack: () => context.pop(),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 6, 16, 0),
              child: SettingsSegmentedTabs(
                labels: const ['Ajuda', 'Termos', 'Privacidade'],
                selectedIndex: _tab.index,
                onChanged: (index) {
                  setState(() => _tab = _InformationTab.values[index]);
                },
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 20, 16, 36),
                children: [
                  if (_tab == _InformationTab.help) ...[
                    Text(
                      'Como podemos ajudar?',
                      style: TextStyle(
                        fontSize: 23,
                        fontWeight: FontWeight.w900,
                        color: colors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Encontre os atalhos principais do perfil ou fale com a equipe de suporte.',
                      style: TextStyle(
                        fontSize: 14,
                        height: 1.55,
                        color: colors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 20),
                    const InformationHelpCard(
                      question: 'Como altero meus dados?',
                      answer: 'Em Seu perfil você pode atualizar nome, username, bio e URL pública da foto. Alterações de senha e e-mail ficam em Segurança e login.',
                    ),
                    const SizedBox(height: 12),
                    const InformationHelpCard(
                      question: 'Onde acompanho memberships e Fan Score?',
                      answer: 'As duas áreas ficam nas configurações e usam os dados retornados pela API para o seu perfil.',
                    ),
                    const SizedBox(height: 12),
                    const InformationHelpCard(
                      question: 'Uma função aparece indisponível. Por quê?',
                      answer: 'Recursos que no aplicativo legado eram apenas simulados ficam identificados como dependentes do backend. Assim nenhuma ação fictícia é apresentada como concluída.',
                    ),
                    const SizedBox(height: 20),
                    AppButton(
                      label: 'Segurança e login',
                      variant: AppButtonVariant.outline,
                      onPressed: () => context.push(Pages.profileSecurity),
                    ),
                    const SizedBox(height: 10),
                    AppButton(
                      label: 'Meus Memberships',
                      variant: AppButtonVariant.outline,
                      onPressed: () => context.push(Pages.profileMemberships),
                    ),
                    const SizedBox(height: 10),
                    AppButton(
                      label: 'Falar com o suporte',
                      onPressed: handleContactSupport,
                    ),
                  ] else if (_tab == _InformationTab.terms)
                    const InformationDocumentView(
                      title: 'Termos de Uso',
                      intro: 'Regras essenciais para uso da plataforma, da conta, das comunidades e das experiências CrowdFans.',
                      sections: informationTermsSections,
                    )
                  else
                    const InformationDocumentView(
                      title: 'Política de Privacidade',
                      intro: 'Como os dados de conta, segurança, interação e suporte são tratados no ecossistema CrowdFans.',
                      sections: informationPrivacySections,
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
