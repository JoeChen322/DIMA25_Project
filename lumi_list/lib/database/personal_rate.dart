import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:lumi_list/services/auth_service.dart';

class PersonalRateDao {
  static final _db = FirebaseFirestore.instance;

  static CollectionReference<Map<String, dynamic>> _col() {
    final uid = AuthService.uid;
    if (uid == null) throw Exception("Please login first");
    return _db.collection('users').doc(uid).collection('personal_ratings');
  }

  static Future<void> insertOrUpdateRate({
    required String imdbId,
    required String title,
    required int rating,
  }) async {
    await _col().doc(imdbId).set({
      'imdb_id': imdbId,
      'title': title,
      'rating': rating,
      'timestamp': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  static Future<int?> getRating(String imdbId) async {
    final doc = await _col().doc(imdbId).get();
    if (!doc.exists) return null;
    return (doc.data()?['rating'] as num?)?.toInt();
  }

  static Future<void> deleteRating(String imdbId) =>
      _col().doc(imdbId).delete();

  static Stream<List<Map<String, dynamic>>> streamAllRatings() {
    return _col()
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snap) => snap.docs.map((d) => d.data()).toList());
  }
}
