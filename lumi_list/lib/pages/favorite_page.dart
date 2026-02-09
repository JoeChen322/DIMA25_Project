import 'package:flutter/material.dart';
import '../database/favorite.dart';
import 'movie_detail.dart';

class FavoritePage extends StatefulWidget {
  const FavoritePage({super.key});

  @override
  State<FavoritePage> createState() => _FavoritePageState();
}

class _FavoritePageState extends State<FavoritePage> {
  // 保留 HEAD 中的同步状态变量
  bool _isSyncing = false;

  // 模拟同步处理逻辑
  Future<void> _handleSync() async {
    setState(() => _isSyncing = true);
    // 这里执行你的同步逻辑，例如从服务器拉取最新收藏
    await Future.delayed(const Duration(seconds: 1)); 
    if (mounted) setState(() => _isSyncing = false);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        title: Text(
          "My Favorite List",
          style: TextStyle(fontWeight: FontWeight.bold, color: colorScheme.onSurface),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          // 保留 HEAD 中的同步按钮功能
          _isSyncing
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: colorScheme.primary,
                      ),
                    ),
                  ),
                )
              : IconButton(
                  icon: Icon(Icons.sync, color: colorScheme.onSurface),
                  onPressed: _handleSync,
                ),
        ],
      ),
      // 采用远程分支的 StreamBuilder，实现数据自动刷新
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: FavoriteDao.streamAllFavorites(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final movies = snapshot.data ?? [];
          if (movies.isEmpty) {
            return Center(
              child: Text(
                "No favorites yet",
                style: TextStyle(color: colorScheme.onSurfaceVariant),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: movies.length,
            itemBuilder: (context, index) {
              return _FavoriteItem(
                movie: movies[index],
                colorScheme: colorScheme,
                isDark: isDark,
              );
            },
          );
        },
      ),
    );
  }
}

// 将 Item 提取为独立组件，并保留 HEAD 的精致样式
class _FavoriteItem extends StatelessWidget {
  final Map<String, dynamic> movie;
  final ColorScheme colorScheme;
  final bool isDark;

  const _FavoriteItem({
    required this.movie,
    required this.colorScheme,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => MovieDetailPage(movie: {
              "Title": movie["title"],
              "Poster": movie["poster"],
              "imdbID": movie["imdb_id"],
            }),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isDark ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.04),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: colorScheme.outlineVariant.withOpacity(0.5)),
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                movie["poster"],
                width: 60,
                height: 90,
                fit: BoxFit.cover,
                errorBuilder: (c, e, s) => Container(
                  width: 60,
                  height: 90,
                  color: colorScheme.onSurfaceVariant,
                  child: const Icon(Icons.broken_image, color: Colors.white),
                ),
              ),
            ),
            const SizedBox(width: 15),
            Expanded(
              child: Text(
                movie["title"],
                style: TextStyle(
                  color: colorScheme.onSurface,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
              onPressed: () async {
                await FavoriteDao.deleteFavorite(movie["imdb_id"]);
                // 由于使用了 StreamBuilder，删除后列表会自动更新
              },
            ),
          ],
        ),
      ),
    );
  }
}