import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lumi_list/pages/home_page.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;

  testWidgets('HomePage test', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(360, 800);
    tester.view.devicePixelRatio = 1.0;

    // mock HomePage with email argument
    await tester.pumpWidget(
      MaterialApp(
        onGenerateRoute: (settings) {
          return MaterialPageRoute(
            builder: (context) => const HomePage(),
            settings: const RouteSettings(arguments: {'email': 'test@example.com'}),
          );
        },
      ),
    );

    
    expect(find.byType(BottomNavigationBar), findsOneWidget);

    //change to profile page
    await tester.tap(find.byIcon(Icons.person));
    await tester.pump(); 

    // Verify that we are on the profile page by checking for a unique widget
    expect(find.byType(BottomNavigationBar), findsOneWidget);
    await tester.pump(const Duration(seconds: 1));
    
    tester.view.resetPhysicalSize();
  });
}