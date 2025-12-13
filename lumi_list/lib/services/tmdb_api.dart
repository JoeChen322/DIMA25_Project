import 'package:dio/dio.dart';
import '../models/movie.dart';

class TMDbApi {
  static const String apiKey = "YOUR_API_KEY_HERE";
  static const String baseUrl = "https://api.themoviedb.org/3";

  static Future<List<Movie>> searchMovie(String query) async {
    const url = "$baseUrl/search/movie";

    final response = await Dio().get(url, queryParameters: {
      "api_key": apiKey,
      "query": query,
      "language": "en-US",
    });

    final List results = response.data["results"];
    return results.map((e) => Movie.fromTMDb(e)).toList();
  }
}
