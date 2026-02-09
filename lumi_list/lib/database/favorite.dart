import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:lumi_list/services/auth_service.dart';

class FavoriteDao {
  static final _db = FirebaseFirestore.instance;

  static CollectionReference<Map<String, dynamic>> _col() {
    final uid = AuthService.uid;
    if (uid == null) throw Exception("Please login first");
    return _db.collection('users').doc(uid).collection('favorites');
  }

  static Future<void> insertFavorite({
    required String imdbId,
    required String title,
    required String poster,
    int? rating,
    String? genre,
  }) async {
    await _col().doc(imdbId).set({
      'imdb_id': imdbId,
      'title': title,
      'poster': poster,
      'genre': genre,
      'rating': rating,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  static Future<void> deleteFavorite(String imdbId) async {
    await _col().doc(imdbId).delete();
  }

  static Future<bool> isFavorite(String imdbId) async {
    final doc = await _col().doc(imdbId).get();
    return doc.exists;
  }

  static Future<List<Map<String, dynamic>>> getAllFavorites() async {
    final snap = await _col().get();
    return snap.docs.map((d) => d.data()).toList();
  }

  static Stream<List<Map<String, dynamic>>> streamAllFavorites() {
    return _col()
        .orderBy('updatedAt', descending: true)
        .snapshots()
        .map((snap) => snap.docs.map((d) => d.data()).toList());
  }

  static Future<String?> getMostFrequentGenre() async {
    final favorites = await getAllFavorites();
    if (favorites.isEmpty) return null;

    final Map<String, int> counts = {};
    for (final movie in favorites) {
      final genreStr = movie['genre'] as String?;
      if (genreStr == null || genreStr.isEmpty || genreStr == "No Info")
        continue;

      for (final g in genreStr.split(',').map((x) => x.trim())) {
        if (g.isEmpty) continue;
        counts[g] = (counts[g] ?? 0) + 1;
      }
    }

    if (counts.isEmpty) return null;
    return counts.entries.reduce((a, b) => a.value >= b.value ? a : b).key;
  }
}
