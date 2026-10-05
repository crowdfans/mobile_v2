import 'package:crowdfans/components/fan_club/fan_club_compose_artist.dart';
import 'package:crowdfans/components/fan_club/fan_club_selector_field.dart';
import 'package:crowdfans/components/post/novo_post_header.dart';
import 'package:crowdfans/components/post/novo_post_secret_banner.dart';
import 'package:crowdfans/constants/theme.dart';
import 'package:crowdfans/models/feed_post.dart';
import 'package:crowdfans/services/post_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_test/flutter_test.dart';

Finder _pillDecoration() {
  return find.descendant(
    of: find.byKey(const Key('novo-post-secret-banner')),
    matching: find.byWidgetPredicate(
      (w) =>
          w is DecoratedBox &&
          (w.decoration as BoxDecoration).borderRadius ==
              BorderRadius.circular(999),
    ),
  );
}

Future<void> _pumpBanner(WidgetTester tester, {double width = 400}) async {
  await tester.pumpWidget(
    MaterialApp(
      theme: buildCrowdFansTheme(Brightness.light),
      home: Scaffold(
        body: SizedBox(
          width: width,
          child: const NovoPostSecretBanner(),
        ),
      ),
    ),
  );
  await tester.pump();
}

/// Harness: header + indicador + seletor — espelha o bloco do print CF-177.
class _Cf177ComposeHarness extends StatefulWidget {
  const _Cf177ComposeHarness({this.initialSecret = false});

  final bool initialSecret;

  @override
  State<_Cf177ComposeHarness> createState() => _Cf177ComposeHarnessState();
}

class _Cf177ComposeHarnessState extends State<_Cf177ComposeHarness> {
  late var _secret = widget.initialSecret;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          NovoPostHeader(
            subtitle: 'Fã Clube',
            canSubmit: false,
            publishing: false,
            onCancel: () {},
            onPublish: () {},
            showSecretToggle: true,
            isSecretMode: _secret,
            onToggleSecret: () => setState(() => _secret = !_secret),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
              children: [
                if (_secret) ...[
                  const NovoPostSecretBanner(),
                  const SizedBox(height: 12),
                ],
                FanClubSelectorField(
                  selected: const FanClubComposeArtist(
                    id: 'mayra',
                    name: 'Mayra',
                    avatarUrl: '',
                  ),
                  expanded: false,
                  onPressed: () {},
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

void main() {
  group('CF-177 green — indicador compacto (print)', () {
    testWidgets('pílula com ícone + texto, sem faixa full-width', (
      tester,
    ) async {
      await _pumpBanner(tester);

      expect(find.byKey(const Key('novo-post-secret-banner')), findsOneWidget);
      expect(find.text('Modo secreto ativo'), findsOneWidget);
      expect(find.byType(SvgPicture), findsOneWidget);

      final pill = _pillDecoration();
      expect(pill, findsOneWidget);
      expect(tester.getSize(pill).width, lessThan(280));
      expect(tester.getSize(pill).width, greaterThan(120));

      final box = tester.widget<DecoratedBox>(pill);
      final deco = box.decoration as BoxDecoration;
      expect(deco.color, AppPalette.blue50);
      expect(deco.border, isNull);
      expect(deco.borderRadius, BorderRadius.circular(999));

      final label = tester.widget<Text>(find.text('Modo secreto ativo'));
      expect(label.style?.color, AppPalette.blue700);
      expect(label.style?.fontWeight, FontWeight.w600);
    });

    testWidgets('acima do seletor com respiro de 12px (print)', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: buildCrowdFansTheme(Brightness.light),
          home: const _Cf177ComposeHarness(initialSecret: true),
        ),
      );
      await tester.pump();

      expect(find.text('Modo secreto ativo'), findsOneWidget);
      expect(find.text('Mayra'), findsOneWidget);

      final bannerBottom =
          tester.getBottomLeft(find.byKey(const Key('novo-post-secret-banner'))).dy;
      final selectorTop =
          tester.getTopLeft(find.byKey(const Key('novo-post-club-selector'))).dy;
      expect(selectorTop - bannerBottom, closeTo(12, 0.5));
    });

    test('PostWriteRequest envia isSecret=true à API real', () {
      final json = const PostWriteRequest(
        type: PostType.text,
        text: 'olá',
        targetArtistId: 'artist-1',
        isSecret: true,
      ).toJson();
      expect(json['isSecret'], isTrue);
      expect(json['targetArtistId'], 'artist-1');
    });
  });

  group('CF-177 red — sem faixa antiga / secreto off', () {
    testWidgets('sem contorno full-width (app antigo)', (tester) async {
      await _pumpBanner(tester);

      final pill = tester.widget<DecoratedBox>(_pillDecoration());
      final deco = pill.decoration as BoxDecoration;
      expect(deco.border, isNull);

      // A pílula não ocupa a largura do parent (400).
      expect(tester.getSize(_pillDecoration()).width, lessThan(300));
      expect(tester.getSize(_pillDecoration()).width, isNot(400));
    });

    testWidgets('modo secreto off: indicador ausente', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: buildCrowdFansTheme(Brightness.light),
          home: const _Cf177ComposeHarness(initialSecret: false),
        ),
      );
      await tester.pump();

      expect(find.text('Modo secreto ativo'), findsNothing);
      expect(find.byKey(const Key('novo-post-secret-banner')), findsNothing);
      expect(find.byKey(const Key('novo-post-secret-toggle')), findsOneWidget);
      expect(find.text('Mayra'), findsOneWidget);
    });

