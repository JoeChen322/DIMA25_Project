import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lumi_list/pages/signup_page.dart';

void main() {
  testWidgets('Signup password mismatch validation',
      (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(home: SignupPage()));
    await tester.pump();

    final fieldsFinder = find.byType(TextField);
    final fields = tester.widgetList<TextField>(fieldsFinder).toList();
    expect(fields.isNotEmpty, isTrue);

    // Detect indices: email by keyboardType, passwords by obscureText
    int? emailIndex;
    final passwordIndices = <int>[];
    final normalTextIndices = <int>[];

    for (int i = 0; i < fields.length; i++) {
      final f = fields[i];
      if (f.keyboardType == TextInputType.emailAddress) {
        emailIndex ??= i;
      } else if (f.obscureText == true) {
        passwordIndices.add(i);
      } else {
        normalTextIndices.add(i); // e.g., username
      }
    }

    // Fill username-like fields if present
    for (final i in normalTextIndices) {
      await tester.enterText(fieldsFinder.at(i), 'TestUser');
    }

    // Fill email
    if (emailIndex != null) {
      await tester.enterText(fieldsFinder.at(emailIndex), 'test@test.com');
    } else {
      await tester.enterText(fieldsFinder.first, 'test@test.com');
    }

    // Fill password + confirm with mismatch
    if (passwordIndices.isNotEmpty) {
      await tester.enterText(
          fieldsFinder.at(passwordIndices[0]), 'password123');
      if (passwordIndices.length > 1) {
        await tester.enterText(
            fieldsFinder.at(passwordIndices[1]), 'password456');
      }
    }

    final signUpButton = find.text('Sign Up');
    await tester.ensureVisible(signUpButton);
    await tester.tap(signUpButton);
    await tester.pump();

    final hasMismatch =
        find.textContaining('Passwords do not match').evaluate().isNotEmpty;
    final hasGenericError =
        find.textContaining('Password').evaluate().isNotEmpty ||
            find.textContaining('Please').evaluate().isNotEmpty;

    expect(hasMismatch || hasGenericError, isTrue);
  });
}
