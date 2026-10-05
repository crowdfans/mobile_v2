import 'package:crowdfans/components/fan_clubs/fan_club_search_result_row.dart';
import 'package:crowdfans/components/fan_clubs/fan_clubs_search_chrome.dart';
import 'package:crowdfans/components/search/search_query_field.dart';
import 'package:crowdfans/constants/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('CF-173: chrome com voltar, lupa circular e campo abaixo', (
    tester,
  ) async {
    final controller = TextEditingController();
    final focusNode = FocusNode();
    var back = 0;

    await tester.pumpWidget(
      MaterialApp(
        theme: buildCrowdFansTheme(Brightness.light),
        home: Scaffold(
          body: FanClubsSearchChrome(
            controller: controller,
            focusNode: focusNode,
            onBack: () => back++,
            onChanged: (_) {},
          ),
        ),
      ),
    );
    await tester.pump();

    expect(find.byKey(const Key('fan-clubs-search-back')), findsOneWidget);
    expect(find.byKey(const Key('fan-clubs-search-lupa')), findsOneWidget);
    expect(find.byKey(const Key('fan-clubs-search-field')), findsOneWidget);
    expect(find.byType(TextField), findsOneWidget);

    final field = tester.widget<SearchQueryField>(
      find.byType(SearchQueryField),
    );
    expect(field.hint, 'Buscar fã clube');
    expect(field.pill, isTrue);
    expect(field.autofocus, isTrue);

    // Campo fica abaixo do cabeçalho (não na mesma linha do Voltar).
    final backTop = tester.getTopLeft(find.byKey(const Key('fan-clubs-search-back'))).dy;
    final fieldTop = tester.getTopLeft(find.byType(TextField)).dy;
    expect(fieldTop, greaterThan(backTop + 24));

    await tester.tap(find.byKey(const Key('fan-clubs-search-lupa')));
    await tester.pump();
    expect(focusNode.hasFocus, isTrue);

    await tester.tap(find.byTooltip('Voltar'));
    await tester.pump();
    expect(back, 1);

    controller.dispose();
    focusNode.dispose();
  });

  testWidgets('CF-173: linhas compactas sem card/borda', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: buildCrowdFansTheme(Brightness.light),
        home: Scaffold(
          body: ListView.separated(
            itemCount: 2,
            separatorBuilder: (_, _) => const Divider(height: 1),
            itemBuilder: (context, index) {
              return FanClubSearchResultRow(
                name: index == 0 ? 'Mayra' : 'Marinhos',
                avatarUrl: '',
                onPressed: () {},
              );
            },
          ),
        ),
      ),
    );
    await tester.pump();

    expect(find.text('Mayra'), findsOneWidget);
    expect(find.text('Marinhos'), findsOneWidget);
    expect(find.byType(Card), findsNothing);

    // Sem Material com borda arredondada em torno da linha.
    final borderedMaterials = tester
        .widgetList<Material>(find.byType(Material))
        .where((material) {
          final shape = material.shape;
          return shape is RoundedRectangleBorder &&
              shape.side != BorderSide.none;
        });
    expect(borderedMaterials, isEmpty);

    final first = tester.getSize(find.byType(FanClubSearchResultRow).first);
    expect(first.height, lessThan(80));
    expect(first.height, greaterThanOrEqualTo(56));
  });

  testWidgets('CF-173: termo pesquisado permanece no controller', (
    tester,
  ) async {
    final controller = TextEditingController();
    final focusNode = FocusNode();

    await tester.pumpWidget(
      MaterialApp(
        theme: buildCrowdFansTheme(Brightness.light),
        home: Scaffold(
          body: FanClubsSearchChrome(
            controller: controller,
            focusNode: focusNode,
            onBack: () {},
            onChanged: (_) {},
          ),
        ),
      ),
    );
    await tester.pump();

    await tester.enterText(find.byType(TextField), 'May');
    await tester.pump();
    expect(controller.text, 'May');

    // Rebuild do chrome não apaga o termo.
    await tester.pumpWidget(
      MaterialApp(
        theme: buildCrowdFansTheme(Brightness.light),
        home: Scaffold(
          body: FanClubsSearchChrome(
            controller: controller,
            focusNode: focusNode,
            onBack: () {},
            onChanged: (_) {},
          ),
        ),
      ),
    );
    await tester.pump();
    expect(controller.text, 'May');
    expect(find.text('May'), findsOneWidget);

    controller.dispose();
    focusNode.dispose();
  });
}
