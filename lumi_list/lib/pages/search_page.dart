import 'package:flutter/material.dart';
import '../services/tmdb_api.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final TextEditingController _controller = TextEditingController();
  Map<String, dynamic>? movieData;
  bool loading = false;
  String? errorMessage;

  void _search() async {
    final query = _controller.text.trim();
    if (query.isEmpty) return;

    setState(() {
      loading = true;
      errorMessage = null;
      movieData = null;
    });

    final data = await OmdbApi.searchMovie(query);

    setState(() {
      loading = false;
      if (data == null) {
        errorMessage = "Did not find movie: $query, please try again.";
      } else {
        movieData = data;
      }
    });
  }

  Widget _buildRatings(List ratings) {
    String imdb = movieData?["imdbRating"] ?? "N/A";
    String? rotten;
    String? meta;

    for (var r in ratings) {
      if (r["Source"] == "Rotten Tomatoes") rotten = r["Value"];
      if (r["Source"] == "Metacritic") meta = r["Value"];
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("IMDb：$imdb", style: const TextStyle(fontSize: 18)),
        Text("Rotten Tomatoes：${rotten ?? "N/A"}", style: const TextStyle(fontSize: 18)),
        Text("Metascore：${meta ?? "N/A"}", style: const TextStyle(fontSize: 18)),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Search Movie Here")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _controller,
              decoration: InputDecoration(
                hintText: "Enter Movie name, Actor name...",
                suffixIcon: IconButton(
                  icon: const Icon(Icons.search),
                  onPressed: _search,
                ),
              ),
            ),
            const SizedBox(height: 20),

            if (loading) const CircularProgressIndicator(),

            if (errorMessage != null)
              Text(errorMessage!, style: const TextStyle(color: Colors.red)),

            if (movieData != null)
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        movieData!["Title"] ?? "",
                        style: const TextStyle(
                            fontSize: 24, fontWeight: FontWeight.bold),
                      ),
                      Text(movieData!["Year"] ?? "",
                          style: const TextStyle(fontSize: 18)),

                      const SizedBox(height: 10),

                      if (movieData!["Poster"] != null &&
                          movieData!["Poster"] != "N/A")
                        Image.network(movieData!["Poster"], height: 300),

                      const SizedBox(height: 20),

                      Text(movieData!["Plot"] ?? "No description available",
                          style: const TextStyle(fontSize: 16)),

                      const SizedBox(height: 20),

                      const Text("Ratings:",
                          style: TextStyle(
                              fontSize: 22, fontWeight: FontWeight.bold)),
                      _buildRatings(movieData!["Ratings"] ?? []),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
