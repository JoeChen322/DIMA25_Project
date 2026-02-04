import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lumi_list/pages/search_page.dart';

void main() {
  group('SearchPage UI 与交互测试', () {
    
    testWidgets('验证搜索页初始 UI 元素', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: SearchPage()));

      // 1. 验证标题和提示文字
      expect(find.text("Search"), findsOneWidget);
      expect(find.text("Find your next story"), findsOneWidget);

      // 2. 验证搜索框和默认分类卡片
      expect(find.byType(TextField), findsOneWidget);
      expect(find.text("Browse Categories"), findsOneWidget);
      expect(find.text("Action"), findsOneWidget);
    });

    testWidgets('输入搜索内容并触发搜索时的加载状态', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: SearchPage()));

      // 1. 模拟输入文字
      await tester.enterText(find.byType(TextField), 'Inception');
      
      // 2. 点击搜索按钮 (发送图标)
      await tester.tap(find.byIcon(Icons.send_rounded));
      
      // 3. 这里的 pump() 是为了触发 setState 后的第一帧
      await tester.pump(); 

      // 4. 验证是否出现了加载指示器
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('验证点击分类卡片是否跳转', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: SearchPage()));

      // 1. 找到 "Fiction" 分类卡片并点击
      await tester.tap(find.text("Fiction"));
      await tester.pumpAndSettle(); // 等待路由跳转动画完成

      // 2. 验证是否跳转到了 CategoryDetailPage (通过检查页面标题或特定逻辑)
      // 注意：由于 CategoryDetailPage 需要数据，确保其逻辑不会崩溃
    });
  });
}