import 'dart:async';
import 'package:flutter/material.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  @override
  void initState() {
    super.initState();
    // 倒计时 2 秒，然后跳转
    Timer(const Duration(seconds: 2), () {
      // 跳转到登录页，并销毁当前页（用户按返回键回不到启动页）
      Navigator.pushReplacementNamed(context, '/login');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // 这里的 Scaffold 不需要 AppBar，全屏显示
      body: Container(
        width: double.infinity,
        height: double.infinity,
        // 统一的深紫色渐变背景
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Colors.black, Color(0xFF1A1A1A)], // 深紫色渐变
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // 1. 大 Logo
            //启动页：改用新的透明图片
            // lib/pages/splash_page.dart

            Container(
              padding: const EdgeInsets.all(24),
              decoration: const BoxDecoration( //这里加上 const
                // 🔥 修改这里：把原来的半透明白色改成纯黑色
                color: Colors.black, 
                shape: BoxShape.circle,
              ),
              child: Image.asset(
                'assets/icon/icon.png', // 使用你现在的黑底图片
                width: 90, 
                height: 90,
                fit: BoxFit.contain,
              ),
            ),
            
            const SizedBox(height: 30),
            
            // 2. App 名称
            const Text(
              "LumiList",
              style: TextStyle(
                fontSize: 42,
                fontWeight: FontWeight.w900,
                color: Colors.white,
                letterSpacing: 3, // 字间距大一点更高级
              ),
            ),
            
            const SizedBox(height: 10),
            
            // 3. Slogan (口号)
            Text(
              "Your Movie Collection",
              style: TextStyle(
                fontSize: 16,
                color: Colors.white.withOpacity(0.7),
                letterSpacing: 1,
              ),
            ),

            const SizedBox(height: 80),

            // 4. 底部小转圈 (表示正在加载)
            const CircularProgressIndicator(
              color: Colors.white,
              strokeWidth: 3,
            ),
          ],
        ),
      ),
    );
  }
}