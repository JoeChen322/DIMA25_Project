import 'package:sqflite/sqflite.dart';
import 'app_database.dart';
import 'user.dart';
class SeeLaterDao {
  static Future<void> insertSeeLater({
    required String imdbId,
    required String title,
    required String poster,
  }) async {
     final userId = UserDao.getCurrentUserId();
    if (userId == null) throw Exception("Please login first");

    final db = await AppDatabase.database;
    await db.insert(
      'see_later',
      {
        'user_id': userId,
        'imdb_id': imdbId,
        'title': title,
        'poster': poster,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  //delete
  static Future<void> deleteSeeLater(String imdbId) async {
    final userId = UserDao.getCurrentUserId();
    if (userId == null) throw Exception("Please login first");
    final db = await AppDatabase.database;
    await db.delete(
      'see_later',
      where: 'imdb_id = ?',
      whereArgs: [imdbId],
    );
  }

  // check if in see later
  static Future<bool> isSeeLater(String imdbId) async {
    final userId = UserDao.getCurrentUserId();
    if (userId == null) throw Exception("Please login first");
    final db = await AppDatabase.database;
    final res = await db.query(
      'see_later',
      where: 'imdb_id = ?',
      whereArgs: [imdbId],
    );
    return res.isNotEmpty;
  }

 //get all see later movies for current user
  static Future<List<Map<String, dynamic>>> getSeeLaterMovies() async {
    final userId = UserDao.getCurrentUserId();
    if (userId == null) throw Exception("Please login first");
    final db = await AppDatabase.database;
    return await db.query(
      'see_later',
      where: 'user_id = ?',
      whereArgs: [userId],
    );
  }
}