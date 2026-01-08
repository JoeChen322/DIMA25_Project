import 'package:flutter/material.dart';
import '../services/omdb_api.dart';
import 'movie_detail.dart';
import '../utils/relevance.dart';

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
    // Sort by relevance
    result.sort((a, b) 
    {
    final scoreB = relevanceScore(b['Title'] ?? '', query);
    final scoreA = relevanceScore(a['Title'] ?? '', query);
    print('Movie: ${a['Title']} Score: $scoreA vs ${b['Title']} Score: $scoreB');
    return scoreB.compareTo(scoreA);
    });
    setState(() {
      loading = false;
      if (result.isEmpty) {
        errorMessage = 'No movies found for "$query"';
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
      appBar: AppBar(
        title: const Text("Search Movie"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // search bar
            TextField(
              controller: _controller,
              onSubmitted: (_) => _search(),
              decoration: InputDecoration(
                hintText: "Enter movie name...",
                prefixIcon: const Icon(Icons.search),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.arrow_forward),
                  onPressed: _search,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Loading
            if (loading)
              const Padding(
                padding: EdgeInsets.all(16),
                child: CircularProgressIndicator(),
              ),

            // Error
            if (errorMessage != null)
              Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  errorMessage!,
                  style: const TextStyle(color: Colors.red),
                ),
              ),

            // Results list
            if (movies.isNotEmpty)
              Expanded(
                child: ListView.builder(
                  itemCount: movies.length,
                  itemBuilder: (context, index) {
                    final movie = movies[index];

                    return Card(
                      child: ListTile(
                        leading: movie["Poster"] != null &&
                                movie["Poster"] != "N/A"
                            ? Image.network(
                                movie["Poster"],
                                width: 50,
                                fit: BoxFit.cover,
                              )
                            : const Icon(Icons.movie),

                        title: Text(movie["Title"] ?? ""),
                        subtitle: Text(movie["Year"] ?? ""),
                        trailing: const Icon(Icons.arrow_forward_ios, size: 16),

                        onTap: () async {
                          final imdbId = movie["imdbID"];
                          if (imdbId == null) return;

                          
                          final fullMovie =
                              await OmdbApi.getMovieById(imdbId);

                          if (fullMovie != null && context.mounted) {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) =>
                                    MovieDetailPage(movie: fullMovie),
                              ),
                            );
                          }
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
