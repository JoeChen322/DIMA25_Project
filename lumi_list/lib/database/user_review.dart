import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:lumi_list/services/auth_service.dart';

class UserReviewDao {
  // allow tests to override (same style as FavoriteDao)
  static FirebaseFirestore db = FirebaseFirestore.instance;
  static String? Function() uidProvider = () => AuthService.uid;

  static CollectionReference<Map<String, dynamic>> _col() {
    final uid = uidProvider();
    if (uid == null) throw Exception("Please login first");
    return db.collection('users').doc(uid).collection('user_reviews');
  }

  /// Upsert review for ONE movie (docId = imdbId).
  /// createdAt is only set on first creation; updatedAt changes every time.
  static Future<void> upsertReview({
    required String imdbId,
    required String title,
    required String content,
    int rating = 0, // 0..5
  }) async {
    final ref = _col().doc(imdbId);

    await db.runTransaction((tx) async {
      final snap = await tx.get(ref);
      if (!snap.exists) {
        tx.set(
            ref,
            {
              'imdb_id': imdbId,
              'title': title,
              'content': content,
              'rating': rating,
              'createdAt': FieldValue.serverTimestamp(),
              'updatedAt': FieldValue.serverTimestamp(),
            },
            SetOptions(merge: true));
      } else {
        tx.set(
            ref,
            {
              'imdb_id': imdbId,
              'title': title,
              'content': content,
              'rating': rating,
              'updatedAt': FieldValue.serverTimestamp(),
            },
            SetOptions(merge: true));
      }
    });
  }

  static Future<Map<String, dynamic>?> getMyReview(String imdbId) async {
    final snap = await _col().doc(imdbId).get();
    return snap.data();
  }

  static Stream<Map<String, dynamic>?> streamMyReview(String imdbId) {
    return _col().doc(imdbId).snapshots().map((d) => d.data());
  }

  static Future<void> deleteMyReview(String imdbId) async {
    await _col().doc(imdbId).delete();
  }
}
