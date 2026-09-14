import 'package:crowdfans/components/login/credentials_form.dart';
import 'package:crowdfans/constants/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('ENTER na senha chama onSubmit do login', (tester) async {
    var submitted = false;

    await tester.pumpWidget(
      MaterialApp(
        theme: buildCrowdFansTheme(Brightness.light),
        home: Scaffold(
          body: CredentialsForm(
            email: 'a@b.com',
            password: 'secret',
            onEmailChanged: (_) {},
            onPasswordChanged: (_) {},
            onSubmit: () => submitted = true,
            onForgotPassword: () {},
          ),
        ),
      ),
    );

    await tester.enterText(find.byKey(const Key('login-password')), 'secret');
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pump();

    expect(submitted, isTrue);
  });
}
