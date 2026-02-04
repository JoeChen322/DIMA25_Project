import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lumi_list/pages/signup_page.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:lumi_list/database/app_database.dart';

void main() {
  sqfliteFfiInit(); 
  databaseFactory = databaseFactoryFfi;
  testWidgets('Signup password test', (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(home: SignupPage()));

    final textFields = find.byType(TextField);
    await tester.enterText(textFields.at(0), 'test@test.com'); // Email
    await tester.enterText(textFields.at(1), 'password123');   // Password
    await tester.enterText(textFields.at(2), 'password456');   // Confirm Password
    final signUpButton = find.text('Sign Up');
    await tester.ensureVisible(signUpButton);
    await tester.tap(signUpButton);
    await tester.pump();

    expect(find.textContaining('Passwords do not match'), findsOneWidget);
  });
}