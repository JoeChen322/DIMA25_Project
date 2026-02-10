import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lumi_list/pages/login_page.dart';

void main() {
  testWidgets('Login page basic UI + validation (key-based)',
      (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(home: LoginPage()));
    await tester.pump();

    // Basic UI
    expect(find.text('Welcome Back'), findsOneWidget);
    expect(find.byKey(LoginPage.kEmailField), findsOneWidget);
    expect(find.byKey(LoginPage.kPasswordField), findsOneWidget);
    expect(find.byKey(LoginPage.kLoginButton), findsOneWidget);

    // Password field should start obscured
    TextField pwdField =
        tester.widget<TextField>(find.byKey(LoginPage.kPasswordField));
    expect(pwdField.obscureText, isTrue);

    // Toggle visibility if icon exists
    final toggleOff = find.byIcon(Icons.visibility_off);
    if (toggleOff.evaluate().isNotEmpty) {
      await tester.tap(toggleOff);
      await tester.pump();

      pwdField = tester.widget<TextField>(find.byKey(LoginPage.kPasswordField));
      expect(pwdField.obscureText, isFalse);
    }

    // Tap login with empty fields -> should show validation SnackBar
    await tester.tap(find.byKey(LoginPage.kLoginButton));
    await tester.pump(); // start SnackBar animation
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.textContaining('Please fill in all fields'), findsOneWidget);
  });
}
