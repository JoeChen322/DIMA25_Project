import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lumi_list/pages/movie_detail.dart';

void main() {
  testWidgets('检查详情页按钮行在窄屏下是否溢出', (WidgetTester tester) async {
    // 1. 设置一个较窄的模拟屏幕尺寸（例如 320 像素宽）
    tester.view.physicalSize = const Size(320, 800);
    tester.view.devicePixelRatio = 1.0;

    // 2. 准备模拟数据
    final mockMovie = {
      'Title': 'Inception',
      'Poster': 'https://example.com/poster.jpg',
      'imdbID': 'tt1375666',
    };

    // 3. 渲染组件
    await tester.pumpWidget(MaterialApp(
      home: MovieDetailPage(movie: mockMovie),
    ));

    // 4. 验证是否有溢出错误
    // 如果你在代码中使用了 Row 且没有处理溢出，测试运行到这里会直接失败
    expect(tester.takeException(), isNull); 

    // 5. 验证特定的按钮是否可见
    expect(find.text('See Later'), findsOneWidget);
    
    // 恢复屏幕尺寸
    addTearDown(tester.view.resetPhysicalSize);
  });
}