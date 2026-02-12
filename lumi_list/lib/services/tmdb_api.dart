import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../models/cast.dart';

class TmdbService {
  static const _baseUrl = 'https://api.themoviedb.org/3';
  final String token;

  TmdbService(this.token);

  Options _opts() => Options(
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

  Dio get _dio => Dio();

  // ---------- IMDb / Cast ----------
  Future<int?> getMovieIdByImdb(String imdbId) async {
    try {
      final res = await _dio.get(
        '$_baseUrl/find/$imdbId',
        options: _opts(),
        queryParameters: {'external_source': 'imdb_id'},
      );

      debugPrint('TMDb find response: ${res.data}');

      final movieResults = res.data['movie_results'] as List?;
      if (movieResults != null && movieResults.isNotEmpty) {
        return movieResults[0]['id'];
      }

      final tvResults = res.data['tv_results'] as List?;
      if (tvResults != null && tvResults.isNotEmpty) {
        return tvResults[0]['id'];
      }

      return null;
    } catch (e) {
      debugPrint('TMDb find error: $e');
      return null;
    }
  }

  Future<List<CastMember>> getCast(int movieId) async {
    try {
      final res = await _dio.get(
        '$_baseUrl/movie/$movieId/credits',
        options: _opts(),
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

  /// Movie details endpoint returns imdb_id directly
  Future<String?> getImdbIdByTmdbId(int tmdbId) async {
    try {
      final res = await _dio.get(
        '$_baseUrl/movie/$tmdbId',
        options: _opts(),
      );
      return res.data['imdb_id'];
    } catch (e) {
      debugPrint('TMDb fail to get IMDb ID (movie): $e');
      return null;
    }
  }

  /// TV needs external_ids endpoint
  Future<String?> getImdbIdByTvTmdbId(int tvId) async {
    try {
      final res = await _dio.get(
        '$_baseUrl/tv/$tvId/external_ids',
        options: _opts(),
      );
      return res.data['imdb_id'];
    } catch (e) {
      debugPrint('TMDb fail to get IMDb ID (tv): $e');
      return null;
    }
  }

  // ---------- Trending / Upcoming / Top rated ----------
  Future<List<dynamic>> getTrendingMovies({int page = 1}) async {
    try {
      final response = await _dio.get(
        '$_baseUrl/trending/all/day',
        options: _opts(),
        queryParameters: {'page': page},
      );
      return (response.data['results'] as List?) ?? [];
    } catch (e) {
      debugPrint('TMDb trending error: $e');
      return [];
    }
  }

  Future<List<dynamic>> getUpcomingMovies({
    int page = 1,
    String region = 'US',
    String language = 'en-US',
  }) async {
    try {
      final response = await _dio.get(
        '$_baseUrl/movie/upcoming',
        options: _opts(),
        queryParameters: {
          'page': page,
          'language': language,
          'region': region,
        },
      );
      return (response.data['results'] as List?) ?? [];
    } catch (e) {
      debugPrint('TMDb upcoming error: $e');
      return [];
    }
  }

  Future<List<dynamic>> getTopRatedMovies({int page = 1}) async {
    try {
      final res = await _dio.get(
        '$_baseUrl/movie/top_rated',
        options: _opts(),
        queryParameters: {
          'language': 'en-US',
          'page': page,
        },
      );

      debugPrint('TMDb top rated response: ${res.data['results']?.length}');
      return (res.data['results'] as List?) ?? [];
    } catch (e) {
      debugPrint('TMDb top rated error: $e');
      return [];
    }
  }

  // ---------- Search (Movie / TV / Multi) ----------
  Future<List<dynamic>> searchMovies(String query, {int page = 1}) async {
    try {
      final response = await _dio.get(
        '$_baseUrl/search/movie',
        options: _opts(),
        queryParameters: {
          'query': query,
          'language': 'en-US',
          'page': page,
        },
      );

      return (response.data['results'] as List?) ?? [];
    } catch (e) {
      debugPrint('TMDb search(movie) error: $e');
      return [];
    }
  }

  Future<List<dynamic>> searchTv(String query, {int page = 1}) async {
    try {
      final response = await _dio.get(
        '$_baseUrl/search/tv',
        options: _opts(),
        queryParameters: {
          'query': query,
          'language': 'en-US',
          'page': page,
        },
      );

      return (response.data['results'] as List?) ?? [];
    } catch (e) {
      debugPrint('TMDb search(tv) error: $e');
      return [];
    }
  }

  /// Multi-search returns movies + tv + people; we will filter people in UI.
  Future<List<dynamic>> searchMulti(String query, {int page = 1}) async {
    try {
      final response = await _dio.get(
        '$_baseUrl/search/multi',
        options: _opts(),
        queryParameters: {
          'query': query,
          'language': 'en-US',
          'page': page,
        },
      );

      return (response.data['results'] as List?) ?? [];
    } catch (e) {
      debugPrint('TMDb search(multi) error: $e');
      return [];
    }
  }

  // ---------- Reviews ----------
  Future<List<dynamic>> getMovieReviews(
    int movieId, {
    int page = 1,
    String language = 'en-US',
  }) async {
    try {
      final res = await _dio.get(
        '$_baseUrl/movie/$movieId/reviews',
        options: _opts(),
        queryParameters: {
          'page': page,
          'language': language,
        },
      );
      return (res.data['results'] as List?) ?? [];
    } catch (e) {
      debugPrint('TMDb movie reviews error: $e');
      return [];
    }
  }

  // ---------- Videos (Teasers / Trailers) ----------
  Future<List<dynamic>> getMovieVideos(
    int movieId, {
    String language = 'en-US',
  }) async {
    try {
      final res = await _dio.get(
        '$_baseUrl/movie/$movieId/videos',
        options: _opts(),
        queryParameters: {'language': language},
      );
      return (res.data['results'] as List?) ?? [];
    } catch (e) {
      debugPrint('TMDb movie videos error: $e');
      return [];
    }
  }

  // ---------- Images (stills / backdrops) ----------
  Future<List<dynamic>> getMovieBackdrops(
    int movieId, {
    String includeImageLanguage = 'en,null',
  }) async {
    try {
      final res = await _dio.get(
        '$_baseUrl/movie/$movieId/images',
        options: _opts(),
        queryParameters: {
          // TMDb accepts include_image_language like "en,null"
          'include_image_language': includeImageLanguage,
        },
      );
      return (res.data['backdrops'] as List?) ?? [];
    } catch (e) {
      debugPrint('TMDb movie images error: $e');
      return [];
    }
  }
}
