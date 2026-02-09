import 'package:flutter/material.dart';
import '../database/seelater.dart';
import 'movie_detail.dart';

class SeeLaterPage extends StatelessWidget {
  const SeeLaterPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text(
          "Watch Later",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: SeeLaterDao.streamSeeLater(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final movies = snapshot.data ?? [];
          if (movies.isEmpty) {
            return const Center(
              child: Text("Your list is empty",
                  style: TextStyle(color: Colors.grey)),
            );
          }

          return ListView.builder(
            itemCount: movies.length,
            itemBuilder: (context, index) {
              final movie = movies[index];
              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(12),
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
                      errorBuilder: (context, e, s) =>
                          Container(width: 60, height: 90, color: Colors.grey),
                    ),
                  ),
                  title: Text(
                    movie['title'] ?? "Unknown",
                    style: const TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                  trailing: const Icon(Icons.arrow_forward_ios,
                      color: Colors.white24, size: 16),
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
