import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lumi_list/pages/signup_page.dart';

void main() {
  testWidgets('注册页面密码一致性校验测试', (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(home: SignupPage()));

    // 1. 输入不一致的密码
    final textFields = find.byType(TextField);
    await tester.enterText(textFields.at(0), 'test@test.com'); // Email
    await tester.enterText(textFields.at(1), 'password123');   // Password
    await tester.enterText(textFields.at(2), 'password456');   // Confirm Password

    // 2. 点击注册
    await tester.tap(find.text('Sign Up'));
    await tester.pump();

    // 3. 验证错误提示
    expect(find.text('Passwords do not match'), findsOneWidget);
  });
}