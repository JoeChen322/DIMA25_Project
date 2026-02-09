import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../models/cast.dart';
class TmdbService {
  static const _baseUrl = 'https://api.themoviedb.org/3';
  final String token;

  TmdbService(this.token);

  Future<int?> getMovieIdByImdb(String imdbId) async {
  try {
    final res = await Dio().get(
      '$_baseUrl/find/$imdbId',
      options: Options(
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      ),
      queryParameters: {
        'external_source': 'imdb_id',
      },
    );

    debugPrint('TMDb find response: ${res.data}');

    // MOVIE
    final movieResults = res.data['movie_results'] as List?;
    if (movieResults != null && movieResults.isNotEmpty) return movieResults[0]['id'];
    // TV Ser
    final tvResults = res.data['tv_results'] as List?;
    if (tvResults != null && tvResults.isNotEmpty) return tvResults[0]['id'];

    return null;
  } catch (e) {
    debugPrint('TMDb find error: $e');
    return null;
  }
}

Future<List<CastMember>> getCast(int movieId) async {
  try {
    final res = await Dio().get(
      '$_baseUrl/movie/$movieId/credits',
      options: Options(
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      ),
    );

    debugPrint('TMDb cast response: ${res.data['cast']?.length}');

    return (res.data['cast'] as List)
        .take(10)
        .map((e) => CastMember.fromJson(e))
        .toList();
  } catch (e) {
    debugPrint('TMDb cast error: $e');
    return [];
  }
}

// add new movie on show 
Future<List<dynamic>> getTrendingMovies() async {
  try {
    final res = await Dio().get(
      '$_baseUrl/trending/all/day',
      options: Options(
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      ),
    );
    return res.data['results'] as List;
  } catch (e) {
    debugPrint('TMDb trending error: $e');
    return [];
  }
}


Future<String?> getImdbIdByTmdbId(int tmdbId) async {
  try {
    
    final res = await Dio().get(
      '$_baseUrl/movie/$tmdbId',
      options: Options(
        headers: {
          'Authorization': 'Bearer $token', // V4 Token
          'Accept': 'application/json',
        },
      ),
    );
    // return imdb id for detail page
    return res.data['imdb_id'];
  } catch (e) {
    debugPrint('TMDb fail to get IMDb ID: $e');
    return null;
  }
}

// tmdb_api.dart

Future<List<dynamic>> searchMovies(String query) async {
  try {
    final res = await Dio().get(
      '$_baseUrl/search/movie',
      options: Options(
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      ),
      queryParameters: {
        'query': query,
        'language': 'en-US',
        'page': 1,
      },
    );
    return res.data['results'] ?? [];
  } catch (e) {
    debugPrint('TMDb search error: $e');
    return [];
  }
}

Future<List<dynamic>> getTopRatedMovies({int page = 1}) async {
  try {
    final res = await Dio().get(
      '$_baseUrl/movie/top_rated', // 
      options: Options(
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      ),
      queryParameters: {
        'language': 'en-US',
        'page': page,
      },
    );
    
    debugPrint('TMDb top rated response: ${res.data['results']?.length}');
    return res.data['results'] ?? [];
  } catch (e) {
    debugPrint('TMDb top rated error: $e');
    return [];
  }
}
}
