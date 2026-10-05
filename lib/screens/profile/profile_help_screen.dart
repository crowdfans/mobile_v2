import 'package:crowdfans/components/profile/help_faq_section.dart';
import 'package:crowdfans/components/profile/help_quick_access_row.dart';
import 'package:crowdfans/components/profile/profile_screen_header.dart';
import 'package:crowdfans/constants/pages.dart';
import 'package:crowdfans/constants/theme.dart';
import 'package:crowdfans/content/help_content.dart';
import 'package:crowdfans/utils/app_alert.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

/// Central de ajuda — hierarquia de títulos, explicações e links (CF-198).
///
/// Conteúdo oficial em [HelpContent] (estático no app; sem CMS). Overrides
/// opcionais só para testes (empty/red).
class ProfileHelpScreen extends StatelessWidget {
  const ProfileHelpScreen({
    super.key,
    this.quickAccessOverride,
    this.faqSectionsOverride,
  });

  /// Quando não-null, substitui [HelpContent.quickAccess] (ex.: lista vazia).
  final List<HelpQuickAccessItem>? quickAccessOverride;

  /// Quando não-null, substitui [HelpContent.faqSections].
  final List<HelpFaqSectionData>? faqSectionsOverride;

  Future<void> handleContactSupport(BuildContext context) async {
    final uri = Uri.parse(HelpContent.supportEmail);
    final ok = await launchUrl(uri);
    if (!ok && context.mounted) {
      await AppAlert.show(
        context,
        title: 'Suporte',
        message:
            'Não foi possível abrir o e-mail. Escreva para support@crowdfans.app.',
      );
    }
  }

  void handleQuickAccess(BuildContext context, String destination) {
    switch (destination) {
      case 'profileSecurity':
        context.push(Pages.profileSecurity);
      case 'profileMemberships':
        context.push(Pages.profileMemberships);
      case 'profileInformationTerms':
        context.push('${Pages.profileInformation}?tab=terms');
      case 'profileInformationPrivacy':
        context.push('${Pages.profileInformation}?tab=privacy');
      default:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = CrowdFansTheme.of(context);
    final quickAccess = quickAccessOverride ?? HelpContent.quickAccess();
    final faqSections = faqSectionsOverride ?? HelpContent.faqSections();
    final hasContent = quickAccess.isNotEmpty || faqSections.isNotEmpty;

    return Scaffold(
      backgroundColor: colors.background,
      body: SafeArea(
        child: Column(
          children: [
            ProfileScreenHeader(
              title: HelpContent.headerTitle,
              onBack: () {
                if (context.canPop()) {
                  context.pop();
                  return;
                }
                context.go(Pages.profileSettings);
              },
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 40),
                child: !hasContent
                    ? Padding(
                        padding: const EdgeInsets.only(top: 24),
                        child: Text(
                          HelpContent.emptyMessage,
                          style: TextStyle(
                            fontSize: 14,
                            color: colors.textSecondary,
                          ),
                        ),
                      )
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Semantics(
                            header: true,
                            child: Text(
                              HelpContent.heroTitle,
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.w900,
                                color: colors.textPrimary,
                              ),
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            HelpContent.intro,
                            style: TextStyle(
                              fontSize: 14,
                              height: 1.55,
                              color: colors.textSecondary,
                            ),
                          ),
                          const SizedBox(height: 28),
                          Semantics(
                            header: true,
                            child: Text(
                              HelpContent.quickAccessSectionTitle,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.4,
                                color: colors.textTertiary,
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          for (var i = 0; i < quickAccess.length; i++)
                            HelpQuickAccessRow(
                              title: quickAccess[i].title,
                              subtitle: quickAccess[i].subtitle,
                              onTap: () => handleQuickAccess(
                                context,
                                quickAccess[i].destination,
                              ),
                              showDivider: i < quickAccess.length - 1,
                            ),
                          const SizedBox(height: 28),
                          for (final section in faqSections) ...[
                            HelpFaqSection(
                              title: section.title,
                              items: section.items,
                            ),
                            const SizedBox(height: 8),
                          ],
                          Semantics(
                            button: true,
                            label: HelpContent.supportSemantics,
                            child: TextButton(
                              onPressed: () => handleContactSupport(context),
                              child: Text(
                                HelpContent.supportLabel,
                                style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                  color: colors.primary,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
