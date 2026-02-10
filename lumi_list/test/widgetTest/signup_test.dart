import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lumi_list/pages/signup_page.dart';

void main() {
  testWidgets('Signup password mismatch validation (key-based)',
      (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(home: SignupPage()));
    await tester.pump();

    // Ensure key widgets exist
    expect(find.byKey(SignupPage.kEmailField), findsOneWidget);
    expect(find.byKey(SignupPage.kPasswordField), findsOneWidget);
    expect(find.byKey(SignupPage.kConfirmField), findsOneWidget);
    expect(find.byKey(SignupPage.kSubmitButton), findsOneWidget);

    // Fill email + mismatching passwords
    await tester.enterText(find.byKey(SignupPage.kEmailField), 'test@test.com');
    await tester.enterText(
        find.byKey(SignupPage.kPasswordField), 'password123');
    await tester.enterText(find.byKey(SignupPage.kConfirmField), 'password456');

    // Tap signup
    await tester.ensureVisible(find.byKey(SignupPage.kSubmitButton));
    await tester.tap(find.byKey(SignupPage.kSubmitButton));
    await tester.pump(); // start SnackBar
    await tester.pump(const Duration(milliseconds: 300));

    // SignupPage shows this exact message:
    expect(find.textContaining('Passwords do not match'), findsOneWidget);
  });
}
