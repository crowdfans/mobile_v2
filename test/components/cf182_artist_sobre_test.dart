import 'package:crowdfans/components/profile/artist_profile_social_links_card.dart';
import 'package:crowdfans/components/profile/artist_profile_spotify_card.dart';
import 'package:crowdfans/components/profile/artist_profile_stat_tile.dart';
import 'package:crowdfans/components/profile/artist_sobre_base.dart';
import 'package:crowdfans/constants/theme.dart';
import 'package:crowdfans/mocks/cf_temp_mocks.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('CF-182 green — print Ludmilla Sobre', () {
    test('amostra print Spotify/base/redes; fixture TEMP off (CF-269)', () {
      expect(CfTempMocks.useArtistSobreFixtures, isFalse);
      expect(Cf182ArtistSobreMock.location, 'Rio de Janeiro, BR');
      expect(Cf182ArtistSobreMock.trackTitle, 'Maldivas');
      expect(Cf182ArtistSobreMock.playlistSubtitle, 'Playlist em destaque');
      expect(Cf182ArtistSobreMock.monthlyListeners, '8,9 mi ouvintes');
      expect(Cf182ArtistSobreMock.genre, 'Pop e R&B');
      expect(Cf182ArtistSobreMock.openSpotifyAlbum, 'Numanice #3');
      expect(Cf182ArtistSobreMock.instagramHandle, '@ludmilla');
      expect(Cf182ArtistSobreMock.youtubeHandle, 'Ludmilla');
    });

    testWidgets('card Spotify: hierarquia play / métricas / abrir', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: buildCrowdFansTheme(Brightness.light),
          home: Scaffold(
            body: SingleChildScrollView(
              child: ArtistProfileSpotifyCard(
                artistName: 'Ludmilla',
                title: Cf182ArtistSobreMock.trackTitle,
                subtitle: Cf182ArtistSobreMock.playlistSubtitle,
                previewReady: true,
                monthlyListeners: Cf182ArtistSobreMock.monthlyListeners,
                genre: Cf182ArtistSobreMock.genre,
                playlistName: Cf182ArtistSobreMock.trackTitle,
                openSpotifyAlbum: Cf182ArtistSobreMock.openSpotifyAlbum,
                onOpenSpotify: () {},
              ),
            ),
          ),
        ),
      );
      await tester.pump();

      expect(find.text('Spotify'), findsOneWidget);
      expect(find.text('Maldivas'), findsWidgets);
      expect(find.text('Playlist em destaque'), findsOneWidget);
      expect(find.text('Prévia Spotify'), findsOneWidget);
      expect(find.text('0:00 / 0:15'), findsOneWidget);
      expect(find.text('Prévia pronta para tocar'), findsOneWidget);
      expect(find.text('OUVINTES MENSAIS'), findsOneWidget);
      expect(find.text('8,9 mi ouvintes'), findsOneWidget);
      expect(find.text('GÊNERO'), findsOneWidget);
      expect(find.text('Pop e R&B'), findsOneWidget);
      expect(find.text('PLAYLIST'), findsOneWidget);
      expect(find.text('ABRIR NO SPOTIFY'), findsOneWidget);
      expect(find.text('Numanice #3'), findsOneWidget);
      expect(find.byIcon(Icons.play_circle_filled), findsOneWidget);
      // Sem CTA legado do app antigo.
      expect(find.text('Abrir fã clube'), findsNothing);
    });

    testWidgets('Base + Outras redes do print', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: buildCrowdFansTheme(Brightness.light),
          home: Scaffold(
            body: Column(
              children: [
                ArtistProfileStatTile(
                  label: 'Base',
                  value: artistSobreBaseLabel(Cf182ArtistSobreMock.location),
                ),
                ArtistProfileSocialLinksCard(
                  instagramHandle: Cf182ArtistSobreMock.instagramHandle,
                  youtubeHandle: Cf182ArtistSobreMock.youtubeHandle,
                  onInstagram: () {},
                  onYoutube: () {},
                ),
              ],
            ),
          ),
        ),
      );
      await tester.pump();

      expect(find.text('Base'), findsOneWidget);
      expect(find.text('Rio de Janeiro, BR'), findsOneWidget);
      expect(find.text('Outras redes'), findsOneWidget);
      expect(find.text('Instagram'), findsOneWidget);
      expect(find.text('@ludmilla'), findsOneWidget);
      expect(find.text('YouTube'), findsOneWidget);
      expect(find.text('Ludmilla'), findsOneWidget);
      expect(find.text('Abrir fã clube'), findsNothing);
    });
  });

  group('CF-182 red — sem fixture / indisponível', () {
    test('Base não inventa Brasil nem cidade', () {
      expect(artistSobreBaseLabel(null), 'Não informado');
      expect(artistSobreBaseLabel(''), 'Não informado');
      expect(artistSobreBaseLabel('  '), 'Não informado');
    });

    testWidgets('card Spotify sem track: indisponível, sem abrir', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: buildCrowdFansTheme(Brightness.light),
          home: const Scaffold(
            body: ArtistProfileSpotifyCard(
              artistName: 'Gus Art',
              previewReady: false,
              monthlyListeners: 'Não informado',
              genre: 'Não informado',
            ),
          ),
        ),
      );
      await tester.pump();

      expect(find.text('Prévia indisponível'), findsOneWidget);
      expect(find.text('Sem prévia no cadastro do artista'), findsOneWidget);
      expect(find.text('Prévia não disponível neste perfil'), findsOneWidget);
      expect(find.text('Não informado'), findsNWidgets(2));
      expect(find.text('ABRIR NO SPOTIFY'), findsNothing);
      expect(find.text('Abrir fã clube'), findsNothing);
      expect(find.text('Maldivas'), findsNothing);
    });

    testWidgets('redes sem handle: Não vinculada', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: buildCrowdFansTheme(Brightness.light),
          home: const Scaffold(body: ArtistProfileSocialLinksCard()),
        ),
      );
      await tester.pump();

      expect(find.text('Não vinculada'), findsNWidgets(2));
      expect(find.text('@ludmilla'), findsNothing);
    });
  });

  group('CF-182 edge — texto longo / teclado / zero', () {
    testWidgets('título longo não estoura o player', (tester) async {
      const longTitle =
          'Maldivas ao vivo no Maracanã com convidados especiais e remix estendido da turnê Numanice';
      await tester.pumpWidget(
        MaterialApp(
          theme: buildCrowdFansTheme(Brightness.light),
          home: Scaffold(
            body: SingleChildScrollView(
              child: ArtistProfileSpotifyCard(
                artistName: 'Ludmilla',
                title: longTitle,
                previewReady: true,
                monthlyListeners: Cf182ArtistSobreMock.monthlyListeners,
                genre: Cf182ArtistSobreMock.genre,
                playlistName: longTitle,
                openSpotifyAlbum: Cf182ArtistSobreMock.openSpotifyAlbum,
                onOpenSpotify: () {},
              ),
            ),
          ),
        ),
      );
      await tester.pump();

      final titleTexts = tester.widgetList<Text>(
        find.textContaining('Maldivas ao vivo'),
      );
      expect(titleTexts, isNotEmpty);
      // Player reserva altura do waveform mesmo com título longo.
      expect(find.byType(SizedBox), findsWidgets);
      expect(tester.takeException(), isNull);
    });

    testWidgets('TextField sobreposto (teclado) não quebra Sobre', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: buildCrowdFansTheme(Brightness.light),
          home: Scaffold(
            body: ListView(
              children: [
                ArtistProfileStatTile(
                  label: 'Base',
                  value: artistSobreBaseLabel(Cf182ArtistSobreMock.location),
                ),
                const Padding(
                  padding: EdgeInsets.all(8),
                  child: TextField(
                    decoration: InputDecoration(hintText: 'Buscar'),
                  ),
                ),
                ArtistProfileSpotifyCard(
                  artistName: 'Ludmilla',
                  title: Cf182ArtistSobreMock.trackTitle,
                  previewReady: true,
                  monthlyListeners: Cf182ArtistSobreMock.monthlyListeners,
                  genre: Cf182ArtistSobreMock.genre,
                  onOpenSpotify: () {},
                ),
              ],
            ),
          ),
        ),
      );
      await tester.pump();
      await tester.tap(find.byType(TextField));
      await tester.pump();
      expect(find.text('Maldivas'), findsWidgets);
      expect(tester.takeException(), isNull);
    });

    test('members zero / fixture off: Base sem inventar', () {
      expect(artistSobreBaseLabel(null), isNot(equals('Brasil')));
      expect(artistSobreBaseLabel(null), isNot(equals('Rio de Janeiro, BR')));
    });
  });
}
