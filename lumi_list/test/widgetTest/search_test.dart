import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lumi_list/pages/search_page.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;

  group('SearchPage 深度兼容测试', () {
    
    Future<void> loadSearchPage(WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          onGenerateRoute: (settings) {
            if (settings.name == '/search') {
              return MaterialPageRoute(
                builder: (context) => const SearchPage(),
                settings: const RouteSettings(arguments: {'email': 'test@example.com'}),
              );
            }
            return null;
          },
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () => Navigator.pushNamed(context, '/search'),
                child: const Text('Go'),
              ),
            ),
          ),
        ),
      );

      // 点击按钮跳转
      await tester.tap(find.text('Go'));
      // pumpAndSettle 会等待跳转动画结束
      await tester.pumpAndSettle();
    }

    testWidgets('验证搜索页面 UI (修复登录异常)', (WidgetTester tester) async {
      await loadSearchPage(tester);

      // 现在应该能看到 SearchPage 的内容而不会报错了
      expect(find.text("Search"), findsOneWidget);
      expect(find.byType(TextField), findsOneWidget);
    });

    testWidgets('模拟搜索输入动作', (WidgetTester tester) async {
      await loadSearchPage(tester);

      // 输入内容并搜索
      await tester.enterText(find.byType(TextField), 'Inception');
      await tester.tap(find.byIcon(Icons.send_rounded));

      // 触发加载状态
      await tester.pump(); 
      
      // 检查加载圈（即使请求 400 失败，UI 也会先显示加载）
      expect(find.byType(CircularProgressIndicator), findsWidgets);

      // 手动消耗掉残留的异步请求，防止 Timer 报错
      await tester.pump(const Duration(seconds: 1));
    });

    testWidgets('验证分类标签', (WidgetTester tester) async {
      await loadSearchPage(tester);

      // 验证静态分类文字
      expect(find.text("Browse Categories"), findsOneWidget);
      expect(find.text("Action"), findsOneWidget);
      expect(find.text("Comedy"), findsOneWidget);
    });
  });
}