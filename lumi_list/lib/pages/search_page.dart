import 'package:flutter/material.dart';
import '../services/tmdb_api.dart';
import 'widgets/movie_card.dart';
import '../models/movie.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final TextEditingController _controller = TextEditingController();
  List<Movie> results = [];
  bool loading = false;

  void _search() async {
    if (_controller.text.isEmpty) return;

    setState(() => loading = true);
    results = await TMDbApi.searchMovie(_controller.text);
    setState(() => loading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Search Movies")),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              controller: _controller,
              decoration: InputDecoration(
                hintText: "Search by title...",
                suffixIcon: IconButton(
                  icon: const Icon(Icons.search),
                  onPressed: _search,
                ),
              ),
            ),
          ),
          Expanded(
            child: loading
                ? const Center(child: CircularProgressIndicator())
                : ListView.builder(
                    itemCount: results.length,
                    itemBuilder: (context, index) {
                      return MovieCard(movie: results[index]);
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
