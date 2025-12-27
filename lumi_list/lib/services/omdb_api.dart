import 'package:dio/dio.dart';

class OmdbApi {
  static const String apiKey = "5a86a29e";
  static const String baseUrl = "http://www.omdbapi.com/";

  static Future<Map<String, dynamic>?> searchMovie(String title) async {
    final response = await Dio().get(baseUrl, queryParameters: {
      "apikey": apiKey,
      "t": title,  //search with film title
    });

    if (response.data["Response"] == "False") {
      return null;
    }

    return response.data;
  }
}
