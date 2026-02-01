/*Info of the personal ratings associated with the star button */
import 'package:sqflite/sqflite.dart';
import 'app_database.dart';

class PersonalRateDao {
  // store or update personal rating
  static Future<void> insertOrUpdateRate({
    required String imdbId,
    required String title,
    required int rating, // 1-5 stars
  }) async {
    final db = await AppDatabase.database;
    await db.insert(
      'personal_ratings', // table name
      {
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
      where: 'imdb_id = ?',
      whereArgs: [imdbId],
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
      where: 'imdb_id = ?',
      whereArgs: [imdbId],
    );
  }

  // read all personal ratings
  static Future<List<Map<String, dynamic>>> getAllRatings() async {
    final db = await AppDatabase.database;
    return await db.query('personal_ratings', orderBy: 'timestamp DESC');
  }
}