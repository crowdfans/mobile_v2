import 'package:crowdfans/api/api_error.dart';
import 'package:crowdfans/services/media_service.dart';
import 'package:crowdfans/services/media_url_shapes.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  setUp(() {
    dotenv.loadFromString(envString: 'APP_FLAVOR=gcp\n', isOptional: true);
  });

  tearDown(() {
    dotenv.loadFromString(envString: '', isOptional: true);
  });

  group('GREEN — shapes GCS', () {
    test('public path-style storage.googleapis.com', () {
      final url =
          'https://storage.googleapis.com/crowdfans-media-gcp/users/u1/posts/2026/10/obj.jpg';
      expect(isGcsPublicUrl(url), isTrue);
      expect(isSpacesMediaUrl(url), isFalse);
      expect(isAllowedPublicMediaUrl(url), isTrue);
    });

    test('signed PUT com X-Goog-*', () {
      final url =
          'https://storage.googleapis.com/crowdfans-media-gcp/users/u1/posts/a.jpg'
          '?X-Goog-Algorithm=GOOG4-RSA-SHA256'
          '&X-Goog-Credential=sa%40proj.iam.gserviceaccount.com%2F20261007%2Fauto%2Fstorage%2Fgoog4_request'
          '&X-Goog-Date=20261007T120000Z'
          '&X-Goog-Expires=900'
          '&X-Goog-SignedHeaders=content-type%3Bhost'
          '&X-Goog-Signature=abc123';
      expect(isGcsSignedUploadUrl(url), isTrue);
      expect(isAllowedUploadUrl(url), isTrue);
    });

    test('buildGcsPublicObjectUrl alinha ao server PublicURL', () {
      expect(
        buildGcsPublicObjectUrl('users/111/posts/2026/10/obj.jpg'),
        'https://storage.googleapis.com/crowdfans-media-gcp/users/111/posts/2026/10/obj.jpg',
      );
    });

    test('resolveMediaUrl aceita https GCS sem upload', () async {
      final url =
          'https://storage.googleapis.com/crowdfans-media-gcp/users/u/avatars/a.png';
      final got = await MediaService.resolveMediaUrl(
        uri: url,
        kind: MediaKind.avatar,
      );
      expect(got, url);
    });

    test('MediaPresignPayload parseia objectKey/expiresIn', () {
      final p = MediaPresignPayload.fromJson({
        'uploadUrl':
            'https://storage.googleapis.com/b/o?X-Goog-Algorithm=GOOG4-RSA-SHA256&X-Goog-Signature=x',
        'method': 'PUT',
        'headers': {'Content-Type': 'image/jpeg'},
        'publicUrl':
            'https://storage.googleapis.com/crowdfans-media-gcp/users/u/posts/a.jpg',
        'objectKey': 'users/u/posts/a.jpg',
        'expiresIn': 900,
      });
      expect(p.objectKey, 'users/u/posts/a.jpg');
      expect(p.expiresIn, 900);
      expect(p.method, 'PUT');
    });
  });

  group('RED — Spaces / inválido no flavor gcp', () {
    test('digitaloceanspaces.com rejeitado como public', () {
      const spaces =
          'https://crowdfans-media-prod.nyc3.digitaloceanspaces.com/users/u/posts/a.jpg';
      expect(isSpacesMediaUrl(spaces), isTrue);
      expect(isAllowedPublicMediaUrl(spaces), isFalse);
    });

    test('resolveMediaUrl com Spaces lança ApiError', () async {
      const spaces =
          'https://crowdfans-media-prod.nyc3.digitaloceanspaces.com/users/u/posts/a.jpg';
      expect(
        () => MediaService.resolveMediaUrl(
          uri: spaces,
          kind: MediaKind.post,
        ),
        throwsA(isA<ApiError>()),
      );
    });

    test('upload URL Spaces rejeitada', () {
      const spaces =
          'https://crowdfans-media-prod.nyc3.digitaloceanspaces.com/users/u/posts/a.jpg?X-Amz-Signature=x';
      expect(isAllowedUploadUrl(spaces), isFalse);
    });

    test('http sem host GCS rejeitado', () {
      expect(
        isAllowedPublicMediaUrl('https://example.com/photo.jpg'),
        isFalse,
      );
    });
  });

  group('EDGE — CDN / virtual-host / flavor digitalocean', () {
    test('virtual-hosted bucket.storage.googleapis.com', () {
      const url =
          'https://crowdfans-media-gcp.storage.googleapis.com/users/u/posts/a.jpg';
      expect(isGcsPublicUrl(url), isTrue);
      expect(isAllowedPublicMediaUrl(url), isTrue);
    });

    test('CDN via MEDIA_GCS_PUBLIC_BASE_URL', () {
      dotenv.loadFromString(
        envString:
            'APP_FLAVOR=gcp\n'
            'MEDIA_GCS_PUBLIC_BASE_URL=https://cdn.example.com/media\n',
      );
      expect(
        isGcsPublicUrl('https://cdn.example.com/media/users/u/posts/a.jpg'),
        isTrue,
      );
      expect(
        isAllowedPublicMediaUrl('https://cdn.example.com/media/users/u/posts/a.jpg'),
        isTrue,
      );
    });

    test('flavor digitalocean aceita Spaces', () {
      dotenv.loadFromString(envString: 'APP_FLAVOR=digitalocean\n');
      const spaces =
          'https://crowdfans-media-prod.nyc3.digitaloceanspaces.com/users/u/posts/a.jpg';
      expect(mediaBackendExpectsGcs(), isFalse);
      expect(isAllowedPublicMediaUrl(spaces), isTrue);
    });

    test('trailing slash / objectKey com leading slash', () {
      expect(
        buildGcsPublicObjectUrl('/users/u/avatars/x.png'),
        endsWith('users/u/avatars/x.png'),
      );
      expect(
        buildGcsPublicObjectUrl('/users/u/avatars/x.png').contains('//users'),
        isFalse,
      );
    });
  });
}
