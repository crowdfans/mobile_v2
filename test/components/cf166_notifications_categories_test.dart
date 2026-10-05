import 'package:crowdfans/components/profile/notification_category_nav_row.dart';
import 'package:crowdfans/components/profile/notification_preference_section.dart';
import 'package:crowdfans/constants/theme.dart';
import 'package:crowdfans/services/notification_preferences_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('CF-166: hub com gerais e categorias detalhadas', (tester) async {
    final general = notificationPreferenceGroups.firstWhere(
      (group) => group.id == 'general',
    );
    final preferences = Map<String, bool>.from(notificationPreferenceDefaults);

    await tester.pumpWidget(
      MaterialApp(
        theme: buildCrowdFansTheme(Brightness.light),
        home: Scaffold(
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                NotificationPreferenceSection(
                  group: general,
                  preferences: preferences,
                  saving: false,
                  onChanged: (_, __) {},
                ),
                const Text('Categorias detalhadas'),
                const Text(
                  'Organizamos os controles em páginas separadas para você ajustar melhor o que quer receber e de quais artistas.',
                ),
                for (final group in notificationCategoryGroups)
                  NotificationCategoryNavRow(
                    title: group.title,
                    subtitle: group.navSubtitle!,
                    onTap: () {},
                  ),
              ],
            ),
          ),
        ),
      ),
    );
    await tester.pump();

    // Preferências Gerais (print LEFT).
    expect(find.text('Preferências Gerais'), findsOneWidget);
    expect(find.text('Notificações push'), findsOneWidget);
    expect(find.text('Receber alertas no celular.'), findsOneWidget);
    expect(find.text('Notificações por e-mail'), findsOneWidget);
    expect(
      find.text('Receber resumos e alertas no e-mail.'),
      findsOneWidget,
    );
    expect(find.text('Modo silencioso'), findsOneWidget);
    expect(
      find.text('Pausa alertas comuns e mantém apenas os críticos.'),
      findsOneWidget,
    );

    // Categorias detalhadas + 4 acessos (print LEFT).
    expect(find.text('Categorias detalhadas'), findsOneWidget);
    expect(
      find.text(
        'Organizamos os controles em páginas separadas para você ajustar melhor o que quer receber e de quais artistas.',
      ),
      findsOneWidget,
    );
    expect(find.text('Interações com você'), findsOneWidget);
    expect(find.text('Interações com Você'), findsNothing);
    expect(find.text('Artistas, Cartas e Fã Clubes'), findsOneWidget);
    expect(find.text('Meet & Greet'), findsOneWidget);
    expect(find.text('Membership e Jam Coins'), findsOneWidget);
    expect(find.byType(NotificationCategoryNavRow), findsNWidgets(4));
    expect(
      find.text(
        'Curtidas do artista nas suas coisas, respostas, menções ao seu fan/ e novos seguidores.',
      ),
      findsOneWidget,
    );
    expect(
      find.text(
        'Posts, cartas, destaques do artista, conteúdo exclusivo e controle por artista.',
      ),
      findsOneWidget,
    );
    expect(
      find.text(
        'Convites, lembretes de fila, início da chamada e encerramento.',
      ),
      findsOneWidget,
    );
    expect(
      find.text(
        'Renovação, saldo insuficiente, recargas, promoções e pagamentos.',
      ),
      findsOneWidget,
    );

    // Controles de interações não ficam no hub.
    expect(find.text('Curtidas em comentários'), findsNothing);
    expect(find.text('Artista curtiu seu comentário'), findsNothing);
    expect(find.text('Novos seguidores'), findsNothing);

    // Print: sem contorno externo nos grupos (só linhas entre itens).
    final borderedCards = find.byWidgetPredicate(
      (widget) =>
          widget is DecoratedBox &&
          widget.decoration is BoxDecoration &&
          (widget.decoration as BoxDecoration).borderRadius != null &&
          (widget.decoration as BoxDecoration).border != null,
    );
    expect(borderedCards, findsNothing);

    // Títulos das categorias: bold como no print.
    final titleText = tester.widget<Text>(find.text('Interações com você'));
    expect(titleText.style?.fontWeight, FontWeight.w700);
  });

  test('CF-166: catálogo do hub — gerais + 4 navSubtitle', () {
    final general = notificationGroupById('general')!;
    expect(general.title, 'Preferências Gerais');
    expect(general.items.map((item) => item.title).toList(), [
      'Notificações push',
      'Notificações por e-mail',
      'Modo silencioso',
    ]);

    expect(notificationCategoryGroups.map((g) => g.id).toList(), [
      'interactions',
      'artists',
      'meet',
      'wallet',
    ]);
    expect(notificationCategoryGroups.map((g) => g.title).toList(), [
      'Interações com você',
      'Artistas, Cartas e Fã Clubes',
      'Meet & Greet',
      'Membership e Jam Coins',
    ]);
    expect(notificationCategoryGroups.map((g) => g.navSubtitle).toList(), [
      'Curtidas do artista nas suas coisas, respostas, menções ao seu fan/ e novos seguidores.',
      'Posts, cartas, destaques do artista, conteúdo exclusivo e controle por artista.',
      'Convites, lembretes de fila, início da chamada e encerramento.',
      'Renovação, saldo insuficiente, recargas, promoções e pagamentos.',
    ]);
  });
}
