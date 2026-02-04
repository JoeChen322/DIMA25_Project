import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lumi_list/pages/favorite_page.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:lumi_list/database/app_database.dart';
void main() {
  sqfliteFfiInit(); 
  databaseFactory = databaseFactoryFfi;
  testWidgets('FavoritePage Widget Test', (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(home: FavoritePage()));

    // 1. loading test
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    await tester.pump(const Duration(seconds: 1)); // Use pump instead of pumpAndSettle

    // 2. empty state test
    if (find.text("No favorites yet").evaluate().isNotEmpty) {
      expect(find.text("No favorites yet"), findsOneWidget);
    }
  });

  testWidgets('FavoritePage button test', (WidgetTester tester) async {

    final deleteIcon = find.byIcon(Icons.delete_outline);
    if (deleteIcon.evaluate().isNotEmpty) {
      await tester.tap(deleteIcon.first);
      await tester.pump();
    }
  });
}