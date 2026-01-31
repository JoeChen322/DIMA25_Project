import 'package:flutter/material.dart';
import 'dart:ui'; // 用于毛玻璃效果

class MyListPage extends StatelessWidget {
  const MyListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // 1. 背景换成与 Search 页面一致的深黑色
      backgroundColor: const Color(0xFF0F0F0F), 
      body: Stack(
        children: [
          // 2. 顶部紫色光晕装饰，呼应 Search 页面
          Positioned(
            top: -50,
            left: -50,
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.deepPurple.withOpacity(0.1),
              ),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 50, sigmaY: 50),
                child: Container(color: Colors.transparent),
              ),
            ),
          ),
          
          SafeArea(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 3. 页面标题
                  const Padding(
                    padding: EdgeInsets.fromLTRB(20, 20, 20, 10),
                    child: Text(
                      "ME",
                      style: TextStyle(
                        color: Colors.white, 
                        fontSize: 34, 
                        fontWeight: FontWeight.bold,
                        letterSpacing: -1,
                      ),
                    ),
                  ),
                  
                  const Padding(
                    padding: EdgeInsets.fromLTRB(20, 10, 20, 20),
                    child: Text(
                      "My Movie Lists",
                      style: TextStyle(
                        color: Colors.grey, 
                        fontSize: 18, 
                        fontWeight: FontWeight.w500
                      ),
                    ),
                  ),
                  
                  // 4. 功能入口网格
                  GridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: 2,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    mainAxisSpacing: 16,
                    crossAxisSpacing: 16,
                    childAspectRatio: 1.3,
                    children: [
                      _buildDarkItem(context, Colors.amber, "Favorites", Icons.star_rounded),
                      _buildDarkItem(context, Colors.redAccent, "Watch Later", Icons.access_time_filled_rounded),
                      _buildDarkItem(context, Colors.blueAccent, "Classics", Icons.movie_filter_rounded),
                      _buildDarkItem(context, Colors.purpleAccent, "Custom List", Icons.add_rounded),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // 5. 适配深色模式的卡片组件
  Widget _buildDarkItem(BuildContext context, Color color, String title, IconData icon) {
    return Container(
      decoration: BoxDecoration(
        // 使用半透明深灰，营造悬浮感
        color: Colors.white.withOpacity(0.05), 
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.08)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.15), 
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 32),
          ),
          const SizedBox(height: 12),
          Text(
            title,
            style: const TextStyle(
              color: Colors.white, 
              fontSize: 15, 
              fontWeight: FontWeight.w600
            ),
          ),
        ],
      ),
    );
  }
}