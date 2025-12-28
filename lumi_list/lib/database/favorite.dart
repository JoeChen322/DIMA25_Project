import 'package:sqflite/sqflite.dart';
import 'app_database.dart';

class FavoriteDao {
  // add to favorites
  static Future<void> insertFavorite({
    required String imdbId,
    required String title,
    required String poster,
    int? rating,
  }) async {
    final db = await AppDatabase.database;
    await db.insert(
      'favorites',
      {
        'imdb_id': imdbId,
        'title': title,
        'poster': poster,
        'rating': rating,
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
}
