import 'package:flutter/material.dart';
import 'route.dart';

class LumiListApp extends StatelessWidget {
  const LumiListApp({super.key});

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
      initialRoute: '/splash',
      routes: appRoutes,

  
    );
  }
}
