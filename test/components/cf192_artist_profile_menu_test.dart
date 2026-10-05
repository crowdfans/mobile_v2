import 'package:crowdfans/components/artists/artist_profile_options_sheet.dart';
import 'package:crowdfans/components/post/post_sheet_list_item.dart';
import 'package:crowdfans/constants/pages.dart';
import 'package:crowdfans/constants/theme.dart';
import 'package:crowdfans/screens/report/report_screen.dart';
import 'package:crowdfans/services/report_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

Future<void> _pumpSheet(
  WidgetTester tester, {
  required bool visible,
  String artistId = 'artist-1',
  String artistName = 'Gus Art',
  VoidCallback? onClose,
  VoidCallback? onOpenFanClub,
  GoRouter? router,
}) async {
  final sheet = ArtistProfileOptionsSheet(
    visible: visible,
    artistId: artistId,
    artistName: artistName,
    onClose: onClose ?? () {},
    onOpenFanClub: onOpenFanClub,
  );

  if (router != null) {
    await tester.pumpWidget(
      MaterialApp.router(
        theme: buildCrowdFansTheme(Brightness.light),
        routerConfig: router,
      ),
    );
  } else {
    await tester.pumpWidget(
      MaterialApp(
        theme: buildCrowdFansTheme(Brightness.light),
        home: Scaffold(body: sheet),
      ),
    );
  }
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 300));
}

/// Harness espelha o perfil: fecha o menu antes do push (evita Overlay sujo).
class _ArtistMenuHarness extends StatefulWidget {
  const _ArtistMenuHarness({
    required this.artistId,
    required this.artistName,
    this.onClosed,
  });

  final String artistId;
  final String artistName;
  final VoidCallback? onClosed;

  @override
  State<_ArtistMenuHarness> createState() => _ArtistMenuHarnessState();
}

class _ArtistMenuHarnessState extends State<_ArtistMenuHarness> {
  var _menuOpen = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          const Center(child: Text('perfil-fundo')),
          ArtistProfileOptionsSheet(
            visible: _menuOpen,
            artistId: widget.artistId,
            artistName: widget.artistName,
            onClose: () {
              setState(() => _menuOpen = false);
              widget.onClosed?.call();
            },
          ),
        ],
      ),
    );
  }
}

GoRouter _reportRouter({
  required String artistId,
  required String artistName,
  VoidCallback? onClosed,
}) {
  return GoRouter(
    initialLocation: '/artist',
    routes: [
      GoRoute(
        path: '/artist',
        builder: (context, state) => _ArtistMenuHarness(
          artistId: artistId,
          artistName: artistName,
          onClosed: onClosed,
        ),
      ),
      GoRoute(
        path: Pages.report,
        builder: (context, state) {
          final q = state.uri.queryParameters;
          return ReportScreen(
            contextKind: ReportService.parseContext(q['context']),
            targetId: q['targetId'],
            displayName: q['displayName'],
          );
        },
      ),
    ],
  );
}

