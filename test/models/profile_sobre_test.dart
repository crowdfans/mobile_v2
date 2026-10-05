import 'package:crowdfans/components/profile/artist_sobre_links.dart';
import 'package:crowdfans/models/profile.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('CF-269 Profile Sobre — green', () {
    test('fromJson mapeia location/track/listeners/genre/redes', () {
      final profile = Profile.fromJson({
        'userUid': 'u1',
        'displayName': 'Ludmilla',
        'name': 'Ludmilla',
        'description': 'Bio',
        'photoUrl': '',
        'isArtist': true,
        'location': 'Rio de Janeiro, BR',
        'trackTitle': 'Maldivas',
        'playlistSubtitle': 'Playlist em destaque',
        'monthlyListeners': '8,9 mi ouvintes',
        'genre': 'Pop e R&B',
        'openSpotifyAlbum': 'Numanice #3',
        'spotifyProfileUrl':
            'https://open.spotify.com/artist/3CDoRporvSjdzTayoYFRia',
        'previewReady': true,
        'instagramHandle': '@ludmilla',
        'youtubeHandle': 'Ludmilla',
      });
      expect(profile.location, 'Rio de Janeiro, BR');
      expect(profile.trackTitle, 'Maldivas');
      expect(profile.monthlyListeners, '8,9 mi ouvintes');
      expect(profile.genre, 'Pop e R&B');
      expect(profile.previewReady, isTrue);
      expect(profile.instagramHandle, '@ludmilla');
      expect(profile.youtubeHandle, 'Ludmilla');
      expect(profile.spotifyProfileUrl, contains('spotify.com/artist'));
    });
  });

  group('CF-269 Profile Sobre — red', () {
    test('JSON parcial / ausente não inventa métricas', () {
      final profile = Profile.fromJson({
        'userUid': 'u2',
        'displayName': 'Gus',
        'name': 'Gus',
        'description': '',
        'photoUrl': '',
        'isArtist': true,
      });
      expect(profile.location, isEmpty);
      expect(profile.trackTitle, isEmpty);
      expect(profile.monthlyListeners, isEmpty);
      expect(profile.genre, isEmpty);
      expect(profile.previewReady, isFalse);
      expect(artistSobreMetricLabel(profile.monthlyListeners), 'Não informado');
      expect(artistSobreMetricLabel(profile.genre), 'Não informado');
    });
  });

  group('CF-269 Profile Sobre — edge', () {
    test('listeners zero e strings longas / handles', () {
      final long =
          'Maldivas ao vivo no Maracanã com convidados especiais e remix';
      final profile = Profile.fromJson({
        'userUid': 'u3',
        'displayName': 'Ludmilla',
        'name': 'Ludmilla',
        'description': '',
        'photoUrl': '',
        'isArtist': true,
        'trackTitle': long,
        'monthlyListeners': '0',
        'instagramHandle': '  @ludmilla  ',
        'youtubeHandle': 'Ludmilla',
      });
      expect(artistSobreMetricLabel(profile.monthlyListeners), '0');
      expect(profile.trackTitle.length, greaterThan(40));
      expect(instagramProfileUrl(profile.instagramHandle),
          'https://instagram.com/ludmilla');
      expect(youtubeProfileUrl(profile.youtubeHandle),
          'https://youtube.com/@Ludmilla');
      expect(instagramProfileUrl(''), isNull);
      expect(youtubeProfileUrl('   '), isNull);
    });
  });
}