    testWidgets('não toca seletor de publicação CF-188 nem tipos CF-141', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: buildCrowdFansTheme(Brightness.light),
          home: const _Cf177ComposeHarness(initialSecret: true),
        ),
      );
      await tester.pump();

      expect(find.text('Fan Letter'), findsNothing);
      expect(find.text('Post Fã Clube'), findsNothing);
      expect(find.text('Seletor de publicação'), findsNothing);
      expect(find.text('Texto'), findsNothing);
      expect(find.text('Imagem'), findsNothing);
    });

    test('PostWriteRequest isSecret=false por padrão', () {
      final json = const PostWriteRequest(
        type: PostType.text,
        text: 'x',
      ).toJson();
      expect(json['isSecret'], isFalse);
    });
  });

  group('CF-177 edge — toggle, largura larga, texto', () {
    testWidgets('toggle revela e esconde o indicador', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: buildCrowdFansTheme(Brightness.light),
          home: const _Cf177ComposeHarness(initialSecret: false),
        ),
      );
      await tester.pump();

      expect(find.text('Modo secreto ativo'), findsNothing);

      await tester.tap(find.byKey(const Key('novo-post-secret-toggle')));
      await tester.pump();
      expect(find.text('Modo secreto ativo'), findsOneWidget);
      expect(tester.getSize(_pillDecoration()).width, lessThan(280));

      await tester.tap(find.byKey(const Key('novo-post-secret-toggle')));
      await tester.pump();
      expect(find.text('Modo secreto ativo'), findsNothing);
    });

    testWidgets('parent largo (800) ainda compacto à esquerda', (tester) async {
      await _pumpBanner(tester, width: 800);

      final pillSize = tester.getSize(_pillDecoration());
      expect(pillSize.width, lessThan(280));

      final pillLeft = tester.getTopLeft(_pillDecoration()).dx;
      final bannerLeft =
          tester.getTopLeft(find.byKey(const Key('novo-post-secret-banner'))).dx;
      expect(pillLeft, closeTo(bannerLeft, 1));
    });

    testWidgets('rótulo exato do print (sem variação)', (tester) async {
      await _pumpBanner(tester);
      expect(find.text('Modo secreto ativo'), findsOneWidget);
      expect(find.textContaining('secreto'), findsOneWidget);
      expect(find.text('Modo secreto'), findsNothing);
      expect(find.text('Secret mode'), findsNothing);
    });
  });
}