void main() {
  group('CF-192 green', () {
    test('rótulos iguais ao print', () {
      expect(artistProfileReportLabel(), 'Denunciar');
      expect(artistProfileOpenFanClubLabel(), 'Abrir fã clube');
    });

    test('rota de denúncia carrega objeto do perfil', () {
      final route = artistProfileReportRoute(
        artistId: 'uid-gus',
        artistName: 'Gus Art',
      );
      final uri = Uri.parse(route);
      expect(uri.path, Pages.report);
      expect(uri.queryParameters['context'], 'artist-profile');
      expect(uri.queryParameters['targetId'], 'uid-gus');
      expect(uri.queryParameters['displayName'], 'Gus Art');
      expect(
        ReportService.parseContext(uri.queryParameters['context']),
        ReportContext.artistProfile,
      );
      expect(
        ReportService.getReportTitle(ReportContext.artistProfile),
        'Denunciar perfil de artista',
      );
      expect(
        ReportService.contextToTargetType(ReportContext.artistProfile),
        ReportTargetType.user,
      );
    });

    testWidgets('menu com Denunciar e Abrir fã clube + ícones', (tester) async {
      await _pumpSheet(tester, visible: true);

      expect(find.text('Denunciar'), findsOneWidget);
      expect(find.text('Abrir fã clube'), findsOneWidget);
      expect(find.textContaining('Denunciar perfil'), findsNothing);
      expect(find.text('Ações do perfil'), findsNothing);
      expect(find.byType(PostSheetListItem), findsNWidgets(2));
      expect(find.byType(SvgPicture), findsNWidgets(2));
      expect(find.byKey(const Key('artist-profile-menu-report')), findsOneWidget);
      expect(
        find.byKey(const Key('artist-profile-menu-fan-club')),
        findsOneWidget,
      );
    });

    testWidgets('Denunciar abre fluxo com nome do artista', (tester) async {
      var closed = false;
      final router = _reportRouter(
        artistId: 'uid-gus',
        artistName: 'Gus Art',
        onClosed: () => closed = true,
      );
      await tester.pumpWidget(
        MaterialApp.router(
          theme: buildCrowdFansTheme(Brightness.light),
          routerConfig: router,
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      await tester.tap(find.text('Denunciar'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      await tester.pumpAndSettle();

      expect(closed, isTrue);
      expect(router.state.uri.path, Pages.report);
      expect(router.state.uri.queryParameters['context'], 'artist-profile');
      expect(router.state.uri.queryParameters['targetId'], 'uid-gus');
      expect(router.state.uri.queryParameters['displayName'], 'Gus Art');
      expect(find.text('Denunciar perfil de artista'), findsOneWidget);
      expect(
        find.text('Por que você está denunciando Gus Art?'),
        findsOneWidget,
      );
    });

    testWidgets('Abrir fã clube chama callback do perfil', (tester) async {
      var closed = false;
      var opened = false;
      await _pumpSheet(
        tester,
        visible: true,
        onClose: () => closed = true,
        onOpenFanClub: () => opened = true,
      );

      await tester.tap(find.text('Abrir fã clube'));
      await tester.pump();

      expect(closed, isTrue);
      expect(opened, isTrue);
    });
  });

  group('CF-192 red', () {
    testWidgets('visível=false não mostra ações', (tester) async {
      await _pumpSheet(tester, visible: false);
      expect(find.text('Denunciar'), findsNothing);
      expect(find.text('Abrir fã clube'), findsNothing);
      expect(find.byType(PostSheetListItem), findsNothing);
    });

    testWidgets('rótulos longos/antigos do chrome não aparecem', (tester) async {
      await _pumpSheet(tester, visible: true);
      expect(find.text('Denunciar perfil de artista'), findsNothing);
      expect(find.text('Denunciar este perfil'), findsNothing);
      expect(find.text('Reportar'), findsNothing);
      expect(find.text('Ver Fã Clube'), findsNothing);
      expect(find.text('Ações do perfil'), findsNothing);
    });

    testWidgets('submit denúncia sem targetId mostra bloqueio', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: buildCrowdFansTheme(Brightness.light),
          home: const ReportScreen(
            contextKind: ReportContext.artistProfile,
            targetId: '',
            displayName: 'Gus Art',
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Spam'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Enviar denúncia'));
      await tester.pumpAndSettle();

      expect(find.text('Alvo da denúncia inválido.'), findsOneWidget);
      expect(find.textContaining('enviada'), findsNothing);
    });
  });

  group('CF-192 edge', () {
    test('nome vazio usa fallback artista na rota', () {
      final route = artistProfileReportRoute(
        artistId: 'uid-x',
        artistName: '   ',
      );
      expect(artistProfileReportDisplayName('   '), 'artista');
      expect(Uri.parse(route).queryParameters['displayName'], 'artista');
    });

    test('nome longo e especial é encodeado na query', () {
      const longName = 'Artista "Gus" & Amigos — #1 🎤';
      final route = artistProfileReportRoute(
        artistId: 'uid/with spaces',
        artistName: longName,
      );
      final uri = Uri.parse(route);
      expect(uri.queryParameters['displayName'], longName);
      expect(uri.queryParameters['targetId'], 'uid/with spaces');
      expect(route.contains(' '), isFalse);
    });

    testWidgets('texto ampliado não corta rótulos do print', (tester) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        MediaQuery(
          data: const MediaQueryData(textScaler: TextScaler.linear(1.6)),
          child: MaterialApp(
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
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.text('Denunciar'), findsOneWidget);
      expect(find.text('Abrir fã clube'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('onClose do sheet dispara sem side-effect de navegação', (
      tester,
    ) async {
      var closed = 0;
      await _pumpSheet(
        tester,
        visible: true,
        onClose: () => closed++,
      );
      final sheet = tester.widget<ArtistProfileOptionsSheet>(
        find.byType(ArtistProfileOptionsSheet),
      );
      sheet.onClose();
      expect(closed, 1);
      expect(find.text('Denunciar perfil de artista'), findsNothing);
    });
  });
}
