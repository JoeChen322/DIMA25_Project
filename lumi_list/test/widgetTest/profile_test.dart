import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lumi_list/pages/profile_page.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:lumi_list/database/app_database.dart';
void main() {
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;

  testWidgets('Profile Widget Test', (WidgetTester tester) async {

  await tester.pumpWidget(MaterialApp(
    onGenerateRoute: (settings) => MaterialPageRoute(
      settings: const RouteSettings(arguments: {'email': 'test@example.com'}),
      builder: (_) => const ProfilePage(),
    ),
    home: Builder(builder: (context) => ElevatedButton(
      onPressed: () => Navigator.pushNamed(context, '/profile'),
      child: const Text('Go'),
    )),
  ));

  await tester.tap(find.text('Go'));
  
  await tester.pump();
  expect(find.byType(CircularProgressIndicator), findsOneWidget);

  //await tester.pump(const Duration(seconds: 1));
  await tester.pumpAndSettle();
  expect(find.text('test@example.com'), findsOneWidget);
  expect(find.byType(CircularProgressIndicator), findsNothing);
});
}