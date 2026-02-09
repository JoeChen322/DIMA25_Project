import 'package:sqflite/sqflite.dart';
import 'app_database.dart';
import 'user.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
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
  final userEmail = UserDao.getCurrentUserEmail();
  if (userId == null) throw Exception("Please login first");

  // delete from local database
  final db = await AppDatabase.database;
  await db.delete(
    'see_later',
    where: 'imdb_id = ? AND user_id = ?',
    whereArgs: [imdbId, userId],
  );

  // delete from cloud
  try {
    await FirebaseFirestore.instance
        .collection('users')
        .doc(userEmail)
        .collection('watch_later')
        .doc(imdbId)
        .delete();
  } catch (e) {
    print("Cloud delete failed (possibly offline): $e");
    
  }
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
 
 // sync with firebase 
  static Future<void> syncWithFirebase() async {
  final userId = UserDao.getCurrentUserId();
  final userEmail = UserDao.getCurrentUserEmail();
  if (userId == null) throw Exception("Please login first");

  final db = await AppDatabase.database;
  final firestoreRef = FirebaseFirestore.instance
      .collection('users')
      .doc(userEmail)
      .collection('watch_later');

  // --- upload local to cloud (Merge) ---
  final localData = await db.query('see_later', where: 'user_id = ?', whereArgs: [userId]);
  for (var movie in localData) {
    await firestoreRef.doc(movie['imdb_id'].toString()).set({
      'imdb_id': movie['imdb_id'],
      'title': movie['title'],
      'poster': movie['poster'],
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  // --- download and merge ---
  final remoteSnapshot = await firestoreRef.get();
  for (var doc in remoteSnapshot.docs) {
    final data = doc.data();
    await db.insert(
      'see_later',
      {
        'user_id': userId,
        'imdb_id': data['imdb_id'],
        'title': data['title'],
        'poster': data['poster'],
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }
}
}