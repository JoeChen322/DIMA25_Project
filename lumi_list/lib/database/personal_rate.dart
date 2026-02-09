/*Info of the personal ratings associated with the star button */
import 'package:sqflite/sqflite.dart';
import 'app_database.dart';
import 'user.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class PersonalRateDao {
  // store or update personal rating
  static Future<void> insertOrUpdateRate({
    required String imdbId,
    required String title,
    required int rating, // 1-5 stars
  }) async {
     final userId = UserDao.getCurrentUserId();
     final userEmail = UserDao.getCurrentUserEmail();
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
     // delete from favorites
    FirebaseFirestore.instance
      .collection('users')
      .doc(userEmail)
      .collection('personal_ratings')
      .doc(imdbId)
      .set({
        'imdb_id': imdbId, 'title': title, 'rating': rating,
        'sync_at': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

  }

  // get personal rating
  static Future<int?> getRating(String imdbId) async {
    final userId = UserDao.getCurrentUserId();
    final userEmail = UserDao.getCurrentUserEmail();
  if (userId == null) throw Exception("Please login first");
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
    final userId = UserDao.getCurrentUserId();
    final userEmail = UserDao.getCurrentUserEmail();
  if (userId == null) return;
    final db = await AppDatabase.database;
    await db.delete(
      'personal_ratings',
      where: 'imdb_id = ? AND user_id = ?',
      whereArgs: [imdbId, UserDao.getCurrentUserId()!],
    );
    FirebaseFirestore.instance
      .collection('users')
      .doc(userEmail)
      .collection('personal_ratings')
      .doc(imdbId)
      .delete();
  }

  // read all personal ratings
  static Future<List<Map<String, dynamic>>> getAllRatings() async {
  final userId = UserDao.getCurrentUserId();
  final userEmail = UserDao.getCurrentUserEmail();
  if (userId == null) throw Exception("Please login first");

  final db = await AppDatabase.database;

  
  _pullFromCloud(userId.toString());
  return await db.query(
    'personal_ratings', 
    where: 'user_email = ?', 
    whereArgs: [userEmail], 
    orderBy: 'timestamp DESC'
  );
}
static Future<void> _pullFromCloud(String userId) async {
  final userEmail = UserDao.getCurrentUserEmail();
  try {
    final remoteSnapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(userEmail)
        .collection('personal_ratings')
        .get();

    final db = await AppDatabase.database;
    for (var doc in remoteSnapshot.docs) {
      final data = doc.data();
      await db.insert(
        'personal_ratings',
        {
          'user_id': userId,
          'imdb_id': data['imdb_id'],
          'title': data['title'],
          'rating': data['rating'],
          'timestamp': data['timestamp'],
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
  } catch (e) {
    print("Silent background sync failed: $e");
  }
}
}