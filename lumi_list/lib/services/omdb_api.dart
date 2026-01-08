import 'package:dio/dio.dart';

class OmdbApi {
  static const String _baseUrl = 'https://www.omdbapi.com/';
  static const String apiKey = '5a86a29e';

  // fuzzy search by title
  static Future<List<Map<String, dynamic>>> searchMovies(String query) async {
    final res = await Dio().get(
      _baseUrl,
      queryParameters: {
        'apikey': apiKey,
        's': query,
        'type': 'movie',
        'page': 3,
      },
    );

    if (res.data['Response'] == 'True') {
      return List<Map<String, dynamic>>.from(res.data['Search']);
    }
    return [];
  }

  // get movie details by imdbID
  static Future<Map<String, dynamic>?> getMovieById(String imdbId) async {
    final res = await Dio().get(
      _baseUrl,
      queryParameters: {
        'apikey': apiKey,
        'i': imdbId,
        'plot': 'full',
      },
    );

    if (res.data['Response'] == 'True') {
      return Map<String, dynamic>.from(res.data);
    }
    return null;
  }

  // get movie details by exact title
  static Future<Map<String, dynamic>?> searchMovie(String title) async {
    final res = await Dio().get(
      _baseUrl,
      queryParameters: {
        'apikey': apiKey,
        't': title,
        'plot': 'full',
      },
    );

    if (res.data['Response'] == 'True') {
      return Map<String, dynamic>.from(res.data);
    }
    return null;
  }
}
