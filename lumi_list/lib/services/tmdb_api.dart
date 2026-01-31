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

    final results = res.data['movie_results'] as List?;
    if (results == null || results.isEmpty) return null;

    return results[0]['id'];
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
}
