// CategoryDetailPage.dart
import 'package:flutter/material.dart';
import 'movieCatergory.dart';
import 'movie_detail.dart'; 
class CategoryDetailPage extends StatelessWidget {
  final String category;
  const CategoryDetailPage({super.key, required this.category});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    final List<Map<String, String>> movies = MovieCategoryData.categories[category] ?? [];

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        title: Text("$category Top 5", style: TextStyle(color: colorScheme.onSurface)),
        backgroundColor: colorScheme.surface,
        iconTheme: IconThemeData(color: colorScheme.onSurface),
        elevation: 0,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        itemCount: movies.length,
        itemBuilder: (context, index) {
          final movie = movies[index];
          
          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => MovieDetailPage(movie: {    
                    "imdbID": movie['id'], 
                    "Title": movie['title'],
                    "Poster": movie['poster'],
                  }),
                ),
              );
            },
            child: Container(
              margin: const EdgeInsets.symmetric(vertical: 8),
              height: 120,
              decoration: BoxDecoration(
                color: isDark ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.05),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: colorScheme.outlineVariant.withOpacity(0.5)),
              ),
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.horizontal(left: Radius.circular(12)),
                    child: Image.network(
                      movie['poster']!,
                      width: 85, height: 120, fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Container(
                        width: 85, 
                        color: colorScheme.surfaceContainerHighest,
                        child: Icon(Icons.broken_image, color: colorScheme.onSurfaceVariant),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            movie['title']!,
                            style: TextStyle(color: colorScheme.onSurface, fontSize: 16, fontWeight: FontWeight.bold),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 5),
                          Text("${movie['year'] ?? 'Unknown Year'} - ${movie['director'] ?? 'NA'}", style: TextStyle(color: colorScheme.onSurfaceVariant, fontSize: 12)),
                        ],
                      ),
                    ),
                  ),
                  Icon(Icons.chevron_right, color: colorScheme.onSurfaceVariant.withOpacity(0.5)),
                  const SizedBox(width: 8),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}