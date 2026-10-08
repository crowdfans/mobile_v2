import 'dart:typed_data';

import 'package:crowdfans/api/api_error.dart';
import 'package:crowdfans/firebase_options.dart';
import 'package:crowdfans/services/firebase_service.dart';
import 'package:crowdfans/services/http_service.dart';
import 'package:crowdfans/services/object_storage_client.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  setUp(() {
    dotenv.loadFromString(envString: 'APP_FLAVOR=gcp\n', isOptional: true);
  });

  tearDown(() {
    dotenv.loadFromString(envString: '', isOptional: true);
  });

  group('GREEN — storage headers + auth contract', () {
    test('headersForSignedUpload define Content-Type e remove Authorization', () {
      final headers = ObjectStorageClient.headersForSignedUpload(
        fromServer: {
          'Content-Type': 'image/png',
          'Authorization': 'Bearer should-not-reach-gcs',
          'x-amz-acl': 'public-read',
        },
        contentType: 'image/jpeg',
      );
      expect(headers['Content-Type'], 'image/jpeg');
      expect(headers.containsKey('Authorization'), isFalse);
      expect(
        headers.keys.any((k) => k.toLowerCase().startsWith('x-amz-')),
        isFalse,
      );
    });

    test('HttpService.isObjectStoreUrl reconhece GCS signed', () {
      const signed =
          'https://storage.googleapis.com/crowdfans-media-gcp/users/u1/a.jpg'
          '?X-Goog-Algorithm=GOOG4-RSA-SHA256'
          '&X-Goog-Credential=sa%40proj.iam.gserviceaccount.com%2F20261007%2Fauto%2Fstorage%2Fgoog4_request'
          '&X-Goog-Date=20261007T120000Z'
          '&X-Goog-Expires=900'
          '&X-Goog-SignedHeaders=content-type%3Bhost'
          '&X-Goog-Signature=deadbeef';
      expect(HttpService.isObjectStoreUrl(signed), isTrue);
      expect(HttpService.isObjectStoreUrl('/api/v1/me'), isFalse);
    });

    test('Firebase stub options detetáveis no flavor gcp', () {
      expect(
        DefaultFirebaseOptions.currentPlatform.apiKey,
        contains('REPLACE_ME'),
      );
      expect(FirebaseService.usingStubOptions, isTrue);
    });
  });

  group('RED — HttpService bloqueia object store', () {
    test('request a GCS public URL falha sem rede', () async {
      await expectLater(
        HttpService.request<dynamic>(
          'https://storage.googleapis.com/crowdfans-media-gcp/users/u1/x.jpg',
          requireAuth: false,
        ),
        throwsA(
          isA<ApiError>().having(
            (e) => e.message,
            'message',
            contains('ObjectStorageClient'),
          ),
        ),
      );
    });

    test('putSignedBytes rejeita Spaces no flavor gcp', () async {
      await expectLater(
        ObjectStorageClient.putSignedBytes(
          uploadUrl:
              'https://crowdfans.nyc3.digitaloceanspaces.com/users/u1/a.jpg'
              '?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Signature=abc',
          method: 'PUT',
          headers: {'Content-Type': 'image/jpeg'},
          bytes: Uint8List.fromList([1, 2, 3]),
        ),
        throwsA(isA<ApiError>()),
      );
    });
  });

  group('EDGE — headers vazios / path relativo', () {
    test('headersForSignedUpload com map vazio só Content-Type', () {
      final headers = ObjectStorageClient.headersForSignedUpload(
        fromServer: const {},
        contentType: 'image/webp',
      );
      expect(headers, {'Content-Type': 'image/webp'});
    });

    test('HttpService.isObjectStoreUrl false para API absoluta Cloud Run', () {
      expect(
        HttpService.isObjectStoreUrl(
          'https://crowdfans-server-staging.southamerica-east1.run.app/api/v1/me',
        ),
        isFalse,
      );
    });

    test('digitalocean flavor não remove x-amz-*', () {
      dotenv.loadFromString(
        envString: 'APP_FLAVOR=digitalocean\n',
        isOptional: true,
      );
      final headers = ObjectStorageClient.headersForSignedUpload(
        fromServer: {'x-amz-acl': 'public-read'},
        contentType: 'image/jpeg',
      );
      expect(headers['x-amz-acl'], 'public-read');
      expect(headers['Content-Type'], 'image/jpeg');
    });
  });
}
