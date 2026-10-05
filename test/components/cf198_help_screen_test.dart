import 'package:crowdfans/components/profile/help_faq_section.dart';
import 'package:crowdfans/components/profile/help_quick_access_row.dart';
import 'package:crowdfans/components/profile/profile_screen_header.dart';
import 'package:crowdfans/constants/pages.dart';
import 'package:crowdfans/constants/theme.dart';
import 'package:crowdfans/mocks/cf_temp_mocks.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Monta a hierarquia visual do print CF-198 sem GoRouter (widget isolado).
Widget _helpPrintTree({
  required List<Cf198QuickAccess> quickAccess,
  required List<Cf198FaqSection> faqSections,
  bool fixturesOn = true,
}) {
  return MaterialApp(
    theme: buildCrowdFansTheme(Brightness.light),
    home: Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            ProfileScreenHeader(
              title: Cf198HelpFixtures.headerTitle,
              onBack: () {},
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 40),
                children: [
                  if (!fixturesOn)
                    const Text('Nenhum conteúdo de ajuda disponível.')
                  else ...[
                    Text(
                      Cf198HelpFixtures.heroTitle,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(Cf198HelpFixtures.intro),
                    const SizedBox(height: 28),
                    Text(Cf198HelpFixtures.quickAccessSectionTitle),
                    const SizedBox(height: 8),
                    for (var i = 0; i < quickAccess.length; i++)
                      HelpQuickAccessRow(
                        title: quickAccess[i].title,
                        subtitle: quickAccess[i].subtitle,
                        onTap: () {},
                        showDivider: i < quickAccess.length - 1,
                      ),
                    const SizedBox(height: 28),
                    for (final section in faqSections)
                      HelpFaqSection(
                        title: section.title,
                        items: section.items,
                      ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

void main() {
  group('CF-198 help screen (green)', () {
    testWidgets('print: hero + 4 acessos + Conta e perfil expandido', (
      tester,
    ) async {
      expect(cf198HelpFixturesEnabled(), isTrue);
      await tester.pumpWidget(
        _helpPrintTree(
          quickAccess: Cf198HelpFixtures.quickAccess(),
          faqSections: Cf198HelpFixtures.faqSections(),
        ),
      );
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
      expect(
        find.textContaining('validação por OTP'),
        findsOneWidget,
      );
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
    });

    test('rota Configurações → Ajuda', () {
      expect(Pages.profileHelp, '/me/settings/help');
    });
  });

  group('CF-198 help screen (red)', () {
    testWidgets('fixtures off: empty sem acessos/FAQ', (tester) async {
      await tester.pumpWidget(
        _helpPrintTree(
          quickAccess: const [],
          faqSections: const [],
          fixturesOn: false,
        ),
      );
      await tester.pump();

      expect(find.text('Ajuda'), findsOneWidget);
      expect(find.text('Nenhum conteúdo de ajuda disponível.'), findsOneWidget);
      expect(find.text('Central de ajuda'), findsNothing);
      expect(find.byType(HelpQuickAccessRow), findsNothing);
      expect(find.byType(HelpFaqSection), findsNothing);
    });

    testWidgets('lista vazia: seção sem rows', (tester) async {
      await tester.pumpWidget(
        _helpPrintTree(quickAccess: const [], faqSections: const []),
      );
      await tester.pump();

      expect(find.text('Central de ajuda'), findsOneWidget);
      expect(find.byType(HelpQuickAccessRow), findsNothing);
      expect(find.text('Como crio uma conta de fã?'), findsNothing);
    });
  });

  group('CF-198 help screen (edge)', () {
    testWidgets('texto longo da 1ª FAQ não estoura layout', (tester) async {
      final longAnswer = 'x' * 800;
      await tester.pumpWidget(
        _helpPrintTree(
          quickAccess: Cf198HelpFixtures.quickAccess(),
          faqSections: [
            (
              title: 'Conta e perfil',
              items: [('Pergunta edge muito longa ' * 4, longAnswer)],
            ),
          ],
        ),
      );
      await tester.pump();

      expect(tester.takeException(), isNull);
      expect(find.byType(HelpFaqSection), findsOneWidget);
      // Scroll vertical permitido; sem overflow reportado.
      await tester.drag(find.byType(ListView), const Offset(0, -400));
      await tester.pump();
      expect(tester.takeException(), isNull);
    });

    testWidgets('subtítulo longo no acesso rápido', (tester) async {
      await tester.pumpWidget(
        _helpPrintTree(
          quickAccess: const [
            (
              title: 'Segurança e Login',
              subtitle:
                  'Troca de senha, e-mail, telefone e dispositivos conectados. '
                  'Texto edge extra para validar quebra de linha sem scroll horizontal.',
              destination: 'profileSecurity',
            ),
          ],
          faqSections: const [],
        ),
      );
      await tester.pump();
      expect(tester.takeException(), isNull);
      expect(find.byType(HelpQuickAccessRow), findsOneWidget);
    });
  });
}
