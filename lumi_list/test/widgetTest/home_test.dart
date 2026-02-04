import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lumi_list/pages/home_page.dart';
import 'package:lumi_list/pages/movie_detail.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;
  group('Home Page Bar Test', () {
    
    // --- bar---
   testWidgets('Home bar switch', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(
        home: HomePage(),
      ));
      //defau lt is Home
      expect(find.textContaining("LumiList"), findsOneWidget);
      //change to Search
      await tester.tap(find.text("Search")); 
      await tester.pump(); 
      expect(find.textContaining("Find your next story"), findsOneWidget);
    //change to Me
      await tester.tap(find.text("Me"));
      await tester.pump(); 
      await tester.pump(const Duration(seconds: 1));
      expect(find.textContaining("List"), findsOneWidget);
});

    
  });
}