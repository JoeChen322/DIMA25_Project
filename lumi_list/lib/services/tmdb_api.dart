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

// 在 TmdbService 类中添加
Future<String?> getImdbIdByTmdbId(int tmdbId) async {
  try {
    // 访问具体电影详情接口
    final res = await Dio().get(
      '$_baseUrl/movie/$tmdbId',
      options: Options(
        headers: {
          'Authorization': 'Bearer $token', // 必须使用你的 V4 Token
          'Accept': 'application/json',
        },
      ),
    );
    // 返回 imdb_id，例如 "tt1546052"
    return res.data['imdb_id'];
  } catch (e) {
    debugPrint('TMDb 获取详情失败: $e');
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

Future<List<dynamic>> getTopRatedMovies() async {
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
        'page': 1, // 
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
