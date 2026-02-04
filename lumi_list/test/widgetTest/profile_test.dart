import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:lumi_list/pages/profile_page.dart';
import 'package:lumi_list/database/app_database.dart';

void main() {
  // 初始化数据库驱动
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;

  testWidgets('Profile loading Widget', (WidgetTester tester) async {
  
  await tester.pumpWidget(MaterialApp(
    onGenerateRoute: (settings) {
      return MaterialPageRoute(
        settings: const RouteSettings(
          arguments: {'email': 'test@example.com'} 
        ),
        builder: (context) => const ProfilePage(),
      );
    },
    home: Builder(builder: (context) => ElevatedButton(
      onPressed: () => Navigator.pushNamed(context, '/profile'),
      child: const Text('Go'),
    )),
  ));


  await tester.tap(find.text('Go'));
  await tester.pump(); 
  final progressFinder = find.byType(CircularProgressIndicator);
  if (progressFinder.evaluate().isNotEmpty) {
     expect(progressFinder, findsOneWidget);
  }
  await tester.pump(const Duration(seconds: 3));
  expect(find.byType(CircularProgressIndicator), findsNothing);
  expect(find.text("Profile"), findsOneWidget);
});
}