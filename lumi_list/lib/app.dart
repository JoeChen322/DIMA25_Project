import 'package:flutter/material.dart';
import 'route.dart';

class LumiListApp extends StatelessWidget {
  final String initialRoute; // 定义参数

  const LumiListApp({super.key, required this.initialRoute}); // 构造函数接收

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'LumiList',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      
      // 使用传进来的初始路由，覆盖掉原本硬编码的 '/splash'
      initialRoute: initialRoute, 
      routes: appRoutes,
    );
  }
}