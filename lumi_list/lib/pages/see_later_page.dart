import 'package:flutter/material.dart';
import '../database/seelater.dart';
import 'movie_detail.dart';

class SeeLaterPage extends StatefulWidget {
  const SeeLaterPage({super.key});

  @override
  State<SeeLaterPage> createState() => _SeeLaterPageState();
}

class _SeeLaterPageState extends State<SeeLaterPage> {
  // 1. 保留 HEAD 分支引入的同步状态
  bool _isSyncing = false;

  // 模拟同步逻辑
  Future<void> _handleSync() async {
    setState(() => _isSyncing = true);
    // 这里放置你的云端同步逻辑
    await Future.delayed(const Duration(seconds: 1));
    if (mounted) setState(() => _isSyncing = false);
  }

  @override
  Widget build(BuildContext context) {
    // 2. 采用 HEAD 分支的动态主题配色逻辑
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        title: Text(
          "Watch Later",
          style: TextStyle(color: colorScheme.onSurface, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: colorScheme.onSurface),
          onPressed: () => Navigator.pop(context),
        ),
        // 3. 整合 HEAD 分支的同步按钮 Actions
        actions: [
          _isSyncing
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
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
      // 4. 采用 af1cd3 分支的 StreamBuilder 实现自动刷新
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: SeeLaterDao.streamSeeLater(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator(color: colorScheme.primary));
          }

          final movies = snapshot.data ?? [];
          if (movies.isEmpty) {
            return Center(
              child: Text(
                "Your list is empty",
                style: TextStyle(color: colorScheme.onSurfaceVariant),
              ),
            );
          }

          return ListView.builder(
            itemCount: movies.length,
            itemBuilder: (context, index) {
              final movie = movies[index];
              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: isDark ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.04),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: colorScheme.outlineVariant.withOpacity(0.5)),
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(8),
                  leading: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      movie['poster'] ?? "",
                      width: 60,
                      height: 90,
                      fit: BoxFit.cover,
                      // 采用 HEAD 分支更友好的错误占位
                      errorBuilder: (context, e, s) => Container(
                        width: 60,
                        height: 90,
                        color: colorScheme.surfaceContainerHighest,
                        child: Icon(Icons.broken_image, color: colorScheme.onSurfaceVariant),
                      ),
                    ),
                  ),
                  title: Text(
                    movie['title'] ?? "Unknown",
                    style: TextStyle(color: colorScheme.onSurface, fontWeight: FontWeight.bold),
                  ),
                  // 5. 保留 HEAD 分支特有的 subtitle (显示年份)
                  subtitle: movie['year'] != null 
                      ? Text(
                          movie['year'],
                          style: TextStyle(color: colorScheme.onSurfaceVariant, fontSize: 13),
                        )
                      : null,
                      //add the delete button
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                        onPressed: () async {
                          await SeeLaterDao.deleteSeeLater(movie['imdb_id']);
                          // use StreamBuilder，aumotically update the list after deletion
                        },
                      ),
                    ],
                  ),  
                  onTap: () {
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