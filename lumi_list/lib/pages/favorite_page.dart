import 'package:flutter/material.dart';
import '../database/favorite.dart';
import 'movie_detail.dart';

class FavoritePage extends StatelessWidget {
  const FavoritePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F0F0F),
      appBar: AppBar(
        title: const Text(
          "My Favorite List",
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: Colors.transparent,
      ),
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: FavoriteDao.streamAllFavorites(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final movies = snapshot.data ?? [];
          if (movies.isEmpty) {
            return const Center(
              child: Text("No favorites yet",
                  style: TextStyle(color: Colors.grey)),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: movies.length,
            itemBuilder: (context, index) =>
                _FavoriteItem(movie: movies[index]),
          );
        },
      ),
    );
  }
}

class _FavoriteItem extends StatelessWidget {
  final Map<String, dynamic> movie;
  const _FavoriteItem({required this.movie});

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
          color: Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                movie["poster"] ?? "",
                width: 60,
                height: 90,
                fit: BoxFit.cover,
                errorBuilder: (c, e, s) =>
                    Container(width: 60, height: 90, color: Colors.grey),
              ),
            ),
            const SizedBox(width: 15),
            Expanded(
              child: Text(
                movie["title"] ?? "Unknown",
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
              onPressed: () async {
                await FavoriteDao.deleteFavorite(movie["imdb_id"]);
              },
            ),
          ],
        ),
      ),
    );
  }
}
