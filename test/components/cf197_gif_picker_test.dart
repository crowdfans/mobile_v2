import 'package:crowdfans/components/comments/comment_gif_picker.dart';
import 'package:crowdfans/constants/theme.dart';
import 'package:crowdfans/mocks/cf_temp_mocks.dart';
import 'package:crowdfans/services/comment_gif_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Widget _harness({
  required String query,
  required List<CommentGifItem> items,
  required bool loading,
  String? errorMessage,
  String? resultAnnouncement,
  ValueChanged<String>? onQueryChanged,
  VoidCallback? onClose,
  ValueChanged<CommentGifItem>? onSelect,
}) {
  return MaterialApp(
    theme: buildCrowdFansTheme(Brightness.light),
    home: CommentGifPicker(
      query: query,
      items: items,
      loading: loading,
      errorMessage: errorMessage,
      resultAnnouncement: resultAnnouncement,
      onQueryChanged: onQueryChanged ?? (_) {},
      onClose: onClose ?? () {},
      onSelect: onSelect ?? (_) {},
    ),
  );
}

void main() {
  group('CF-197 GIF picker — green', () {
    testWidgets('sheet Tenor + grid; selecionar devolve item sem fechar via close', (
      tester,
    ) async {
      CommentGifItem? selected;
      var closed = false;
      final items = Cf197GifFixtures.featured();

      await tester.pumpWidget(
        _harness(
          query: '',
          items: items,
          loading: false,
          resultAnnouncement: '${items.length} GIFs em destaque',
          onClose: () => closed = true,
          onSelect: (item) => selected = item,
        ),
      );
      await tester.pump();

      expect(find.text('Escolher GIF'), findsOneWidget);
      expect(find.text('Fonte: Tenor'), findsOneWidget);
      expect(find.byKey(const Key('comment-gif-search')), findsOneWidget);
      expect(find.byKey(const Key('comment-gif-search-icon')), findsOneWidget);
      expect(find.text('${items.length} GIFs em destaque'), findsOneWidget);
      expect(find.byKey(const Key('comment-gif-grid')), findsOneWidget);

      await tester.tap(find.byKey(const Key('comment-gif-result-0')));
      await tester.pump();

      expect(selected?.id, items.first.id);
      expect(closed, isFalse);
    });
  });

  group('CF-197 GIF picker — red', () {
    testWidgets('erro recuperável sem API key; busca preservada', (tester) async {
      await tester.pumpWidget(
        _harness(
          query: 'rock',
          items: const [],
          loading: false,
          errorMessage: CommentGifService.userErrorMessage,
        ),
      );
      await tester.pump();

      expect(find.text(CommentGifService.userErrorMessage), findsOneWidget);
      expect(find.textContaining('API key'), findsNothing);
      expect(find.textContaining('apikey'), findsNothing);
      expect(find.textContaining('LIVDSRZULELA'), findsNothing);
      expect(find.byKey(const Key('comment-gif-error')), findsOneWidget);

      final field = tester.widget<TextField>(
        find.descendant(
          of: find.byKey(const Key('comment-gif-search')),
          matching: find.byType(TextField),
        ),
      );
      expect(field.controller?.text, 'rock');
      // Vazio e erro são estados distintos — sem mensagem de “nenhum GIF”.
      expect(find.textContaining('Nenhum GIF'), findsNothing);
    });
  });

  group('CF-197 GIF picker — edge', () {
    testWidgets('vazio featured vs busca sem resultado; limpar query', (
      tester,
    ) async {
      var query = 'xyzzy';
      await tester.pumpWidget(
        _harness(
          query: query,
          items: const [],
          loading: false,
          onQueryChanged: (value) => query = value,
        ),
      );
      await tester.pump();

      expect(
        find.text('Nenhum GIF encontrado para “xyzzy”.'),
        findsOneWidget,
      );
      expect(find.byKey(const Key('comment-gif-empty')), findsOneWidget);
      expect(find.byKey(const Key('comment-gif-clear')), findsOneWidget);

      await tester.tap(find.byKey(const Key('comment-gif-clear')));
      await tester.pump();
      expect(query, '');

      await tester.pumpWidget(
        _harness(
          query: '',
          items: const [],
          loading: false,
        ),
      );
      await tester.pump();
      expect(
        find.text('Nenhum GIF em destaque no momento.'),
        findsOneWidget,
      );
      expect(find.byKey(const Key('comment-gif-clear')), findsNothing);
    });

    testWidgets('loading distinto de erro/vazio', (tester) async {
      await tester.pumpWidget(
        _harness(query: '', items: const [], loading: true),
      );
      await tester.pump();
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.byKey(const Key('comment-gif-error')), findsNothing);
      expect(find.byKey(const Key('comment-gif-empty')), findsNothing);
    });
  });
}
