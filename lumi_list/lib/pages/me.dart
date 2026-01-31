import 'package:flutter/material.dart';

class MyListPage extends StatelessWidget {
  const MyListPage({super.key});

  @override
Widget build(BuildContext context) {
  return Scaffold(
    backgroundColor: const Color(0xFFF5F5F5),
    // 方案：重新启用标准 AppBar，但高度调低
    appBar: AppBar(
      title: const Text(
        "ME",
        style: TextStyle(
          color: Colors.black, 
          fontWeight: FontWeight.bold, 
          fontSize: 18
        ),
      ),
      centerTitle: true,
      backgroundColor: Colors.white,
      elevation: 0,
      // 关键点：手动把这个高度调低（默认是 56）
      // 44-48 左右在全面屏手机上最协调
      toolbarHeight: 48, 
      automaticallyImplyLeading: false,
    ),
    body: SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            // 这里顶部的 20 改成 16，会让“My Movie Lists”贴得更紧凑一点
            padding: EdgeInsets.fromLTRB(16, 16, 16, 10),
            child: Text(
              "My Movie Lists",
              style: TextStyle(
                color: Colors.black87, 
                fontSize: 18, 
                fontWeight: FontWeight.bold
              ),
            ),
          ),
          
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 1.4,
            children: [
              _buildListItem(context, Colors.amber, "Favorites", Icons.star, 
                  onTap: () => Navigator.pushNamed(context, '/favorite')),
              _buildListItem(context, Colors.redAccent, "Watch Later", Icons.access_time),
              _buildListItem(context, Colors.blueAccent, "Classics", Icons.movie_filter),
              _buildListItem(context, Colors.purple, "Custom List", Icons.add),
            ],
          ),
        ],
      ),
    ),
  );
}

  // 这里的组件设计参考了 profile_page.dart 的 _buildListItem 实现
  Widget _buildListItem(BuildContext context, Color color, String title, IconData icon, {VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white, 
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
             BoxShadow(
               color: Colors.black.withOpacity(0.05), 
               blurRadius: 10, 
               offset: const Offset(0, 4)
             ),
          ]
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1), 
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 30),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: const TextStyle(
                color: Colors.black87, 
                fontSize: 14, 
                fontWeight: FontWeight.w600
              ),
            ),
          ],
        ),
      ),
    );
  }
}