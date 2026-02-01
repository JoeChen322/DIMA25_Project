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

  Future<void> _fetchClassics() async {
    try {
      // use getTopRatedMovies to fetch top rated movies
      final movies = await _tmdbService.getTopRatedMovies(); 
      setState(() {
        _topMovies = movies;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint("fail: $e");
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F0F0F),
      appBar: AppBar(
        title: const Text("IMDb Top 50", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.deepPurpleAccent))
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _topMovies.length > 50 ? 50 : _topMovies.length,
              itemBuilder: (context, index) {
                final movie = _topMovies[index];
                return _buildMovieItem(movie, index + 1);
              },
            ),
    );
  }

  Widget _buildMovieItem(dynamic movie, int rank) {
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
          color: Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            // 排名数字
            SizedBox(
              width: 40,
              child: Text(
                "#$rank", 
                style: const TextStyle(color: Colors.amber, fontWeight: FontWeight.bold, fontSize: 18)
              ),
            ),
            const SizedBox(width: 5),
            // 海报
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
                  width: 60, height: 90, color: Colors.grey[900], 
                  child: const Icon(Icons.movie, color: Colors.grey)
                ),
              ),
            ),
            const SizedBox(width: 15),
            // 文字信息
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    movie["title"] ?? "Unknown", 
                    style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold), 
                    maxLines: 1, 
                    overflow: TextOverflow.ellipsis
                  ),
                  const SizedBox(height: 5),
                  Text(
                    (movie["release_date"] != null && movie["release_date"].toString().length >= 4)
                        ? movie["release_date"].split('-')[0]
                        : "N/A", 
                    style: const TextStyle(color: Colors.grey)
                  ),
                  const SizedBox(height: 5),
                  
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios, color: Colors.white24, size: 16),
          ],
        ),
      ),
    );
  }
}