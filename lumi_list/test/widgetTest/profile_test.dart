import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:lumi_list/pages/profile_page.dart';

void main() {
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;

  testWidgets('Profile loading Widget', (WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(
      onGenerateRoute: (settings) {
        return MaterialPageRoute(
          settings: const RouteSettings(arguments: {'email': 'test@example.com'}),
          builder: (context) => const ProfilePage(),
        );
      },
      home: Builder(builder: (context) => ElevatedButton(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const ProfilePage(),
            settings: const RouteSettings(arguments: {'email': 'test@example.com'}),
          ),
        ),
        child: const Text('Go'),
      )),
    ));

    
    await tester.tap(find.text('Go'));
    await tester.pump(); 
    bool isLoading = true;
    for (int i = 0; i < 5; i++) {
      await tester.pump(const Duration(seconds: 1)); 
      if (find.byType(CircularProgressIndicator).evaluate().isEmpty) {
        isLoading = false;
        break;
      }
    }

    
    expect(find.byType(ProfilePage), findsOneWidget);
    
    
    expect(find.byType(Scaffold), findsOneWidget);
    
    if (!isLoading) {
      expect(find.textContaining('Profile'), findsWidgets);
    }
  });
}