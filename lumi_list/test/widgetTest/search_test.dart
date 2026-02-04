import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lumi_list/pages/search_page.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
void main() {
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;
  group('SearchPage widget', () {
    
    testWidgets('search page UI', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: SearchPage()));

      // 1. title & subtitle
      expect(find.text("Search"), findsOneWidget);
      expect(find.text("Find your next story"), findsOneWidget);

      // 2. search field
      expect(find.byType(TextField), findsOneWidget);
      expect(find.text("Browse Categories"), findsOneWidget);
      expect(find.text("Action"), findsOneWidget);
    });

      testWidgets('input and search', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: SearchPage()));

      await tester.enterText(find.byType(TextField), 'Inception');
      await tester.tap(find.byIcon(Icons.send_rounded));

      await tester.pump(); 
      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      await tester.pump(const Duration(seconds: 1)); 
    });
    testWidgets(' category selection', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: SearchPage()));

      
      await tester.tap(find.text("Fiction"));
      await tester.pumpAndSettle(); // 等待路由跳转动画完成

    });
  });
}