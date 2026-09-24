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
    _tab = raw == 'privacy' ? _InformationTab.privacy : _InformationTab.terms;
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
    return Scaffold(
      backgroundColor: colors.background,
      body: SafeArea(
        child: Column(
          children: [
            ProfileScreenHeader(
              title: 'Documentos',
              onBack: () => context.pop(),
            ),
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
                      sections: informationTermsSections,
                    )
                  else
                    const InformationDocumentView(
                      title: 'Política de Privacidade',
                      intro:
                          'Como os dados de conta, segurança, interação e suporte são tratados no ecossistema CrowdFans.',
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
