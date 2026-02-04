/*for serch movies using TMDb API*/
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import '../services/tmdb_api.dart'; 
import 'movie_detail.dart';
import 'dart:ui'; 
import 'CategoryDetail.dart';
class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final TextEditingController _controller = TextEditingController();
  
  
  List<dynamic> _movies = [];
  bool _isLoading = false;
  String? _errorMessage;

  // all use TMDb Service
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
      
      final result = await _tmdbService.searchMovies(query);
      // filter  movies without poster
      final filteredResult = result.where((movie) {
          return movie['poster_path'] != null && movie['poster_path'].toString().isNotEmpty;
         }).toList();

      setState(() {
        _isLoading = false;
        if (filteredResult.isEmpty) {
          _errorMessage = 'No movies found for "$query"';
        } else {
          _movies = filteredResult;
          
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
      backgroundColor: const Color(0xFF0F0F0F), // dark background
      body: Stack(
        children: [
          // purple blurred circle background
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
                //tilte
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

                // search bar
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

                // default view when no search has been made
                if (!_isLoading && _movies.isEmpty && _errorMessage == null)
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          
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
                              _buildCategoryCard("Fiction", Colors.blueAccent),
                              _buildCategoryCard("Horror", Colors.redAccent),
                              _buildCategoryCard("Comedy", Colors.greenAccent),
                              _buildCategoryCard("Crime",  Colors.yellowAccent),
                              _buildCategoryCard("Romance", Colors.purpleAccent),
                            ],
                          ),
                          

                        ],
                      ),
                    ),
                  ),

                // loading indicator
                if (_isLoading)
                  const Expanded(child: Center(child: CircularProgressIndicator(color: Colors.deepPurpleAccent))),

                //error message
                if (_errorMessage != null)
                  Expanded(child: Center(child: Text(_errorMessage!, style: const TextStyle(color: Colors.red, fontSize: 16)))),

                // show search results
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

  // mobvie card widget
  Widget _buildMovieCard(dynamic movie) {
    final String title = movie["title"] ?? "Untitled";
    final String year = movie["release_date"]?.split('-')[0] ?? "N/A";
    final String? posterPath = movie["poster_path"];

    return GestureDetector(
      onTap: () {
        // change movie data format to match MovieDetailPage requirements
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
  return GestureDetector( 
    onTap: () {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => CategoryDetailPage(category: title),
        ),
      );
    },
    child: Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: LinearGradient(
          colors: [color.withOpacity(0.4), color.withOpacity(0.1)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Center( // 
        child: Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    ),
  );
}
}