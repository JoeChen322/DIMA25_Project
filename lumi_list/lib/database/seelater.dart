import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:lumi_list/services/auth_service.dart';

class SeeLaterDao {
  static final _db = FirebaseFirestore.instance;

  static CollectionReference<Map<String, dynamic>> _col() {
    final uid = AuthService.uid;
    if (uid == null) throw Exception("Please login first");
    return _db.collection('users').doc(uid).collection('watch_later');
  }

  static Future<void> insertSeeLater({
    required String imdbId,
    required String title,
    required String poster,
  }) async {
    await _col().doc(imdbId).set({
      'imdb_id': imdbId,
      'title': title,
      'poster': poster,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  static Future<void> deleteSeeLater(String imdbId) =>
      _col().doc(imdbId).delete();

  static Future<bool> isSeeLater(String imdbId) async {
    final doc = await _col().doc(imdbId).get();
    return doc.exists;
  }

  static Stream<List<Map<String, dynamic>>> streamSeeLater() {
    return _col()
        .orderBy('updatedAt', descending: true)
        .snapshots()
        .map((snap) => snap.docs.map((d) => d.data()).toList());
  }
}
