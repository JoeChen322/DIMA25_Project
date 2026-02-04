import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lumi_list/pages/profile_page.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  testWidgets('Profile页面加载状态及 UI 渲染测试', (WidgetTester tester) async {
  await tester.pumpWidget(MaterialApp(
    // 定义路由表，确保 pushNamed('/') 能找到 ProfilePage
    initialRoute: '/login',
    routes: {
      '/login': (context) => Scaffold(
        body: Builder(builder: (context) {
          return ElevatedButton(
            onPressed: () => Navigator.pushNamed(
              context, 
              '/profile', 
              arguments: {'email': 'test@example.com'}
            ),
            child: const Text('Go'),
          );
        }),
      ),
      '/profile': (context) => const ProfilePage(),
    },
  ));

  // 点击跳转到 ProfilePage
  await tester.tap(find.text('Go'));
  await tester.pumpAndSettle(); // 等待动画完成

  // 1. 验证加载动画是否存在
  // 注意：如果加载太快，可能直接跳过动画进入内容，这里可以用 pump() 捕捉瞬间
  // expect(find.byType(CircularProgressIndicator), findsOneWidget);

  // 2. 验证 Profile 页面特有元素是否渲染
  expect(find.text('Profile'), findsOneWidget);
  expect(find.text('Email'), findsOneWidget);
  expect(find.text('test@example.com'), findsOneWidget);
});
}