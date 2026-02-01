// lib/pages/see_later_page.dart

import 'package:flutter/material.dart';
import 'package:lumi_list/database/app_database.dart';
import 'movie_detail.dart';

class SeeLaterPage extends StatelessWidget {
  const SeeLaterPage({super.key});

  // 从数据库获取列表的方法
  Future<List<Map<String, dynamic>>> _getSeeLaterMovies() async {
    final db = await AppDatabase.database;
    return await db.query('see_later');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black, // 保持深色主题
      appBar: AppBar(
        title: const Text("Watch Later", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _getSeeLaterMovies(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Text("Your list is empty", style: TextStyle(color: Colors.grey)),
            );
          }

          final movies = snapshot.data!;

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: movies.length,
            itemBuilder: (context, index) {
              final movie = movies[index];
              return Card(
                color: Colors.white.withOpacity(0.08),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                margin: const EdgeInsets.only(bottom: 16),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(8),
                  leading: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      movie['poster'] ?? "",
                      width: 60,
                      fit: BoxFit.cover,
                      errorBuilder: (context, e, s) => Container(width: 60, color: Colors.grey),
                    ),
                  ),
                  title: Text(
                    movie['title'] ?? "Unknown",
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                  trailing: const Icon(Icons.arrow_forward_ios, color: Colors.white24, size: 16),
                  onTap: () {
                    // 跳转回详情页，注意需要构造 movie 对象
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => MovieDetailPage(movie: {
                          'imdbID': movie['imdb_id'],
                          'Title': movie['title'],
                          'Poster': movie['poster'],
                        }),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}