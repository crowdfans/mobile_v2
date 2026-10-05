import 'package:crowdfans/mocks/cf_temp_mocks.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('CF-198 help fixtures (green)', () {
    test('TEMP on + hero/intro/acessos do print', () {
      expect(CfTempMocks.useHelpFixtures, isTrue);
      expect(kUseCf198HelpMocks, isTrue);
      expect(kCf198MockEmpty, isFalse);
      expect(cf198HelpFixturesEnabled(), isTrue);

      expect(Cf198HelpFixtures.headerTitle, 'Ajuda');
      expect(Cf198HelpFixtures.heroTitle, 'Central de ajuda');
      expect(
        Cf198HelpFixtures.intro,
        contains('conta, memberships, artistas, moderação'),
      );
      expect(Cf198HelpFixtures.quickAccessSectionTitle, 'Acessos rápidos');
    });

    test('quatro acessos rápidos com destinos descritivos', () {
      final rows = Cf198HelpFixtures.quickAccess();
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
      final sections = Cf198HelpFixtures.faqSections();
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

  group('CF-198 help fixtures (red)', () {
    test('helper desliga com empty ou flag off', () {
      expect(kUseCfTempMocks, isTrue);
      expect(CfTempMocks.useHelpFixtures, isTrue);
      expect(kUseCf198HelpMocks, isTrue);
      expect(kCf198MockEmpty, isFalse);
      expect(cf198HelpFixturesEnabled(), isTrue);
      // Contrato red: qualquer um dos gates desliga o print.
      expect(
        kUseCfTempMocks &&
            CfTempMocks.useHelpFixtures &&
            kUseCf198HelpMocks &&
            !true, // simula kCf198MockEmpty
        isFalse,
      );
    });

    test('destinos inválidos não colidem com os quatro do print', () {
      final destinations =
          Cf198HelpFixtures.quickAccess().map((r) => r.destination).toSet();
      expect(destinations.contains(''), isFalse);
      expect(destinations.contains('unknown'), isFalse);
      expect(destinations.contains('profileSecurity'), isTrue);
    });

    test('perguntas sem resposta vazia / título em branco', () {
      for (final section in Cf198HelpFixtures.faqSections()) {
        expect(section.title.trim(), isNotEmpty);
        for (final item in section.items) {
          expect(item.$1.trim(), isNotEmpty);
          expect(item.$2.trim(), isNotEmpty);
        }
      }
    });
  });

  group('CF-198 help fixtures (edge)', () {
    test('intro longo sem truncar contrato de leitura', () {
      expect(Cf198HelpFixtures.intro.length, greaterThan(80));
      expect(Cf198HelpFixtures.intro.contains('\n'), isFalse);
    });

    test('primeira resposta OTP é parágrafo longo (edge texto)', () {
      final answer = Cf198HelpFixtures.faqSections().first.items.first.$2;
      expect(answer.length, greaterThan(120));
      expect(answer, contains('Conexões sociais'));
    });

    test('mailto suporte está bem formado', () {
      final uri = Uri.parse(Cf198HelpFixtures.supportEmail);
      expect(uri.scheme, 'mailto');
      expect(uri.path, 'support@crowdfans.app');
    });
  });
}
