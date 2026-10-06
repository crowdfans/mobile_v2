import 'package:crowdfans/components/artists/artist_profile_options_sheet.dart';
import 'package:crowdfans/components/post/post_sheet_list_item.dart';
import 'package:crowdfans/components/ui/bottom_sheet_shell.dart';
import 'package:crowdfans/constants/pages.dart';
import 'package:crowdfans/constants/theme.dart';
import 'package:crowdfans/screens/report/report_screen.dart';
import 'package:crowdfans/services/report_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

Finder _svgAsset(String assetName) {
  return find.byWidgetPredicate(
    (widget) =>
        widget is SvgPicture &&
        widget.bytesLoader is SvgAssetLoader &&
        (widget.bytesLoader as SvgAssetLoader).assetName == assetName,
  );
}

/// Fecha o sheet no [onClose] antes da navegação (evita overlay stale).
class _Cf192MenuHarness extends StatefulWidget {
  const _Cf192MenuHarness({required this.artistId, required this.artistName});

  final String artistId;
  final String artistName;

  @override
  State<_Cf192MenuHarness> createState() => _Cf192MenuHarnessState();
}

class _Cf192MenuHarnessState extends State<_Cf192MenuHarness> {
  var _open = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ArtistProfileOptionsSheet(
        visible: _open,
        artistId: widget.artistId,
        artistName: widget.artistName,
        onClose: () => setState(() => _open = false),
      ),
    );
  }
}

