import 'package:crowdfans/components/buttons/app_button.dart';
import 'package:crowdfans/components/fan_club/fan_club_defend_return_field.dart';
import 'package:crowdfans/components/fan_club/fan_club_defend_return_reason_card.dart';
import 'package:crowdfans/constants/theme.dart';
import 'package:crowdfans/mocks/cf_temp_mocks.dart';
import 'package:crowdfans/screens/fan_clubs/fan_club_defend_return_screen.dart';
import 'package:crowdfans/services/fan_club_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('CF-200 GREEN — print / sucesso', () {
    testWidgets(
      'motivo separado do campo; Enviar desabilitado; copy do print',
      (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            theme: buildCrowdFansTheme(Brightness.light),
            home: const FanClubDefendReturnScreen(
              artistId: cfTempMockFelipeArtistUid,
              artistName: 'Felipe Rhy',
              expulsionReason: cfTempMockExpulsionReason,
            ),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.text('Defender retorno'), findsOneWidget);
        expect(
          find.text(
            'Explique para a moderação por que você acredita que deve voltar '
            'para a comunidade e o que mudou desde a expulsão.',
          ),
          findsOneWidget,
        );
        expect(find.text('Motivo da expulsão'), findsOneWidget);
        expect(find.text(cfTempMockExpulsionReason), findsOneWidget);
        expect(find.text('Sua defesa'), findsNothing);
        expect(
          find.text(
            'Conte o contexto, reconheça o problema e explique por que pode '
            'voltar sem repetir isso.',
          ),
          findsOneWidget,
        );
        expect(find.text('Mínimo de 24 caracteres.'), findsOneWidget);
        expect(find.text('0/420'), findsOneWidget);

        final button = tester.widget<AppButton>(find.byType(AppButton));
        expect(button.disabled, isTrue);
        expect(button.label, 'Enviar defesa');
        expect(button.variant, AppButtonVariant.dark);
      },
    );

    testWidgets('CTA habilita com ≥24 caracteres (runes)', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: buildCrowdFansTheme(Brightness.light),
          home: const FanClubDefendReturnScreen(
            artistId: cfTempMockFelipeArtistUid,
            expulsionReason: cfTempMockExpulsionReason,
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.enterText(
        find.byType(TextField),
        'a' * FanClubDefendReturnField.minChars,
      );
      await tester.pump();

      expect(find.text('24/420'), findsOneWidget);
      expect(
        tester.widget<AppButton>(find.byType(AppButton)).disabled,
        isFalse,
      );
    });

    test('fixture TEMP CF-200 + limites alinhados ao servidor', () {
      expect(kUseCfTempMocks, isTrue);
      expect(kUseCf200DefendReturnFixtures, isTrue);
      expect(cf200DefendReturnFixturesEnabled(), isTrue);
      expect(cfTempMockExpulsionReason, contains('ataques recorrentes'));
      expect(FanClubDefendReturnField.minChars, 24);
      expect(FanClubDefendReturnField.maxChars, 420);
    });

    test('createFanClubAppeal TEMP retorna pending com defesa válida', () async {
      final appeal = await FanClubService.createFanClubAppeal(
        cfTempMockFelipeArtistUid,
        'Reconheço o erro e quero voltar com respeito.',
      );
      expect(appeal.status, 'pending');
      expect(appeal.defense, contains('respeito'));
      expect(appeal.appealId, 'cf200-appeal-temp');
    });
  });

  group('CF-200 RED — inválido / bloqueado / vazio', () {
    testWidgets('CTA permanece desabilitado com 23 caracteres', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: buildCrowdFansTheme(Brightness.light),
          home: const FanClubDefendReturnScreen(
            artistId: 'artist-x',
            expulsionReason: cfTempMockExpulsionReason,
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.enterText(
        find.byType(TextField),
        'a' * (FanClubDefendReturnField.minChars - 1),
      );
      await tester.pump();

      expect(find.text('23/420'), findsOneWidget);
      expect(
        tester.widget<AppButton>(find.byType(AppButton)).disabled,
        isTrue,
      );
    });

    testWidgets('erro associado ao campo quando submit inválido', (
      tester,
    ) async {
      final controller = TextEditingController(text: 'curto');
      await tester.pumpWidget(
        MaterialApp(
          theme: buildCrowdFansTheme(Brightness.light),
          home: Scaffold(
            body: FanClubDefendReturnField(
              controller: controller,
              errorText: 'Explique em 24 a 420 caracteres.',
              onChanged: (_) {},
            ),
          ),
        ),
      );
      await tester.pump();

      expect(find.text('Explique em 24 a 420 caracteres.'), findsOneWidget);
      final field = tester.widget<TextField>(find.byType(TextField));
      expect(field.decoration?.errorText, 'Explique em 24 a 420 caracteres.');
    });

    testWidgets('motivo vazio usa fallback sem esconder o card', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: buildCrowdFansTheme(Brightness.light),
          home: const Scaffold(
            body: FanClubDefendReturnReasonCard(reason: '   '),
          ),
        ),
      );
      await tester.pump();

      expect(find.text('Motivo da expulsão'), findsOneWidget);
      expect(
        find.text('A moderação removeu seu acesso a esta comunidade.'),
        findsOneWidget,
      );
    });

    test('createFanClubAppeal TEMP rejeita defesa curta', () async {
      expect(
        () => FanClubService.createFanClubAppeal(
          cfTempMockFelipeArtistUid,
          'curto demais',
        ),
        throwsA(
          isA<Object>().having(
            (e) => e.toString(),
            'message',
            contains('24 a 420'),
          ),
        ),
      );
    });
  });

  group('CF-200 EDGE — teclado / longo / runes / contador', () {
    testWidgets('máximo 420 — contador e sem double counter Flutter', (
      tester,
    ) async {
      final controller = TextEditingController();
      await tester.pumpWidget(
        MaterialApp(
          theme: buildCrowdFansTheme(Brightness.light),
          home: StatefulBuilder(
            builder: (context, setState) {
              return Scaffold(
                body: FanClubDefendReturnField(
                  controller: controller,
                  onChanged: (_) => setState(() {}),
                ),
              );
            },
          ),
        ),
      );
      await tester.pump();

      await tester.enterText(
        find.byType(TextField),
        'á' * FanClubDefendReturnField.maxChars,
      );
      await tester.pump();

      expect(find.text('420/420'), findsOneWidget);
      // Flutter default counter text "420/420" would appear twice if not hidden.
      expect(find.textContaining('/420'), findsOneWidget);
    });

    testWidgets('runes Unicode contam como 1 caractere no mínimo', (
      tester,
    ) async {
      final controller = TextEditingController();
      var canSubmit = false;
      await tester.pumpWidget(
        MaterialApp(
          theme: buildCrowdFansTheme(Brightness.light),
          home: StatefulBuilder(
            builder: (context, setState) {
              canSubmit = controller.text.trim().characters.length >=
                  FanClubDefendReturnField.minChars;
              return Scaffold(
                body: Column(
                  children: [
                    FanClubDefendReturnField(
                      controller: controller,
                      onChanged: (_) => setState(() {}),
                    ),
                    AppButton(
                      label: 'Enviar defesa',
                      variant: AppButtonVariant.dark,
                      disabled: !canSubmit,
                      onPressed: () {},
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      );
      await tester.pump();

      await tester.enterText(
        find.byType(TextField),
        'á' * FanClubDefendReturnField.minChars,
      );
      await tester.pump();

      expect(find.text('24/420'), findsOneWidget);
      expect(
        tester.widget<AppButton>(find.byType(AppButton)).disabled,
        isFalse,
      );
    });

    testWidgets('motivo longo não quebra o card rosado', (tester) async {
      final long = 'Motivo muito longo. ' * 20;
      await tester.pumpWidget(
        MaterialApp(
          theme: buildCrowdFansTheme(Brightness.light),
          home: Scaffold(
            body: FanClubDefendReturnReasonCard(reason: long),
          ),
        ),
      );
      await tester.pump();

      expect(find.text('Motivo da expulsão'), findsOneWidget);
      expect(find.textContaining('Motivo muito longo'), findsOneWidget);
      final decorated = tester.widget<DecoratedBox>(
        find
            .descendant(
              of: find.byType(FanClubDefendReturnReasonCard),
              matching: find.byType(DecoratedBox),
            )
            .first,
      );
      final box = decorated.decoration as BoxDecoration;
      expect(box.color, AppPalette.red100);
    });

    testWidgets('viewInsets (teclado) não remove o CTA', (tester) async {
      await tester.pumpWidget(
        MediaQuery(
          data: const MediaQueryData(viewInsets: EdgeInsets.only(bottom: 300)),
          child: MaterialApp(
            theme: buildCrowdFansTheme(Brightness.light),
            home: const FanClubDefendReturnScreen(
              artistId: cfTempMockFelipeArtistUid,
              expulsionReason: cfTempMockExpulsionReason,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Enviar defesa'), findsOneWidget);
      expect(find.byType(AppButton), findsOneWidget);
    });

    test('CF-229/230 flags intactas (não regressão)', () {
      expect(kUseCf229ExpelledFixtures, isTrue);
      expect(kUseCf230WarningFixtures, isTrue);
      expect(cfTempMockStrikeReason, isNot(equals(cfTempMockExpulsionReason)));
    });
  });
}
