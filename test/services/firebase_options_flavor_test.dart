import 'package:crowdfans/firebase_options.dart';
import 'package:crowdfans/firebase_options_digitalocean.dart';
import 'package:crowdfans/firebase_options_gcp.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  setUp(() {
    dotenv.loadFromString(envString: '', isOptional: true);
  });

  tearDown(() {
    dotenv.loadFromString(envString: '', isOptional: true);
  });

  group('stubs sem segredos', () {
    test('gcp android usa placeholder REPLACE_ME', () {
      expect(
        GcpFirebaseOptions.android.apiKey,
        contains('REPLACE_ME'),
      );
      expect(GcpFirebaseOptions.android.projectId, 'crowdfans-prod');
    });

    test('digitalocean android usa placeholder REPLACE_ME', () {
      expect(
        DigitalOceanFirebaseOptions.android.apiKey,
        contains('REPLACE_ME'),
      );
      expect(DigitalOceanFirebaseOptions.android.projectId, 'crowdfans-prod');
    });

    test('appIds de stub diferem por flavor', () {
      expect(
        GcpFirebaseOptions.android.appId,
        isNot(DigitalOceanFirebaseOptions.android.appId),
      );
    });
  });

  group('seletor DefaultFirebaseOptions', () {
    test('default flavor gcp → stub gcp', () {
      expect(DefaultFirebaseOptions.activeStubName, 'gcp');
      expect(
        DefaultFirebaseOptions.currentPlatform.apiKey,
        GcpFirebaseOptions.android.apiKey,
      );
    });

    test('APP_FLAVOR=digitalocean → stub digitalocean', () {
      dotenv.loadFromString(envString: 'APP_FLAVOR=digitalocean\n');
      expect(DefaultFirebaseOptions.activeStubName, 'digitalocean');
      expect(
        DefaultFirebaseOptions.currentPlatform.apiKey,
        DigitalOceanFirebaseOptions.android.apiKey,
      );
    });
  });
}