void main() {
  group('CF-192 green — sucesso / print', () {
    test('rótulos e rota com objeto da denúncia', () {
      expect(artistProfileReportLabel(), 'Denunciar');
      expect(artistProfileOpenFanClubLabel(), 'Abrir fã clube');
      final route = artistProfileReportRoute(
        artistId: 'artist-1',
        artistName: 'Gus Art',
      );
      expect(route, contains('context=artist-profile'));
      expect(route, contains('targetId=artist-1'));
      expect(Uri.parse(route).queryParameters['displayName'], 'Gus Art');
      expect(
        ReportService.parseContext('artist-profile'),
        ReportContext.artistProfile,
      );
      expect(
        ReportService.getReportTitle(ReportContext.artistProfile),
        'Denunciar perfil de artista',
      );
    });

    testWidgets('menu Instagram: Denunciar + Abrir fã clube + ícones + lilás', (
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
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.text('Denunciar'), findsOneWidget);
      expect(find.text('Abrir fã clube'), findsOneWidget);
      expect(find.textContaining('Denunciar perfil'), findsNothing);
      expect(find.text('Ações do perfil'), findsNothing);
      expect(find.byType(PostSheetListItem), findsNWidgets(2));
      expect(_svgAsset(kArtistProfileReportIconAsset), findsOneWidget);
      expect(_svgAsset(kArtistProfileFanClubIconAsset), findsOneWidget);

      final shell = tester.widget<BottomSheetShell>(
        find.byType(BottomSheetShell),
      );
      expect(shell.panelColor, AppPalette.purple50);
    });

    testWidgets('Denunciar navega com objeto do perfil no fluxo seguinte', (
      tester,
    ) async {
      final router = GoRouter(
        initialLocation: '/profile',
        routes: [
          GoRoute(
            path: '/profile',
            builder: (context, state) => const _Cf192MenuHarness(
              artistId: 'gus-art',
              artistName: 'Gus Art',
            ),
          ),
          GoRoute(
            path: Pages.report,
            builder: (context, state) => ReportScreen(
              contextKind: ReportService.parseContext(
                state.uri.queryParameters['context'],
              ),
              targetId: state.uri.queryParameters['targetId'],
              displayName: state.uri.queryParameters['displayName'],
            ),
          ),
        ],
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
      await tester.pump(const Duration(milliseconds: 350));

      expect(router.state.uri.path, Pages.report);
      expect(router.state.uri.queryParameters['context'], 'artist-profile');
      expect(router.state.uri.queryParameters['targetId'], 'gus-art');
      expect(router.state.uri.queryParameters['displayName'], 'Gus Art');
      expect(find.text('Denunciar perfil de artista'), findsOneWidget);
      expect(
        find.text('Por que você está denunciando Gus Art?'),
        findsOneWidget,
      );
    });

    testWidgets('Abrir fã clube chama callback (sem ações de post)', (
      tester,
    ) async {
      var opened = false;
      await tester.pumpWidget(
        MaterialApp(
          theme: buildCrowdFansTheme(Brightness.light),
          home: Scaffold(
            body: ArtistProfileOptionsSheet(
              visible: true,
              artistId: 'artist-1',
              artistName: 'Gus Art',
              onClose: () {},
              onOpenFanClub: () => opened = true,
            ),
          ),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.text('Favoritar'), findsNothing);
      expect(find.text('Compartilhar'), findsNothing);
      expect(find.text('Copiar link'), findsNothing);
      expect(find.text('Memórias'), findsNothing);

      await tester.tap(find.text('Abrir fã clube'));
      await tester.pump();
      expect(opened, isTrue);
    });
  });

  group('CF-192 red — bloqueio / vazio / ação negada', () {
    testWidgets('visível=false não mostra ações', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: buildCrowdFansTheme(Brightness.light),
          home: Scaffold(
            body: ArtistProfileOptionsSheet(
              visible: false,
              artistId: 'artist-1',
              artistName: 'Gus Art',
              onClose: () {},
            ),
          ),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.text('Denunciar'), findsNothing);
      expect(find.text('Abrir fã clube'), findsNothing);
    });

    testWidgets(
      'chrome legado (Ações do perfil / Reportar / rótulo longo) ausente',
      (tester) async {
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
        await tester.pump(const Duration(milliseconds: 300));

        expect(find.text('Denunciar'), findsOneWidget);
        expect(find.text('Ações do perfil'), findsNothing);
        expect(find.text('Reportar'), findsNothing);
        expect(find.text('Denunciar perfil de artista'), findsNothing);
        expect(find.text('Denunciar este artista'), findsNothing);
      },
    );

    testWidgets(
      'enviar denúncia sem targetId mostra Alvo da denúncia inválido',
      (tester) async {
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
        await tester.pump();

        expect(find.text('Denunciar perfil de artista'), findsOneWidget);
        await tester.tap(find.text('Spam'));
        await tester.pump();

        await tester.tap(find.text('Enviar denúncia'));
        await tester.pumpAndSettle();

        expect(find.text('Alvo da denúncia inválido.'), findsOneWidget);
      },
    );

    testWidgets('artistId vazio: Denunciar fecha e não navega', (tester) async {
      final router = GoRouter(
        initialLocation: '/profile',
        routes: [
          GoRoute(
            path: '/profile',
            builder: (context, state) =>
                const _Cf192MenuHarness(artistId: '   ', artistName: 'Gus Art'),
          ),
          GoRoute(
            path: Pages.report,
            builder: (context, state) =>
                const Scaffold(body: Text('report-opened')),
          ),
        ],
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
      await tester.pump(const Duration(milliseconds: 350));

      expect(find.text('report-opened'), findsNothing);
      expect(find.text('Denunciar'), findsNothing);
    });

    testWidgets('artistId vazio: Abrir fã clube não chama callback', (
      tester,
    ) async {
      var opened = false;
      var closed = false;
      await tester.pumpWidget(
        MaterialApp(
          theme: buildCrowdFansTheme(Brightness.light),
          home: Scaffold(
            body: ArtistProfileOptionsSheet(
              visible: true,
              artistId: '',
              artistName: 'Gus Art',
              onClose: () => closed = true,
              onOpenFanClub: () => opened = true,
            ),
          ),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      await tester.tap(find.text('Abrir fã clube'));
      await tester.pump();

      expect(closed, isTrue);
      expect(opened, isFalse);
    });
  });

  group('CF-192 edge — texto longo / nome vazio / texto ampliado', () {
    test('nome vazio vira fallback artista na rota', () {
      final route = artistProfileReportRoute(artistId: 'a1', artistName: '  ');
      expect(route, contains('displayName=artista'));
    });

    test('nome longo é encoded sem cortar id', () {
      final long = 'A' * 80;
      final route = artistProfileReportRoute(
        artistId: 'artist-long',
        artistName: long,
      );
      expect(route, contains('targetId=artist-long'));
      expect(route, contains(Uri.encodeQueryComponent(long)));
    });

    test('nome e id especiais ficam URL-encoded', () {
      const id = 'id/with spaces&x';
      const name = 'Ana & João?';
      final route = artistProfileReportRoute(artistId: id, artistName: name);
      final uri = Uri.parse(route);
      expect(uri.queryParameters['context'], 'artist-profile');
      expect(uri.queryParameters['targetId'], id);
      expect(uri.queryParameters['displayName'], name);
      expect(route, contains(Uri.encodeQueryComponent(id)));
      expect(route, contains(Uri.encodeQueryComponent(name)));
    });

    testWidgets('texto ampliado: ambas ações cabem e são tocáveis', (
      tester,
    ) async {
      await tester.binding.setSurfaceSize(const Size(320, 640));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      var reported = false;
      var opened = false;
      await tester.pumpWidget(
        MaterialApp(
          theme: buildCrowdFansTheme(Brightness.light),
          home: MediaQuery(
            data: const MediaQueryData(textScaler: TextScaler.linear(1.6)),
            child: Scaffold(
              body: ArtistProfileOptionsSheet(
                visible: true,
                artistId: 'artist-1',
                artistName: 'Nome Muito Longo Do Artista Para Edge',
                onClose: () {},
                onOpenFanClub: () => opened = true,
              ),
            ),
          ),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.text('Denunciar'), findsOneWidget);
      expect(find.text('Abrir fã clube'), findsOneWidget);

      await tester.tap(find.text('Abrir fã clube'));
      await tester.pump();
      expect(opened, isTrue);

      // Reabre para toque em Denunciar via callback de close+route
      // (aqui só garante que o hit target existe com scaler).
      reported = find.text('Denunciar').evaluate().isNotEmpty;
      expect(reported, isTrue);
    });

    testWidgets('scrim opaco: fundo não recebe toque enquanto aberto', (
      tester,
    ) async {
      var behindTapped = false;
      var closed = false;
      await tester.pumpWidget(
        MaterialApp(
          theme: buildCrowdFansTheme(Brightness.light),
          home: Scaffold(
            body: Stack(
              children: [
                Positioned.fill(
                  child: GestureDetector(
                    onTap: () => behindTapped = true,
                    child: const ColoredBox(color: Colors.red),
                  ),
                ),
                ArtistProfileOptionsSheet(
                  visible: true,
                  artistId: 'artist-1',
                  artistName: 'Gus Art',
                  onClose: () => closed = true,
                ),
              ],
            ),
          ),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      // Toque no canto superior (área do scrim do overlay).
      await tester.tapAt(const Offset(10, 10));
      await tester.pump();

      expect(behindTapped, isFalse);
      expect(closed, isTrue);
    });

    testWidgets('onClose no scrim não navega para denúncia nem fã clube', (
      tester,
    ) async {
      var closed = false;
      final router = GoRouter(
        initialLocation: '/profile',
        routes: [
          GoRoute(
            path: '/profile',
            builder: (context, state) => Scaffold(
              body: ArtistProfileOptionsSheet(
                visible: true,
                artistId: 'artist-1',
                artistName: 'Gus Art',
                onClose: () => closed = true,
              ),
            ),
          ),
          GoRoute(
            path: Pages.report,
            builder: (context, state) =>
                const Scaffold(body: Text('report-opened')),
          ),
          GoRoute(
            path: '/fan-clubs/community/:artistId',
            builder: (context, state) =>
                const Scaffold(body: Text('fan-club-opened')),
          ),
        ],
      );

      await tester.pumpWidget(
        MaterialApp.router(
          theme: buildCrowdFansTheme(Brightness.light),
          routerConfig: router,
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      await tester.tapAt(const Offset(10, 10));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 350));

      expect(closed, isTrue);
      expect(router.state.uri.path, '/profile');
      expect(find.text('report-opened'), findsNothing);
      expect(find.text('fan-club-opened'), findsNothing);
    });
  });
}
