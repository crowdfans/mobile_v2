import 'package:crowdfans/content/help_content.dart';
import 'package:crowdfans/mocks/cf_temp_mocks.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('CF-198 help content (green)', () {
    test('demock: flags off + hero/intro/acessos oficiais', () {
      expect(CfTempMocks.useHelpFixtures, isFalse);
      expect(kUseCf198HelpMocks, isFalse);
      expect(kCf198MockEmpty, isFalse);
      expect(cf198HelpFixturesEnabled(), isFalse);

      expect(HelpContent.headerTitle, 'Ajuda');
      expect(HelpContent.heroTitle, 'Central de ajuda');
      expect(
        HelpContent.intro,
        contains('conta, memberships, artistas, moderação'),
      );
      expect(HelpContent.quickAccessSectionTitle, 'Acessos rápidos');
      // Sample de print espelha o conteúdo oficial.
      expect(Cf198HelpFixtures.heroTitle, HelpContent.heroTitle);
    });

    test('quatro acessos rápidos com destinos descritivos', () {
      final rows = HelpContent.quickAccess();
      expect(rows, hasLength(4));
      expect(rows.map((r) => r.title).toList(), [
        'Segurança e Login',
        'Meus Memberships',
        'Termos de Uso',
        'Política de Privacidade',
      ]);
      expect(rows.every((r) => r.subtitle.trim().isNotEmpty), isTrue);
      expect(rows.map((r) => r.destination).toSet(), hasLength(4));
      expect(rows[0].subtitle, contains('senha'));
      expect(rows[3].subtitle, contains('dados de cadastro'));
    });

    test('FAQ Conta e perfil já aberta (sem accordion)', () {
      final sections = HelpContent.faqSections();
      expect(sections, isNotEmpty);
      expect(sections.first.title, 'Conta e perfil');
      expect(sections.first.items, hasLength(3));
      expect(sections.first.items[0].$1, 'Como crio uma conta de fã?');
      expect(sections.first.items[0].$2, contains('validação por OTP'));
      expect(
        sections.first.items[1].$1,
        'Como funciona a entrada de artistas?',
      );
      expect(
        sections.first.items[1].$2,
        startsWith('Perfis de artistas podem existir antes da entrada oficial'),
      );
    });
  });

  group('CF-198 help content (red)', () {
    test('TEMP desligado — helper não liga fixtures', () {
      expect(kUseCfTempMocks, isTrue);
      expect(CfTempMocks.useHelpFixtures, isFalse);
      expect(kUseCf198HelpMocks, isFalse);
      expect(cf198HelpFixturesEnabled(), isFalse);
    });

    test('destinos inválidos não colidem com os quatro oficiais', () {
      final destinations =
          HelpContent.quickAccess().map((r) => r.destination).toSet();
      expect(destinations.contains(''), isFalse);
      expect(destinations.contains('unknown'), isFalse);
      expect(destinations.contains('profileSecurity'), isTrue);
    });

    test('perguntas sem resposta vazia / título em branco', () {
      for (final section in HelpContent.faqSections()) {
        expect(section.title.trim(), isNotEmpty);
        for (final item in section.items) {
          expect(item.$1.trim(), isNotEmpty);
          expect(item.$2.trim(), isNotEmpty);
        }
      }
    });
  });

  group('CF-198 help content (edge)', () {
    test('intro longo sem truncar contrato de leitura', () {
      expect(HelpContent.intro.length, greaterThan(80));
      expect(HelpContent.intro.contains('\n'), isFalse);
    });

    test('primeira resposta OTP é parágrafo longo (edge texto)', () {
      final answer = HelpContent.faqSections().first.items.first.$2;
      expect(answer.length, greaterThan(120));
      expect(answer, contains('Conexões sociais'));
    });

    test('mailto suporte está bem formado', () {
      final uri = Uri.parse(HelpContent.supportEmail);
      expect(uri.scheme, 'mailto');
      expect(uri.path, 'support@crowdfans.app');
    });
  });
}
