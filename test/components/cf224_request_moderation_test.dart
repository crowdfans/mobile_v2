import 'package:crowdfans/api/api_error.dart';
import 'package:crowdfans/components/buttons/app_button.dart';
import 'package:crowdfans/constants/theme.dart';
import 'package:crowdfans/mocks/cf_temp_mocks.dart';
import 'package:crowdfans/screens/fan_clubs/fan_club_request_moderation_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('CF-224 fixture: candidato Aline + avatar + limites 24/420', () {
    expect(kUseCfTempMocks, isTrue);
    expect(kUseCf224RequestModerationMocks, isTrue);
    expect(cfTempMockModerationCandidate.displayName, 'Aline Duarte');
    expect(cfTempMockModerationCandidate.handle, 'fan/alineduarte');
    expect(cfTempMockModerationCandidate.photoUrl, isNotEmpty);
    expect(FanClubRequestModerationScreen.minReasonLength, 24);
    expect(FanClubRequestModerationScreen.maxReasonLength, 420);
  });

  test('CF-224 erros de API viram mensagens compreensíveis', () {
    expect(
      mapFanClubModerationRequestError(
        ApiError('A pending request already exists', 409),
      ),
      'Você já tem um pedido de moderação pendente neste fã-clube.',
    );
    expect(
      mapFanClubModerationRequestError(
        ApiError('Reason must be between 24 and 420 characters', 400),
      ),
      'Explique em 24 a 420 caracteres.',
    );
    expect(
      mapFanClubModerationRequestError(
        ApiError('Only members or subscribers can request moderation', 400),
      ),
      'Só membros ou assinantes podem solicitar moderação.',
    );
  });

  testWidgets(
    'CF-224 tela: print Solicitar moderação (Aline, 0/420, CTA desabilitado)',
    (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: buildCrowdFansTheme(Brightness.light),
          home: const FanClubRequestModerationScreen(
            artistId: 'mock-fc-enzo',
            artistName: 'Enzo Lima',
          ),
        ),
      );
      await tester.pumpAndSettle();

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

  testWidgets('CF-224 CTA habilita com ≥24 caracteres (runes)', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: buildCrowdFansTheme(Brightness.light),
        home: const FanClubRequestModerationScreen(
          artistId: 'mock-fc-enzo',
          artistName: 'Enzo Lima',
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.enterText(
      find.byType(TextFormField),
      'Quero ajudar a cuidar da comunidade com respeito.',
    );
    await tester.pump();

    final button = tester.widget<AppButton>(find.byType(AppButton));
    expect(button.disabled, isFalse);
    expect(
      find.textContaining('/420'),
      findsOneWidget,
    );
  });
}
