import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:lumi_list/app.dart';
import 'package:lumi_list/pages/login_page.dart';
import 'package:lumi_list/pages/signup_page.dart';
import 'package:lumi_list/pages/home_page.dart';
import 'package:lumi_list/pages/me_page.dart'; // contains MyListPage

Future<void> _pumpUntilFound(
  WidgetTester tester,
  Finder finder, {
  Duration timeout = const Duration(seconds: 25),
  Duration step = const Duration(milliseconds: 200),
}) async {
  final end = DateTime.now().add(timeout);
  while (DateTime.now().isBefore(end)) {
    await tester.pump(step);
    if (finder.evaluate().isNotEmpty) return;
  }
  throw TestFailure('Timed out waiting for: $finder');
}

Future<void> _restartApp(WidgetTester tester) async {
  await tester.pumpWidget(const SizedBox.shrink());
  await tester.pump(const Duration(milliseconds: 100));
  await tester.pumpWidget(const LumiListApp(initialRoute: '/'));
  await tester.pump(const Duration(seconds: 1));
}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    // Needed because we pump the widget directly (we are not running app main()).
    WidgetsFlutterBinding.ensureInitialized();
    await Firebase.initializeApp();
  });

  testWidgets(
    'signup -> home -> me -> home -> logout -> login -> home',
    (WidgetTester tester) async {
      // Keep UI in portrait so BottomNavigationBar exists (not NavigationRail).
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      // Start clean
      await FirebaseAuth.instance.signOut();

      // Create a unique account each run (no need to pre-register)
      final email = 'it_${DateTime.now().millisecondsSinceEpoch}@example.com';
      final password = 'Password123!';

      // --- Launch app (goes to AuthGate -> LoginPage when signed out) ---
      await tester.pumpWidget(const LumiListApp(initialRoute: '/'));
      await tester.pump(const Duration(seconds: 1));

      // --- Go to signup ---
      await _pumpUntilFound(tester, find.byType(LoginPage));
      await tester.tap(find.byKey(LoginPage.kToSignupButton));
      await tester.pump();

      await _pumpUntilFound(tester, find.byType(SignupPage));

      // --- Fill signup form using keys ---
      await tester.enterText(find.byKey(SignupPage.kEmailField), email);
      await tester.enterText(find.byKey(SignupPage.kPasswordField), password);
      await tester.enterText(find.byKey(SignupPage.kConfirmField), password);

      await tester.tap(find.byKey(SignupPage.kSubmitButton));
      await tester.pump();

      // Signup creates user and navigates to '/' -> AuthGate -> HomePage
      await _pumpUntilFound(tester, find.byType(HomePage),
          timeout: const Duration(seconds: 40));

      // --- Navigate to Me tab ---
      await tester.tap(find.byKey(HomePage.kTabMe));
      await tester.pump();

      await _pumpUntilFound(tester, find.byType(MyListPage),
          timeout: const Duration(seconds: 25));

      // --- Back to Home tab ---
      await tester.tap(find.byKey(HomePage.kTabHome));
      await tester.pump();

      await _pumpUntilFound(tester, find.byType(HomePage));

      // --- Logout (direct Firebase sign out) ---
      await FirebaseAuth.instance.signOut();

      // Restart widget tree so AuthGate rebuilds cleanly
      await _restartApp(tester);

      // --- Login with the same new account ---
      await _pumpUntilFound(tester, find.byType(LoginPage));

      await tester.enterText(find.byKey(LoginPage.kEmailField), email);
      await tester.enterText(find.byKey(LoginPage.kPasswordField), password);

      await tester.tap(find.byKey(LoginPage.kLoginButton));
      await tester.pump();

      await _pumpUntilFound(tester, find.byType(HomePage),
          timeout: const Duration(seconds: 40));
    },
  );
}
