import 'package:crowdfans/components/profile/information_document_view.dart';
import 'package:crowdfans/components/profile/profile_screen_header.dart';
import 'package:crowdfans/components/profile/settings_segmented_tabs.dart';
import 'package:crowdfans/constants/pages.dart';
import 'package:crowdfans/constants/theme.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

enum _InformationTab { terms, privacy }

/// Termos de Uso e Política de Privacidade.
/// Ajuda vive em [ProfileHelpScreen] (`Pages.profileHelp`).
///
/// CF-214: Política abre como página dedicada (sem abas), com hierarquia do print.
class ProfileInformationScreen extends StatefulWidget {
  const ProfileInformationScreen({super.key, this.initialTab});

  /// `help`, `terms` ou `privacy`. `help` redireciona para a Central de ajuda.
  final String? initialTab;

  @override
  State<ProfileInformationScreen> createState() =>
      _ProfileInformationScreenState();
}

class _ProfileInformationScreenState extends State<ProfileInformationScreen> {
  late _InformationTab _tab;
  var _redirectingHelp = false;
  var _privacyOnly = false;

  @override
  void initState() {
    super.initState();
    final raw = (widget.initialTab ?? '').toLowerCase();
    if (raw == 'help') {
      _redirectingHelp = true;
      _tab = _InformationTab.terms;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) {
          return;
        }
        context.go(Pages.profileHelp);
      });
      return;
    }
    _privacyOnly = raw == 'privacy';
    _tab = _privacyOnly ? _InformationTab.privacy : _InformationTab.terms;
  }

  @override
  Widget build(BuildContext context) {
    final colors = CrowdFansTheme.of(context);
    if (_redirectingHelp) {
      return Scaffold(
        backgroundColor: colors.background,
        body: const Center(child: CircularProgressIndicator()),
      );
    }
    final headerTitle = _privacyOnly
        ? 'Política de Privacidade'
        : (_tab == _InformationTab.terms
              ? 'Termos de Uso'
              : 'Política de Privacidade');
    return Scaffold(
      backgroundColor: colors.background,
      body: SafeArea(
        child: Column(
          children: [
            ProfileScreenHeader(
              title: headerTitle,
              onBack: () => context.pop(),
            ),
            if (!_privacyOnly)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 6, 16, 0),
                child: SettingsSegmentedTabs(
                  labels: const ['Termos', 'Privacidade'],
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
                  if (_tab == _InformationTab.terms)
                    const InformationDocumentView(
                      title: 'Termos de Uso',
                      intro:
                          'Regras essenciais para uso da plataforma, da conta, das comunidades e das experiências CrowdFans.',
                      lastUpdated:
                          'Última atualização: 17 de março de 2026.',
                      sections: informationTermsSections,
                    )
                  else
                    const InformationDocumentView(
                      title: 'Política de privacidade detalhada',
                      intro:
                          'Este texto consolida, em formato mais completo, como o ecossistema atual da Crowd Fans trata dados de conta, segurança, interação social, memberships, conteúdo e suporte.',
                      lastUpdated:
                          'Última atualização: 17 de março de 2026.',
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
