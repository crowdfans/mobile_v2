import 'package:crowdfans/components/artists/artist_profile_options_sheet.dart';
import 'package:crowdfans/components/post/post_sheet_list_item.dart';
import 'package:crowdfans/constants/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('CF-192: rótulo Denunciar igual ao print', () {
    expect(artistProfileReportLabel(), 'Denunciar');
  });

  testWidgets('CF-192: menu com Denunciar e Abrir fã clube + ícones', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: buildCrowdFansTheme(Brightness.light),
        home: Scaffold(
          body: ArtistProfileOptionsSheet(
            visible: true,
            artistId: 'artist-1',
            artistName: 'Gus Art',
            onClose: () {},
          ),
        ),
      ),
    );
    await tester.pump();

    expect(find.text('Denunciar'), findsOneWidget);
    expect(find.text('Abrir fã clube'), findsOneWidget);
    expect(find.textContaining('Denunciar perfil'), findsNothing);
    expect(find.text('Ações do perfil'), findsNothing);
    expect(find.byType(PostSheetListItem), findsNWidgets(2));
  });
}
