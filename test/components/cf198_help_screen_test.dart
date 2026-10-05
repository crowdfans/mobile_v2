import 'package:crowdfans/components/profile/help_faq_section.dart';
import 'package:crowdfans/components/profile/help_quick_access_row.dart';
import 'package:crowdfans/constants/pages.dart';
import 'package:crowdfans/constants/theme.dart';
import 'package:crowdfans/content/help_content.dart';
import 'package:crowdfans/mocks/cf_temp_mocks.dart';
import 'package:crowdfans/screens/profile/profile_help_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// MaterialApp isolado (sem GoRouter) para a hierarquia CF-198.
class HelpTestApp extends StatelessWidget {
  const HelpTestApp(this.child, {super.key});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: buildCrowdFansTheme(Brightness.light),
      home: child,
    );
  }
}

void main() {
  group('CF-198 help screen (green)', () {
    testWidgets('print: hero + 4 acessos + Conta e perfil expandido', (
      tester,
    ) async {
      // Demock: fixtures off, conteúdo oficial ainda preenche a tela.
      expect(cf198HelpFixturesEnabled(), isFalse);
      expect(CfTempMocks.useHelpFixtures, isFalse);

      await tester.pumpWidget(const HelpTestApp(ProfileHelpScreen()));
      await tester.pump();

      expect(find.text('Ajuda'), findsOneWidget);
      expect(find.text('Central de ajuda'), findsOneWidget);
      expect(find.text('Acessos rápidos'), findsOneWidget);
      expect(find.text('Segurança e Login'), findsOneWidget);
      expect(find.text('Meus Memberships'), findsOneWidget);
      expect(find.text('Termos de Uso'), findsOneWidget);
      expect(find.text('Política de Privacidade'), findsOneWidget);
      expect(find.byType(HelpQuickAccessRow), findsNWidgets(4));
      expect(find.text('Conta e perfil'), findsOneWidget);
      expect(find.text('Como crio uma conta de fã?'), findsOneWidget);
      expect(find.textContaining('validação por OTP'), findsOneWidget);
      expect(
        find.text('Como funciona a entrada de artistas?'),
        findsOneWidget,
      );
      // Resposta já aberta (não accordion): texto visível sem expandir.
      expect(
        find.textContaining(
          'Perfis de artistas podem existir antes da entrada oficial',
        ),
        findsOneWidget,
      );
      expect(find.byIcon(Icons.chevron_right), findsNWidgets(4));
      expect(find.text('Comunidades e moderação'), findsOneWidget);
      expect(find.text('Notificações e suporte'), findsOneWidget);
      expect(find.text('Falar com o suporte'), findsOneWidget);
      expect(find.text(HelpContent.emptyMessage), findsNothing);
    });

    test('rota Configurações → Ajuda', () {
      expect(Pages.profileHelp, '/me/settings/help');
    });
  });

  group('CF-198 help screen (red)', () {
    testWidgets('conteúdo vazio: empty sem acessos/FAQ', (tester) async {
      await tester.pumpWidget(
        const HelpTestApp(
          ProfileHelpScreen(
            quickAccessOverride: [],
            faqSectionsOverride: [],
          ),
        ),
      );
      await tester.pump();

      expect(find.text('Ajuda'), findsOneWidget);
      expect(find.text(HelpContent.emptyMessage), findsOneWidget);
      expect(find.text('Central de ajuda'), findsNothing);
      expect(find.byType(HelpQuickAccessRow), findsNothing);
      expect(find.byType(HelpFaqSection), findsNothing);
    });

    testWidgets('destino inválido não quebra a árvore', (tester) async {
      await tester.pumpWidget(
        const HelpTestApp(
          ProfileHelpScreen(
            quickAccessOverride: [
              (
                title: 'Destino inválido',
                subtitle: 'Não deve navegar.',
                destination: 'unknown',
              ),
            ],
            faqSectionsOverride: [],
          ),
        ),
      );
      await tester.pump();

      expect(find.text('Destino inválido'), findsOneWidget);
      await tester.tap(find.text('Destino inválido'));
      await tester.pump();
      expect(tester.takeException(), isNull);
    });
  });

  group('CF-198 help screen (edge)', () {
    testWidgets('fixtures off sem empty — conteúdo oficial permanece', (
      tester,
    ) async {
      expect(cf198HelpFixturesEnabled(), isFalse);
      await tester.pumpWidget(const HelpTestApp(ProfileHelpScreen()));
      await tester.pump();

      expect(find.text(HelpContent.emptyMessage), findsNothing);
      expect(find.text('Central de ajuda'), findsOneWidget);
      expect(find.byType(HelpQuickAccessRow), findsNWidgets(4));
    });

    testWidgets('texto longo da 1ª FAQ não estoura layout', (tester) async {
      final longAnswer = 'x' * 800;
      await tester.pumpWidget(
        HelpTestApp(
          ProfileHelpScreen(
            quickAccessOverride: HelpContent.quickAccess(),
            faqSectionsOverride: [
              (
                title: 'Conta e perfil',
                items: [('Pergunta edge muito longa ' * 4, longAnswer)],
              ),
            ],
          ),
        ),
      );
      await tester.pump();

      expect(tester.takeException(), isNull);
      expect(find.byType(HelpFaqSection), findsOneWidget);
      await tester.drag(find.byType(SingleChildScrollView), const Offset(0, -400));
      await tester.pump();
      expect(tester.takeException(), isNull);
    });

    testWidgets('subtítulo longo no acesso rápido', (tester) async {
      await tester.pumpWidget(
        const HelpTestApp(
          ProfileHelpScreen(
            quickAccessOverride: [
              (
                title: 'Segurança e Login',
                subtitle:
                    'Troca de senha, e-mail, telefone e dispositivos conectados. '
                    'Texto edge extra para validar quebra de linha sem scroll horizontal.',
                destination: 'profileSecurity',
              ),
            ],
            faqSectionsOverride: [],
          ),
        ),
      );
      await tester.pump();
      expect(tester.takeException(), isNull);
      expect(find.byType(HelpQuickAccessRow), findsOneWidget);
    });
  });
}
