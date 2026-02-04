import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lumi_list/pages/login_page.dart';

void main() {
  testWidgets('登录页面 UI 元素及密码切换测试', (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(home: LoginPage()));

    // 1. 验证关键元素是否存在
    expect(find.text('Welcome Back'), findsOneWidget);
    expect(find.widgetWithText(ElevatedButton, 'Login'), findsOneWidget);

    // 2. 测试密码可见性切换
    final passwordField = find.byType(TextField).last;
    // 初始状态应该是隐藏的 (obscureText: true)
    TextField textField = tester.widget<TextField>(passwordField);
    expect(textField.obscureText, isTrue);

    // 点击眼睛图标
    await tester.tap(find.byIcon(Icons.visibility_off));
    await tester.pump();

    // 验证切换为可见
    textField = tester.widget<TextField>(passwordField);
    expect(textField.obscureText, isFalse);

    // 3. 验证空点击时的提示
    await tester.tap(find.text('Login'));
    await tester.pump();
    expect(find.text('Please fill in all fields'), findsOneWidget);
  });
}