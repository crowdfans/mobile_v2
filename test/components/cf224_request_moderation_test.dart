import 'package:crowdfans/api/api_error.dart';
import 'package:crowdfans/components/buttons/app_button.dart';
import 'package:crowdfans/constants/theme.dart';
import 'package:crowdfans/mocks/cf_temp_mocks.dart';
import 'package:crowdfans/models/profile.dart';
import 'package:crowdfans/screens/fan_clubs/fan_club_request_moderation_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// CF-273 — regressão FE de CF-224 (solicitar moderação).
/// Obrigatório Gustavo: green / red / edge.
void main() {
  Profile printCandidate() {
    return Profile(
      userUid: 'cf-mod-aline',
      displayName: cfTempMockModerationCandidate.displayName,
      name: 'alineduarte',
      description: '',
      photoUrl: cfTempMockModerationCandidate.photoUrl,
      isArtist: false,
    );
  }

  Future<void> pumpScreen(
    WidgetTester tester, {
    double keyboardInset = 0,
    Future<Profile> Function()? loadCandidate,
    bool usePrintCandidate = true,
  }) async {
    await tester.pumpWidget(
      MediaQuery(
        data: MediaQueryData(
          size: const Size(390, 844),
          viewInsets: EdgeInsets.only(bottom: keyboardInset),
        ),
        child: MaterialApp(
          theme: buildCrowdFansTheme(Brightness.light),
          home: FanClubRequestModerationScreen(
            artistId: 'mock-fc-enzo',
            artistName: 'Enzo Lima',
            loadCandidate: loadCandidate ??
                (usePrintCandidate ? () async => printCandidate() : null),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  group('CF-273 green', () {
    test('print helper Aline + limites 24/420 alinhados ao server', () {
      expect(cfTempMockModerationCandidate.displayName, 'Aline Duarte');
      expect(cfTempMockModerationCandidate.handle, 'fan/alineduarte');
      expect(cfTempMockModerationCandidate.photoUrl, isNotEmpty);
      expect(FanClubRequestModerationScreen.minReasonLength, 24);
      expect(FanClubRequestModerationScreen.maxReasonLength, 420);
    });

    testWidgets(
      'print: título, intro, candidato, helper, 0/420 e CTA desabilitado',
      (tester) async {
        await pumpScreen(tester);

        expect(find.text('Solicitar moderação'), findsOneWidget);
        expect(
          find.text(
            'Conte ao artista por que você quer ajudar na '
            'moderação e como pode contribuir com o fã-clube.',
          ),
          findsOneWidget,
        );
        expect(find.text('Aline Duarte'), findsOneWidget);
        expect(find.text('fan/alineduarte'), findsOneWidget);
        expect(
          find.text(
            'Explique por que você quer ser moderador(a) e como ajudaria esse fã-clube.',
          ),
          findsOneWidget,
        );
        expect(find.text('Mínimo de 24 caracteres.'), findsOneWidget);
        expect(find.text('0/420'), findsOneWidget);
        expect(find.text('Enviar solicitação'), findsOneWidget);

        final button = tester.widget<AppButton>(find.byType(AppButton));
        expect(button.disabled, isTrue);
        expect(button.label, 'Enviar solicitação');
      },
    );

    testWidgets('elegível: CTA habilita com ≥24 caracteres', (tester) async {
      await pumpScreen(tester);

      await tester.enterText(
        find.byType(TextFormField),
        'Quero ajudar a cuidar da comunidade com respeito.',
      );
      await tester.pump();

      final button = tester.widget<AppButton>(find.byType(AppButton));
      expect(button.disabled, isFalse);
      expect(find.textContaining('/420'), findsOneWidget);
    });
  });

  group('CF-273 red', () {
    testWidgets('vazio / curto: CTA permanece negado (sem submit)', (
      tester,
    ) async {
      await pumpScreen(tester);

      var button = tester.widget<AppButton>(find.byType(AppButton));
      expect(button.disabled, isTrue);

      await tester.enterText(find.byType(TextFormField), 'muito curto');
      await tester.pump();

      button = tester.widget<AppButton>(find.byType(AppButton));
      expect(button.disabled, isTrue);
      expect(find.text('Pedido enviado ao artista.'), findsNothing);
    });

    test('inelegível / duplicado / limite: erros mapeados sem sucesso', () {
      expect(
        mapFanClubModerationRequestError(
          ApiError('A pending request already exists', 409),
        ),
        'Você já tem um pedido de moderação pendente neste fã-clube.',
      );
      expect(
        mapFanClubModerationRequestError(
          ApiError('Only members or subscribers can request moderation', 400),
        ),
        'Só membros ou assinantes podem solicitar moderação.',
      );
      expect(
        mapFanClubModerationRequestError(
          ApiError('User is already a moderator', 400),
        ),
        'Você já é moderador(a) deste fã-clube.',
      );
      expect(
        mapFanClubModerationRequestError(
          ApiError('Reason must be between 24 and 420 characters', 400),
        ),
        'Explique em 24 a 420 caracteres.',
      );
      expect(
        mapFanClubModerationRequestError(
          ApiError('Requester is the club owner', 400),
        ),
        'O artista já é o dono do fã-clube.',
      );
    });

    testWidgets('23 caracteres: ainda bloqueado (limite mínimo)', (
      tester,
    ) async {
      await pumpScreen(tester);

      // Exatamente 23 runes — abaixo do mínimo do server.
      await tester.enterText(
        find.byType(TextFormField),
        '12345678901234567890123',
      );
      await tester.pump();

      final button = tester.widget<AppButton>(find.byType(AppButton));
      expect(button.disabled, isTrue);
      expect(find.text('23/420'), findsOneWidget);
    });
  });

  group('CF-273 edge', () {
    test('fixtures off: flags demock; amostra print permanece p/ testes', () {
      expect(kUseCfTempMocks, isTrue);
      expect(kUseCf224RequestModerationMocks, isFalse);
      expect(CfTempMocks.useFanClubFixtures, isFalse);
      expect(cfTempMockModerationCandidate.displayName, 'Aline Duarte');
    });

    testWidgets('contagem zero: 0/420 no estado inicial', (tester) async {
      await pumpScreen(tester);
      expect(find.text('0/420'), findsOneWidget);
      expect(find.text('Enviar solicitação'), findsOneWidget);
    });

    testWidgets('texto longo: 420 chars atualiza contador e CTA ok', (
      tester,
    ) async {
      await pumpScreen(tester);

      final long = 'a' * FanClubRequestModerationScreen.maxReasonLength;
      await tester.enterText(find.byType(TextFormField), long);
      await tester.pump();

      expect(find.text('420/420'), findsOneWidget);
      final button = tester.widget<AppButton>(find.byType(AppButton));
      expect(button.disabled, isFalse);
      expect(tester.takeException(), isNull);
    });

    testWidgets('teclado aberto: CTA permanece alcançável no scroll', (
      tester,
    ) async {
      await pumpScreen(tester, keyboardInset: 280);

      expect(find.text('Solicitar moderação'), findsOneWidget);

      await tester.scrollUntilVisible(
        find.text('Enviar solicitação'),
        60,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.pumpAndSettle();

      expect(find.text('Enviar solicitação'), findsOneWidget);
      expect(find.byType(AppButton), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('emoji/runes: ≥24 graphemes habilita CTA', (tester) async {
      await pumpScreen(tester);

      final emojis = '😀' * 24;
      await tester.enterText(find.byType(TextFormField), emojis);
      await tester.pump();

      expect(find.text('24/420'), findsOneWidget);
      final button = tester.widget<AppButton>(find.byType(AppButton));
      expect(button.disabled, isFalse);
    });

    testWidgets(
      'rede: falha ao carregar perfil — copy de erro, sem formulário/submit',
      (tester) async {
        await pumpScreen(
          tester,
          loadCandidate: () async {
            throw ApiError('Falha de rede ao falar com o servidor.', 0);
          },
        );

        expect(find.text(kFanClubRequestModerationLoadError), findsOneWidget);
        expect(find.text('Aline Duarte'), findsNothing);
        expect(find.text('Enviar solicitação'), findsNothing);
        expect(find.text('Pedido enviado ao artista.'), findsNothing);
        expect(find.byType(AppButton), findsNothing);
      },
    );

    test('rede no POST: Falha de rede não vira sucesso', () {
      expect(
        mapFanClubModerationRequestError(
          ApiError('Falha de rede ao falar com o servidor.', 0),
        ),
        'Falha de rede ao falar com o servidor.',
      );
    });
  });
}
