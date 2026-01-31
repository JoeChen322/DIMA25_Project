import 'package:flutter/material.dart';
import '../services/omdb_api.dart';
import 'movie_detail.dart';
import '../utils/relevance.dart';
import 'dart:ui'; // 用于毛玻璃效果

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final TextEditingController _controller = TextEditingController();
  List<Map<String, dynamic>> movies = [];
  bool loading = false;
  String? errorMessage;

  Future<void> _search() async {
    final query = _controller.text.trim();
    if (query.isEmpty) return;

    setState(() {
      loading = true;
      errorMessage = null;
      movies = [];
    });

    final result = await OmdbApi.searchMovies(query);
    result.sort((a, b) {
      final scoreB = relevanceScore(b['Title'] ?? '', query);
      final scoreA = relevanceScore(a['Title'] ?? '', query);
      return scoreB.compareTo(scoreA);
    });

    setState(() {
      loading = false;
      if (result.isEmpty) {
        errorMessage = 'No results found for "$query"';
      } else {
        movies = result;
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F0F0F), // 采用电影感极佳的暗色背景
      body: Stack(
        children: [
          // 背景装饰：顶部的紫色光晕渐变
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
                // 1. 标题栏
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

                // 2. 悬浮质感的搜索框
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

                // 3. 初始状态下的引导元素 (只有在没加载、没结果时显示)
                if (!loading && movies.isEmpty && errorMessage == null)
                  Expanded(
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 10),
                          const Text(
                            "Trending Searches",
                            style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                          ),
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
                          const Text(
                            "Browse Categories",
                            style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                          ),
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

                // 4. 加载状态
                if (loading)
                  const Expanded(child: Center(child: CircularProgressIndicator(color: Colors.deepPurpleAccent))),

                // 5. 错误提示
                if (errorMessage != null)
                  Expanded(child: Center(child: Text(errorMessage!, style: const TextStyle(color: Colors.grey, fontSize: 16)))),

                // 6. 搜索结果列表
                if (movies.isNotEmpty)
                  Expanded(
                    child: ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: movies.length,
                      itemBuilder: (context, index) {
                        final movie = movies[index];
                        return _buildMovieCard(movie);
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

  // 电影卡片 UI
  Widget _buildMovieCard(Map<String, dynamic> movie) {
    return GestureDetector(
      onTap: () async {
        final imdbId = movie["imdbID"];
        if (imdbId == null) return;
        final fullMovie = await OmdbApi.getMovieById(imdbId);
        if (fullMovie != null && context.mounted) {
          Navigator.push(context, MaterialPageRoute(builder: (_) => MovieDetailPage(movie: fullMovie)));
        }
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
              child: movie["Poster"] != null && movie["Poster"] != "N/A"
                  ? Image.network(movie["Poster"], width: 85, height: 120, fit: BoxFit.cover)
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
                      movie["Title"] ?? "",
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      movie["Year"] ?? "",
                      style: TextStyle(color: Colors.grey[500], fontSize: 14),
                    ),
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

  // 胶囊标签
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
        child: Text(
          text,
          style: const TextStyle(color: Colors.white70, fontSize: 13),
        ),
      ),
    );
  }

  // 分类卡片
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
        child: Text(
          title,
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15),
        ),
      ),
    );
  }
}