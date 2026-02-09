/*in ME/IMDB CLASSICS PAGE, change to use 
getTopRatedMovies from TMDB service to fetch top rated movies*/

import 'package:flutter/material.dart';
import '../services/tmdb_api.dart'; // TMDB 
import 'movie_detail.dart';

class ClassicsPage extends StatefulWidget {
  const ClassicsPage({super.key});

  @override
  State<ClassicsPage> createState() => _ClassicsPageState();
}

class _ClassicsPageState extends State<ClassicsPage> {
  final TmdbService _tmdbService = TmdbService(
      'eyJhbGciOiJIUzI1NiJ9.eyJhdWQiOiJlNWUxYTU5ODc0YzMwZDlmMWM2NTJlYjllZDQ4MmMzMyIsIm5iZiI6MTc2NjQzOTY0Mi40NTIsInN1YiI6IjY5NDliYWRhNTNhODI1Nzk1YzE1NTk5OCIsInNjb3BlcyI6WyJhcGlfcmVhZCJdLCJ2ZXJzaW9uIjoxfQ.V0Z-rlGFtBKfCUHFx3nNnqxVNoJ-T3YNVDF8URfMj4U');

  List<dynamic> _topMovies = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchClassics();
  }

  // ... 前面 import 部分保持不变 ...

  Future<void> _fetchClassics() async {
    try {
      // 👈 核心修改：并发请求前 3 页数据 (每页 20 条，3 页共 60 条)
      final results = await Future.wait([
        _tmdbService.getTopRatedMovies(page: 1),
        _tmdbService.getTopRatedMovies(page: 2),
        _tmdbService.getTopRatedMovies(page: 3),
      ]);

      // 将三页数据合并为一个 List
      List<dynamic> allMovies = results.expand((x) => x).toList();

      if (mounted) {
        setState(() {
          // 👈 核心修改：只取前 50 名
          _topMovies = allMovies.take(50).toList();
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint("fail: $e");
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        title: Text("IMDb Top 50", style: TextStyle(fontWeight: FontWeight.bold, color:colorScheme.onSurface)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              decoration: BoxDecoration(
                color: isDark ? Colors.white.withOpacity(0.15) : Colors.black.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.arrow_back_ios_new_rounded, color: colorScheme.onSurface, size: 18),
            ),
          ),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.deepPurpleAccent))
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              // 现在 _topMovies.length 就是 50 了
              itemCount: _topMovies.length,
              itemBuilder: (context, index) {
                final movie = _topMovies[index];
                return _buildMovieItem(movie, index + 1, colorScheme, isDark);
              },
            ),
    );
  }

  // _buildMovieItem 部分保持不变 ...

  Widget _buildMovieItem(dynamic movie, int rank, ColorScheme colorScheme, bool isDark) {
    return GestureDetector(
      onTap: () {
        final formattedMovie = {
          "Title": movie["title"] ?? "Unknown Title",
          "Year": (movie["release_date"] != null && movie["release_date"].toString().length >= 4)
              ? movie["release_date"].split('-')[0]
              : "N/A",
          "Poster": movie['poster_path'] != null 
              ? "https://image.tmdb.org/t/p/w500${movie['poster_path']}"
              : "https://via.placeholder.com/500x750?text=No+Poster",
          "Plot": movie["overview"] ?? "No plot description available.",
          "imdbRating": movie["vote_average"]?.toString() ?? "N/A",
          "imdbID": movie["id"].toString(), 
          "Type": "movie",
        };

        Navigator.push(
          context, 
          MaterialPageRoute(builder: (_) => MovieDetailPage(movie: formattedMovie))
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
            SizedBox(
              width: 40,
              child: Text(
                "#$rank", 
                style: const TextStyle(color: Colors.amber, fontWeight: FontWeight.bold, fontSize: 18)
              ),
            ),
            const SizedBox(width: 5),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                movie['poster_path'] != null 
                    ? "https://image.tmdb.org/t/p/w92${movie['poster_path']}"
                    : "https://via.placeholder.com/92x138?text=No+Image",
                width: 60,
                height: 90,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  width: 60, height: 90, color: colorScheme.surfaceContainerHighest, 
                  child: Icon(Icons.movie, color: colorScheme.onSurfaceVariant)
                ),
              ),
            ),
            const SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    movie["title"] ?? "Unknown", 
                    style: TextStyle(color: colorScheme.onSurface, fontSize: 16, fontWeight: FontWeight.bold), 
                    maxLines: 1, 
                    overflow: TextOverflow.ellipsis
                  ),
                  const SizedBox(height: 5),
                  Text(
                    (movie["release_date"] != null && movie["release_date"].toString().length >= 4)
                        ? movie["release_date"].split('-')[0]
                        : "N/A", 
                    style: TextStyle(color: colorScheme.onSurfaceVariant)
                  ),
                  const SizedBox(height: 5),
                  
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios, color: colorScheme.onSurfaceVariant.withOpacity(0.3), size: 16),
          ],
        ),
      ),
    );
  }
}