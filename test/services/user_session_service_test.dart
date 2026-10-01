import 'package:crowdfans/services/user_session_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('currentSessionId persiste o mesmo UUID', () async {
    SharedPreferences.setMockInitialValues({});
    final first = await UserSessionService.currentSessionId();
    final second = await UserSessionService.currentSessionId();
    expect(first, isNotEmpty);
    expect(first, second);
    expect(
      RegExp(
        r'^[0-9a-f]{8}-[0-9a-f]{4}-4[0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$',
      ).hasMatch(first),
      isTrue,
    );
  });
}
