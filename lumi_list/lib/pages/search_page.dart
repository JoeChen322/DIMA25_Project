import 'package:flutter/material.dart';
import '../services/tmdb_api.dart'; // 切换到 TMDb Service
import 'movie_detail.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final TextEditingController _controller = TextEditingController();
  
  // 使用与 HomePage 相同的 Token
  final TmdbService _tmdbService = TmdbService(
      'eyJhbGciOiJIUzI1NiJ9.eyJhdWQiOiJlNWUxYTU5ODc0YzMwZDlmMWM2NTJlYjllZDQ4MmMzMyIsIm5iZiI6MTc2NjQzOTY0Mi40NTIsInN1YiI6IjY5NDliYWRhNTNhODI1Nzk1YzE1NTk5OCIsInNjb3BlcyI6WyJhcGlfcmVhZCJdLCJ2ZXJzaW9uIjoxfQ.V0Z-rlGFtBKfCUHFx3nNnqxVNoJ-T3YNVDF8URfMj4U');

  List<dynamic> _movies = [];
  bool _isLoading = false;
  String? _errorMessage;

  Future<void> _search() async {
    final query = _controller.text.trim();
    if (query.isEmpty) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _movies = [];
    });

    try {
      // 调用 TMDb 的搜索接口
      final result = await _tmdbService.searchMovies(query);
      
      setState(() {
        _isLoading = false;
        if (result.isEmpty) {
          _errorMessage = 'No movies found for "$query"';
        } else {
          _movies = result;
        }
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = "Search failed. Please check your connection.";
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black, // 保持与首页风格一致
      appBar: AppBar(
        title: const Text("Search Movies"),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // 搜索框
            TextField(
              controller: _controller,
              style: const TextStyle(color: Colors.white),
              onSubmitted: (_) => _search(),
              decoration: InputDecoration(
                hintText: "Enter movie name...",
                hintStyle: const TextStyle(color: Colors.grey),
                prefixIcon: const Icon(Icons.search, color: Colors.white),
                filled: true,
                fillColor: Colors.grey[900],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.send, color: Colors.deepPurpleAccent),
                  onPressed: _search,
                ),
              ),
            ),

            const SizedBox(height: 16),

            if (_isLoading)
              const Padding(
                padding: EdgeInsets.all(16),
                child: CircularProgressIndicator(color: Colors.deepPurpleAccent),
              ),

            if (_errorMessage != null)
              Padding(
                padding: const EdgeInsets.all(16),
                child: Text(_errorMessage!, style: const TextStyle(color: Colors.red)),
              ),

            // 搜索结果列表
            Expanded(
              child: ListView.builder(
                itemCount: _movies.length,
                itemBuilder: (context, index) {
                  final movie = _movies[index];
                  final String? posterPath = movie["poster_path"];
                  final String title = movie["title"] ?? "Untitled";
                  final String year = movie["release_date"]?.split('-')[0] ?? "N/A";

                  return Card(
                    color: Colors.grey[900],
                    margin: const EdgeInsets.only(bottom: 10),
                    child: ListTile(
                      leading: ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: posterPath != null
                            ? Image.network(
                                "https://image.tmdb.org/t/p/w92$posterPath", // 拼接图片前缀
                                width: 50,
                                fit: BoxFit.cover,
                                errorBuilder: (ctx, err, stack) => const Icon(Icons.broken_image, color: Colors.grey),
                              )
                            : Container(width: 50, color: Colors.grey, child: const Icon(Icons.movie)),
                      ),
                      title: Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                      subtitle: Text(year, style: const TextStyle(color: Colors.grey)),
                      trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.white),
                      onTap: () {
                        // 格式化数据以兼容 MovieDetailPage
                        final formattedMovie = {
                          "Title": title,
                          "Year": year,
                          "Poster": posterPath != null ? "https://image.tmdb.org/t/p/w500$posterPath" : null,
                          "Plot": movie["overview"] ?? "No summary available.",
                          "imdbID": movie["id"].toString(), // 传 TMDb ID，详情页会自动换取 tt 号
                          "imdbRating": movie["vote_average"]?.toString(),
                          "Ratings": [
                            {"Source": "TMDb", "Value": "${movie["vote_average"]}/10"}
                          ],
                        };

                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => MovieDetailPage(movie: formattedMovie),
                          ),
                        );
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}