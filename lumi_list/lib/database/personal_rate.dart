/*Info of the personal ratings associated with the star button */
import 'package:sqflite/sqflite.dart';
import 'app_database.dart';
import 'user.dart';
class PersonalRateDao {
  // store or update personal rating
  static Future<void> insertOrUpdateRate({
    required String imdbId,
    required String title,
    required int rating, // 1-5 stars
  }) async {
     final userId = UserDao.getCurrentUserId();
    if (userId == null) throw Exception("Please login first");

    final db = await AppDatabase.database;
    await db.insert(

      'personal_ratings', // table name
      {
        'user_id': userId,
        'imdb_id': imdbId,
        'title': title,
        'rating': rating,
        'timestamp': DateTime.now().millisecondsSinceEpoch, // timestamp
      },
      // if the movie already has a rating, replace it
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // get personal rating
  static Future<int?> getRating(String imdbId) async {
    final db = await AppDatabase.database;
    final res = await db.query(
      'personal_ratings',
      where: 'imdb_id = ? AND user_id = ?',
      whereArgs: [imdbId, UserDao.getCurrentUserId()!],
    );
    
    if (res.isNotEmpty) {
      return res.first['rating'] as int;
    }
    return null;
  }

  // delate personal rating
  static Future<void> deleteRating(String imdbId) async {
    final db = await AppDatabase.database;
    await db.delete(
      'personal_ratings',
      where: 'imdb_id = ? AND user_id = ?',
      whereArgs: [imdbId, UserDao.getCurrentUserId()!],
    );
  }

  // read all personal ratings
  static Future<List<Map<String, dynamic>>> getAllRatings() async {
    final userId = UserDao.getCurrentUserId();
    if (userId == null) {
      throw Exception("Please login first");
    }
    else{
      final db = await AppDatabase.database;
      return await db.query('personal_ratings', where: 'user_id = ?', whereArgs: [userId], orderBy: 'timestamp DESC');
    }
    
  }
}