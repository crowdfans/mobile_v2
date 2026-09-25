import 'package:crowdfans/components/search/search_artist_result_row.dart';
import 'package:crowdfans/components/search/search_artists_chrome.dart';
import 'package:crowdfans/constants/theme.dart';
import 'package:crowdfans/services/search_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('CF-240: linha com nome, handle, membros, #rank e menu', (
    tester,
  ) async {
    const artist = ArtistSearchItem(
      id: 'a1',
      name: 'Ludmilla',
      handle: 'ludmilla',
      avatarUri: '',
      memberCount: 512000,
      membersLabel: '512 mil membros',
      rank: 1,
    );

    await tester.pumpWidget(
      MaterialApp(
        theme: buildCrowdFansTheme(Brightness.light),
        home: Scaffold(
          body: SearchArtistResultRow(
            artist: artist,
            position: 1,
            onPressed: () {},
            onPressMore: () {},
          ),
        ),
      ),
    );
    await tester.pump();

    expect(find.text('Ludmilla'), findsOneWidget);
    expect(find.text('@ludmilla'), findsOneWidget);
    expect(find.text('512 mil membros'), findsOneWidget);
    expect(find.text('#1'), findsOneWidget);
    expect(find.byTooltip('Opções de Ludmilla'), findsOneWidget);

    final box = tester.getSize(find.byType(SearchArtistResultRow));
    expect(box.height, greaterThanOrEqualTo(72));
  });

  testWidgets('CF-240: chrome com voltar, lupa circular e campo pílula', (
    tester,
  ) async {
    final controller = TextEditingController();
    var back = 0;

    await tester.pumpWidget(
      MaterialApp(
        theme: buildCrowdFansTheme(Brightness.light),
        home: Scaffold(
          body: SearchArtistsChrome(
            controller: controller,
            onBack: () => back++,
            onChanged: (_) {},
            showClear: true,
            onClear: () {},
          ),
        ),
      ),
    );
    await tester.pump();

    expect(find.byTooltip('Voltar'), findsOneWidget);
    expect(find.byType(TextField), findsOneWidget);
    final field = tester.widget<TextField>(find.byType(TextField));
    expect(field.decoration?.hintText, '...');

    await tester.tap(find.byTooltip('Voltar'));
    await tester.pump();
    expect(back, 1);

    controller.dispose();
  });
}
