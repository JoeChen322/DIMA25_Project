import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lumi_list/pages/home_page.dart';
import 'package:lumi_list/pages/movie_detail.dart';

void main() {
  group('LumiList 整合测试集', () {
    
    // --- 1. 首页导航与状态测试 ---
    testWidgets('首页底部导航栏应能正确切换页面', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: HomePage()));

      // 验证初始状态在 Home (index 1)
      expect(find.text("LumiList"), findsOneWidget);

      // 切换到 Search 页面 (index 0)
      await tester.tap(find.byIcon(Icons.search));
      await tester.pumpAndSettle();
      expect(find.text("Search"), findsOneWidget);
      expect(find.text("Find your next story"), findsOneWidget);

      // 切换到 Me 页面 (index 2)
      await tester.tap(find.byIcon(Icons.person));
      await tester.pumpAndSettle();
      // 验证 Me 页面是否显示（由于 Me 页面 AppBar 为空，可检查其特有内容）
    });

    // --- 2. 详情页 UI 健壮性测试 (解决 9.9 像素溢出) ---
    testWidgets('详情页在窄屏下不应出现布局溢出', (WidgetTester tester) async {
      // 模拟窄屏设备 (例如 iPhone SE 尺寸)
      tester.view.physicalSize = const Size(320, 800);
      tester.view.devicePixelRatio = 1.0;

      final mockMovie = {
        'Title': 'The Godfather Part II',
        'Year': '1974',
        'Poster': 'https://example.com/poster.jpg',
        'imdbID': 'tt0071562',
      };

      await tester.pumpWidget(MaterialApp(
        home: MovieDetailPage(movie: mockMovie),
      ));

      // 等待异步初始化完成
      await tester.pump(); 

      // 检查是否发生溢出错误
      // 如果使用了 Expanded 处理标题，并用 Wrap 处理了按钮，此处不应报错
      expect(tester.takeException(), isNull);

      // 验证核心组件是否渲染
      expect(find.textContaining('The Godfather Part II'), findsOneWidget);
      expect(find.text('Summary'), findsOneWidget);

      // 恢复尺寸设置
      addTearDown(tester.view.resetPhysicalSize);
    });

    
  });
}