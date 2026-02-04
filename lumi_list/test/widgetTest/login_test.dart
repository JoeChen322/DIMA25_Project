import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lumi_list/pages/login_page.dart';

void main() {
  testWidgets('Login Widget Test', (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(home: LoginPage()));

    
    expect(find.text('Welcome Back'), findsOneWidget);
    expect(find.widgetWithText(ElevatedButton, 'Login'), findsOneWidget);

    // psw visibility toggle test
    final passwordField = find.byType(TextField).last;
    
    TextField textField = tester.widget<TextField>(passwordField);
    expect(textField.obscureText, isTrue);

    //change visibility
    await tester.tap(find.byIcon(Icons.visibility_off));
    await tester.pump();
    textField = tester.widget<TextField>(passwordField);
    expect(textField.obscureText, isFalse);

    // empty input test
    await tester.tap(find.text('Login'));
    await tester.pump();
    expect(find.textContaining('Please fill in all fields'), findsOneWidget);
  });
}