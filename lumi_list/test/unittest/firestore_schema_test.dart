import 'package:flutter_test/flutter_test.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';

void main() {
  group('Firestore schema tests (fake)', () {
    test('users/{uid} profile + subcollections CRUD', () async {
      final db = FakeFirebaseFirestore();

      const uid = 'uid_test_123';
      const imdbId = 'tt1375668';

      // users/{uid}
      await db.collection('users').doc(uid).set({
        'email': 'test@example.com',
        'username': 'TestUser',
        'bio': 'NA',
        'phone': 'NA',
        'avatarUrl': 'NA',
      });

      final profile = await db.collection('users').doc(uid).get();
      expect(profile.exists, isTrue);
      expect(profile.data()!['username'], 'TestUser');

      // users/{uid}/favorites/{imdbId}
      final favRef =
          db.collection('users').doc(uid).collection('favorites').doc(imdbId);

      await favRef.set({
        'imdb_id': imdbId,
        'title': 'Inception',
        'poster': 'https://example.com/p.jpg',
        'genre': 'Sci-Fi',
        'rating': 9.0,
      });

      final favDoc = await favRef.get();
      expect(favDoc.exists, isTrue);
      expect(favDoc.data()!['title'], 'Inception');

      // update favorite
      await favRef.update({'title': 'Inception (Updated)'});
      final favUpdated = await favRef.get();
      expect(favUpdated.data()!['title'], 'Inception (Updated)');

      // delete favorite
      await favRef.delete();
      final favDeleted = await favRef.get();
      expect(favDeleted.exists, isFalse);

      // users/{uid}/watch_later/{imdbId}
      final laterRef =
          db.collection('users').doc(uid).collection('watch_later').doc(imdbId);

      await laterRef.set({
        'imdb_id': imdbId,
        'title': 'Inception',
        'poster': 'https://example.com/p.jpg',
      });

      final laterDoc = await laterRef.get();
      expect(laterDoc.exists, isTrue);

      // users/{uid}/personal_ratings/{imdbId}
      final rateRef = db
          .collection('users')
          .doc(uid)
          .collection('personal_ratings')
          .doc(imdbId);

      await rateRef.set({
        'imdb_id': imdbId,
        'title': 'Inception',
        'rating': 5,
        'timestamp': 123456,
      });

      final rateDoc = await rateRef.get();
      expect(rateDoc.exists, isTrue);
      expect(rateDoc.data()!['rating'], 5);
    });
  });
}
