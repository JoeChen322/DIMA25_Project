import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lumi_list/pages/home_page.dart';

void main() {
  testWidgets('HomePage shows BottomNavigationBar in portrait',
      (WidgetTester tester) async {
    // Portrait
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    // Start on "Me" tab to avoid HomeContent TMDb network call
    await tester.pumpWidget(const MaterialApp(home: HomePage(initialIndex: 2)));
    await tester.pump();

    expect(find.byKey(HomePage.kBottomNav), findsOneWidget);
    expect(find.byKey(HomePage.kNavRail), findsNothing);
  });

  testWidgets('HomePage shows NavigationRail in landscape',
      (WidgetTester tester) async {
    // Landscape
    tester.view.physicalSize = const Size(844, 390);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    // Start on "Me" tab to avoid HomeContent TMDb network call
    await tester.pumpWidget(const MaterialApp(home: HomePage(initialIndex: 2)));
    await tester.pump();

    expect(find.byKey(HomePage.kNavRail), findsOneWidget);
    expect(find.byKey(HomePage.kBottomNav), findsNothing);
  });
}
