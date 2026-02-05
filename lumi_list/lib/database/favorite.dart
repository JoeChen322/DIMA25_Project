/*Info of the favorites list associated with the ♥ button */
import 'package:sqflite/sqflite.dart';
import 'app_database.dart';

class FavoriteDao {
  // add to favorites
  static Future<void> insertFavorite({
    required String imdbId,
    required String title,
    required String poster,
    int? rating,
    String? genre,
  }) async {
    final db = await AppDatabase.database;
    await db.insert(
      'favorites',
      {
        'imdb_id': imdbId,
        'title': title,
        'poster': poster,
        'genre': genre,
        'rating': rating

      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // delete from favorites
  static Future<void> deleteFavorite(String imdbId) async {
    final db = await AppDatabase.database;
    await db.delete(
      'favorites',
      where: 'imdb_id = ?',
      whereArgs: [imdbId],
    );
  }

  // check if favorite
  static Future<bool> isFavorite(String imdbId) async {
    final db = await AppDatabase.database;
    final res = await db.query(
      'favorites',
      where: 'imdb_id = ?',
      whereArgs: [imdbId],
    );
    return res.isNotEmpty;
  }

  // read all favorites
  static Future<List<Map<String, dynamic>>> getAllFavorites() async {
    final db = await AppDatabase.database;
    return db.query('favorites');
  }
  
  static Future<String?> getMostFrequentGenre() async {

    final favorites = await getAllFavorites();
    if (favorites.isEmpty) return null;
    Map<String, int> genreCounts = {};

    for (var movie in favorites) {
      String? genreStr = movie['genre']; 
      if (genreStr != null && genreStr != "No Info" && genreStr.isNotEmpty) {
        List<String> genres = genreStr.split(',').map((g) => g.trim()).toList();
        
        for (var genre in genres) {
          genreCounts[genre] = (genreCounts[genre] ?? 0) + 1;
        }
      }
    }

    if (genreCounts.isEmpty) return null;
    var mostFrequent = genreCounts.entries.reduce((a, b) => a.value > b.value ? a : b);

    return mostFrequent.key;
  }

}
