import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lumi_list/pages/login_page.dart';

void main() {
  testWidgets('Login page basic UI + validation', (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(home: LoginPage()));
    await tester.pump();

    expect(find.text('Welcome Back'), findsOneWidget);
    expect(find.widgetWithText(ElevatedButton, 'Login'), findsOneWidget);

    // Password field obscure toggle (assumes visibility icon exists)
    final passwordFieldFinder = find.byType(TextField).last;
    TextField tf = tester.widget<TextField>(passwordFieldFinder);
    expect(tf.obscureText, isTrue);

    final toggleIcon = find.byIcon(Icons.visibility_off);
    if (toggleIcon.evaluate().isNotEmpty) {
      await tester.tap(toggleIcon);
      await tester.pump();
      tf = tester.widget<TextField>(passwordFieldFinder);
      expect(tf.obscureText, isFalse);
    }

    // Empty submit shows error (message might be SnackBar / inline)
    await tester.tap(find.text('Login'));
    await tester.pump();

    // Prefer exact message if you have it, else accept any "Please..." validation
    final hasExact =
        find.textContaining('Please fill in all fields').evaluate().isNotEmpty;
    final hasGeneric = find.textContaining('Please').evaluate().isNotEmpty;

    expect(hasExact || hasGeneric, isTrue);
  });
}
