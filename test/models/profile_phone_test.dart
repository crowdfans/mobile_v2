import 'package:crowdfans/models/profile.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Profile.fromJson lê phone/phoneVerified (CF-271)', () {
    final profile = Profile.fromJson({
      'userUid': 'u1',
      'displayName': 'Fan',
      'name': 'fan',
      'description': '',
      'photoUrl': '',
      'isArtist': false,
      'phone': '+5511999999999',
      'phoneVerified': true,
    });
    expect(profile.phone, '+5511999999999');
    expect(profile.phoneVerified, isTrue);
  });

  test('Profile.fromJson tolera phone ausente', () {
    final profile = Profile.fromJson({
      'userUid': 'u1',
      'displayName': 'Fan',
      'name': 'fan',
      'description': '',
      'photoUrl': '',
      'isArtist': false,
    });
    expect(profile.phone, '');
    expect(profile.phoneVerified, isFalse);
  });
}
