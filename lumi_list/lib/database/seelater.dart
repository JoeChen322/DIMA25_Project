import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:lumi_list/services/auth_service.dart';

class SeeLaterDao {
  static FirebaseFirestore db = FirebaseFirestore.instance;
  static String? Function() uidProvider = () => AuthService.uid;

  static CollectionReference<Map<String, dynamic>> _col() {
    final uid = uidProvider();
    if (uid == null) throw Exception("Please login first");
    return db.collection('users').doc(uid).collection('watch_later');
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
