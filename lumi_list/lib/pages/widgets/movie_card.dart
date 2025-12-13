import 'package:flutter/material.dart';
import "package:lumi_list/models/movie.dart";

class MovieCard extends StatelessWidget {
  final Movie movie;

  const MovieCard({super.key, required this.movie});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: movie.posterUrl.isNotEmpty
          ? Image.network(movie.posterUrl, width: 50)
          : const Icon(Icons.movie),
      title: Text(movie.title),
      subtitle: Text(
        movie.overview.length > 50
            ? "${movie.overview.substring(0, 50)}..."
            : movie.overview,
      ),
      onTap: () {
        Navigator.pushNamed(context, '/detail', arguments: movie);
      },
    );
  }
}
