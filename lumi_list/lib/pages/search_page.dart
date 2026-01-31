import 'package:flutter/material.dart';
import '../services/tmdb_api.dart'; // 统一使用 TMDb
import 'movie_detail.dart';
import 'dart:ui'; // 用于毛玻璃效果

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final TextEditingController _controller = TextEditingController();
  
  // 统一变量名，使用队友定义的 _movies 逻辑，但保留你的 loading 状态名
  List<dynamic> _movies = [];
  bool _isLoading = false;
  String? _errorMessage;

  // 使用统一的 TMDb Service
  final TmdbService _tmdbService = TmdbService(
      'eyJhbGciOiJIUzI1NiJ9.eyJhdWQiOiJlNWUxYTU5ODc0YzMwZDlmMWM2NTJlYjllZDQ4MmMzMyIsIm5iZiI6MTc2NjQzOTY0Mi40NTIsInN1YiI6IjY5NDliYWRhNTNhODI1Nzk1YzE1NTk5OCIsInNjb3BlcyI6WyJhcGlfcmVhZCJdLCJ2ZXJzaW9uIjoxfQ.V0Z-rlGFtBKfCUHFx3nNnqxVNoJ-T3YNVDF8URfMj4U');

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
          // TMDb 的结果已经按流行度排序，通常不需要手动再次排序
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
      backgroundColor: const Color(0xFF0F0F0F), // 采用深色背景
      body: Stack(
        children: [
          // 背景装饰：紫光晕
          Positioned(
            top: -100,
            right: -50,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.deepPurple.withOpacity(0.15),
              ),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 50, sigmaY: 50),
                child: Container(color: Colors.transparent),
              ),
            ),
          ),
          
          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. 标题
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Search",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 34,
                          fontWeight: FontWeight.bold,
                          letterSpacing: -1,
                        ),
                      ),
                      Text(
                        "Find your next story",
                        style: TextStyle(color: Colors.grey[500], fontSize: 16),
                      ),
                    ],
                  ),
                ),

                // 2. 搜索框
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.white.withOpacity(0.1)),
                    ),
                    child: TextField(
                      controller: _controller,
                      onSubmitted: (_) => _search(),
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        hintText: "Enter movie name...",
                        hintStyle: TextStyle(color: Colors.grey[600]),
                        prefixIcon: const Icon(Icons.search_rounded, color: Colors.deepPurpleAccent),
                        suffixIcon: IconButton(
                          icon: const Icon(Icons.send_rounded, color: Colors.white),
                          onPressed: _search,
                        ),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(vertical: 15),
                      ),
                    ),
                  ),
                ),

                // 3. 引导元素 (仅在初始状态显示)
                if (!_isLoading && _movies.isEmpty && _errorMessage == null)
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 10),
                          const Text("Trending Searches", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 15),
                          Wrap(
                            spacing: 10,
                            runSpacing: 12,
                            children: [
                              _buildModernTag("Inception"),
                              _buildModernTag("Interstellar"),
                              _buildModernTag("The Whale"),
                              _buildModernTag("Batman"),
                              _buildModernTag("Marvel"),
                            ],
                          ),
                          const SizedBox(height: 40),
                          const Text("Browse Categories", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 15),
                          GridView.count(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            crossAxisCount: 2,
                            childAspectRatio: 2.5,
                            mainAxisSpacing: 12,
                            crossAxisSpacing: 12,
                            children: [
                              _buildCategoryCard("Action", Colors.orangeAccent),
                              _buildCategoryCard("Sci-Fi", Colors.blueAccent),
                              _buildCategoryCard("Horror", Colors.redAccent),
                              _buildCategoryCard("Comedy", Colors.greenAccent),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),

                // 4. 加载中
                if (_isLoading)
                  const Expanded(child: Center(child: CircularProgressIndicator(color: Colors.deepPurpleAccent))),

                // 5. 错误显示
                if (_errorMessage != null)
                  Expanded(child: Center(child: Text(_errorMessage!, style: const TextStyle(color: Colors.red, fontSize: 16)))),

                // 6. 搜索结果 (使用 TMDb 格式)
                if (_movies.isNotEmpty)
                  Expanded(
                    child: ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: _movies.length,
                      itemBuilder: (context, index) {
                        return _buildMovieCard(_movies[index]);
                      },
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // 电影卡片 UI (适配 TMDb 数据格式)
  Widget _buildMovieCard(dynamic movie) {
    final String title = movie["title"] ?? "Untitled";
    final String year = movie["release_date"]?.split('-')[0] ?? "N/A";
    final String? posterPath = movie["poster_path"];

    return GestureDetector(
      onTap: () {
        // 转换数据格式以兼容 MovieDetailPage
        final formattedMovie = {
          "Title": title,
          "Year": year,
          "Poster": posterPath != null ? "https://image.tmdb.org/t/p/w500$posterPath" : null,
          "Plot": movie["overview"] ?? "No summary available.",
          "imdbID": movie["id"].toString(),
          "imdbRating": movie["vote_average"]?.toString(),
        };

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => MovieDetailPage(movie: formattedMovie),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        height: 120,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.horizontal(left: Radius.circular(12)),
              child: posterPath != null
                  ? Image.network(
                      "https://image.tmdb.org/t/p/w185$posterPath",
                      width: 85,
                      height: 120,
                      fit: BoxFit.cover,
                    )
                  : Container(width: 85, color: Colors.grey[800], child: const Icon(Icons.movie, color: Colors.white)),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Text(year, style: TextStyle(color: Colors.grey[500], fontSize: 14)),
                  ],
                ),
              ),
            ),
            const Icon(Icons.chevron_right, color: Colors.grey),
            const SizedBox(width: 10),
          ],
        ),
      ),
    );
  }

  Widget _buildModernTag(String text) {
    return GestureDetector(
      onTap: () {
        _controller.text = text;
        _search(); 
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white.withOpacity(0.1)),
        ),
        child: Text(text, style: const TextStyle(color: Colors.white70, fontSize: 13)),
      ),
    );
  }

  Widget _buildCategoryCard(String title, Color color) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: LinearGradient(
          colors: [color.withOpacity(0.4), color.withOpacity(0.1)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Center(
        child: Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15)),
      ),
    );
  }
}