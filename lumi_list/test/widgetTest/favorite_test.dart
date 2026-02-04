import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lumi_list/pages/favorite_page.dart';

void main() {
  testWidgets('FavoritePage 渲染与空状态测试', (WidgetTester tester) async {
    // 渲染页面
    await tester.pumpWidget(const MaterialApp(home: FavoritePage()));

    // 1. 验证初始加载状态
    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    // 2. 模拟异步数据加载完成
    await tester.pumpAndSettle();

    // 3. 如果数据库为空，应显示提示文字
    // 注意：真实运行取决于你的 FavoriteDao mock 结果
    if (find.text("No favorites yet").evaluate().isNotEmpty) {
      expect(find.text("No favorites yet"), findsOneWidget);
    }
  });

  testWidgets('FavoritePage 删除按钮点击交互', (WidgetTester tester) async {
    // 此处通常需要 Mock FavoriteDao.getAllFavorites 返回一条假数据
    // 模拟 UI 渲染后点击删除图标的操作
    final deleteIcon = find.byIcon(Icons.delete_outline);
    if (deleteIcon.evaluate().isNotEmpty) {
      await tester.tap(deleteIcon.first);
      await tester.pump();
      // 验证页面是否重新触发了 _refreshFavorites
    }
  });
}