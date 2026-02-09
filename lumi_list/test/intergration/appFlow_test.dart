import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:lumi_list/app.dart';
import 'package:lumi_list/pages/login_page.dart';
import 'package:lumi_list/pages/home_page.dart';
import 'package:lumi_list/pages/profile_page.dart';
import 'package:lumi_list/pages/signup_page.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Intergration test', () {
    
    testWidgets('full processing: start -> sign up -> login -> home page -> change bar', 
        (WidgetTester tester) async {
      
    
      await tester.pumpWidget(const LumiListApp(initialRoute: '/login'));
      await tester.pumpAndSettle();

      // login page
      expect(find.byType(LoginPage), findsOneWidget);

      //sinup page
      final signupButton = find.text('Sign Up'); 
      if (signupButton.evaluate().isNotEmpty) {
        await tester.tap(signupButton);
        await tester.pumpAndSettle();
        expect(find.byType(SignupPage), findsOneWidget);
        
        // back to login page
        await tester.pageBack();
        await tester.pumpAndSettle();
      }

      // fill in login form
      final emailField = find.byType(TextField).at(0);
      final passwordField = find.byType(TextField).at(1);
      
      await tester.enterText(emailField, 'test@example.com');
      await tester.enterText(passwordField, 'password123');
      //await tester.closeSoftKeyboard();
      
      // press login button
      final loginBtn = find.byType(ElevatedButton).first;
      await tester.tap(loginBtn);
      await tester.pumpAndSettle(const Duration(seconds: 1));

      // change bottom navigation bar
      final profileTab = find.byIcon(Icons.person);
      if (profileTab.evaluate().isNotEmpty) {
        await tester.tap(profileTab);
        await tester.pumpAndSettle();
        expect(find.byType(ProfilePage), findsOneWidget);
      }

      // back to home page
      final homeTab = find.byIcon(Icons.home);
      if (homeTab.evaluate().isNotEmpty) {
        await tester.tap(homeTab);
        await tester.pumpAndSettle();
        expect(find.byType(HomePage), findsOneWidget);
      }
    });

    testWidgets('Direct startup to home page test (simulate logged-in state)', (WidgetTester tester) async {
      
      await tester.pumpWidget(const LumiListApp(initialRoute: '/'));
      await tester.pumpAndSettle();

      expect(find.byType(HomePage), findsOneWidget);
    });
  });
}