import 'package:flutter/material.dart';
import '../database/favorite.dart';
import 'movie_detail.dart';

class FavoritePage extends StatefulWidget {
  const FavoritePage({super.key});

  @override
  State<FavoritePage> createState() => _FavoritePageState();
}

class _FavoritePageState extends State<FavoritePage> {
  List<Map<String, dynamic>> _favoriteMovies = [];
  bool _isLoading = true;
  bool _isSyncing = false; // sysnc state

Future<void> _handleSync() async {
  setState(() => _isSyncing = true);
  try {
    await FavoriteDao.syncWithFirebase();
    await _refreshFavorites(); 
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Sync completed successfully!")),
    );
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Sync failed: $e")),
    );
  } finally {
    setState(() => _isSyncing = false);
  }
}


  @override
  void initState() {
    super.initState();
    _refreshFavorites();
  }

  // refresh favorite list from database
  Future<void> _refreshFavorites() async {
    final data = await FavoriteDao.getAllFavorites();
    setState(() {
      _favoriteMovies = data;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F0F0F),
      appBar: AppBar(
        title: const Text("My Favorite List", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        backgroundColor: Colors.transparent,
        actions: [
        _isSyncing 
          ? const Center(child: Padding(padding: EdgeInsets.all(16.0), child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))))
          : IconButton(
              icon: const Icon(Icons.sync, color: Colors.white),
              onPressed: _handleSync,
            ),
      ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _favoriteMovies.isEmpty
              ? const Center(child: Text("No favorites yet", style: TextStyle(color: Colors.grey)))
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _favoriteMovies.length,
                  itemBuilder: (context, index) {
                    final movie = _favoriteMovies[index];
                    return _buildFavoriteItem(movie);
                  },
                ),
    );
  }

  Widget _buildFavoriteItem(Map<String, dynamic> movie) {
    return GestureDetector(
      onTap: () async {
        // Navigate to movie detail page
        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => MovieDetailPage(movie: {
              "Title": movie["title"],
              "Poster": movie["poster"],
              "imdbID": movie["imdb_id"],
              // add more fields if needed
            }),
          ),
        );
        _refreshFavorites(); // Refresh favorites after returning
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
                movie["poster"],
                width: 60, height: 90, fit: BoxFit.cover,
                errorBuilder: (c, e, s) => Container(width: 60, height: 90, color: Colors.grey),
              ),
            ),
            const SizedBox(width: 15),
            Expanded(
              child: Text(
                movie["title"],
                style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
              onPressed: () async {
                await FavoriteDao.deleteFavorite(movie["imdb_id"]);
                _refreshFavorites();
              },
            )
          ],
        ),
      ),
    );
  }
}