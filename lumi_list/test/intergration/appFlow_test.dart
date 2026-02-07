import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lumi_list/app.dart';
import 'package:lumi_list/pages/home_page.dart';
import 'package:lumi_list/pages/profile_page.dart';
import 'package:lumi_list/pages/splash_page.dart';
import 'package:lumi_list/pages/login_page.dart';
import 'package:lumi_list/pages/search_page.dart';

void main() {
  group('LumiList Integration Tests', () {
    // ✅ 测试应用启动
    testWidgets('App initializes and shows splash screen', 
        (WidgetTester tester) async {
      await tester.pumpWidget(const LumiListApp());

      // 验证启动页
      expect(find.byType(SplashPage), findsOneWidget);
    });

    // ✅ 测试完整的用户流程
    testWidgets('User can login, search movie, and add to favorites', 
        (WidgetTester tester) async {
      await tester.pumpWidget(const LumiListApp());

      // 等待启动页加载
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // 1. 导航到登录页
      await tester.tap(find.text('Login'));
      await tester.pumpAndSettle();

      // 2. 输入登录信息
      await tester.enterText(
        find.byType(TextField).first,
        'test@example.com',
      );
      await tester.enterText(
        find.byType(TextField).last,
        'password123',
      );

      // 3. 点击登录
      await tester.tap(find.byType(ElevatedButton));
      await tester.pumpAndSettle();

      // 4. 导航到搜索
      await tester.tap(find.byIcon(Icons.search));
      await tester.pumpAndSettle();

      // 5. 搜索电影
      await tester.enterText(
        find.byType(TextField),
        'Inception',
      );
      await tester.pumpAndSettle();

      // 6. 点击搜索结果
      await tester.tap(find.text('Inception'));
      await tester.pumpAndSettle();

      // 7. 添加到收藏
      await tester.tap(find.byIcon(Icons.favorite_border));
      await tester.pumpAndSettle();

      // 验证已添加到收藏
      expect(find.byIcon(Icons.favorite), findsOneWidget);
    });

    // ✅ 测试路由导航
    testWidgets('Navigation between pages works correctly', 
        (WidgetTester tester) async {
      await tester.pumpWidget(const LumiListApp());
      await tester.pumpAndSettle();

      // 测试多个路由
      await tester.tap(find.byIcon(Icons.home));
      await tester.pumpAndSettle();
      expect(find.byType(HomePage), findsOneWidget);

      await tester.tap(find.byIcon(Icons.person));
      await tester.pumpAndSettle();
      expect(find.byType(ProfilePage), findsOneWidget);
    });
  });
}