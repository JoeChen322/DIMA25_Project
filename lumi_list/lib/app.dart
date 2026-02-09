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
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple,
        brightness: Brightness.light,
      ),
        useMaterial3: true,
      ),

      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple,
        brightness: Brightness.dark,
      ),
        useMaterial3: true,
      ),

      themeMode: ThemeMode.system,

      // Set initial route and define routes
      initialRoute: initialRoute, // 使用传入的参数
      routes: appRoutes,
    );
  }
}