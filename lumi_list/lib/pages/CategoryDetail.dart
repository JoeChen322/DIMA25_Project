// CategoryDetailPage.dart
import 'package:flutter/material.dart';
import 'movieCatergory.dart';
import 'movie_detail.dart'; 
class CategoryDetailPage extends StatelessWidget {
  final String category;
  const CategoryDetailPage({super.key, required this.category});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, String>> movies = MovieCategoryData.categories[category] ?? [];

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text("$category Top 5", style: const TextStyle(color: Colors.white)),
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
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
                color: Colors.white.withOpacity(0.05),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.horizontal(left: Radius.circular(12)),
                    child: Image.network(
                      movie['poster']!,
                      width: 85, height: 120, fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Container(
                        width: 85, color: Colors.grey[850],
                        child: const Icon(Icons.broken_image, color: Colors.white24),
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
                            style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 5),
                          Text("${movie['year'] ?? 'Unknown Year'} - ${movie['director'] ?? 'NA'}", style: const TextStyle(color: Colors.amber, fontSize: 12)),
                        ],
                      ),
                    ),
                  ),
                  const Icon(Icons.chevron_right, color: Colors.white30),
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