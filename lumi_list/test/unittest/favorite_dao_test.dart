import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:lumi_list/database/favorite.dart';

void main() {
  group('FavoriteDao (FakeFirestore)', () {
    late FakeFirebaseFirestore fakeDb;
    const uid = 'uid_test_123';

    CollectionReference<Map<String, dynamic>> favCol() =>
        fakeDb.collection('users').doc(uid).collection('favorites');

    setUp(() {
      fakeDb = FakeFirebaseFirestore();
      FavoriteDao.db = fakeDb;
      FavoriteDao.uidProvider = () => uid;
    });

    test('insertFavorite + isFavorite + deleteFavorite', () async {
      const imdbId = 'tt1';
      await FavoriteDao.insertFavorite(
        imdbId: imdbId,
        title: 'Movie 1',
        poster: 'http://p1',
        genre: 'Action',
        rating: 7,
      );

      expect(await FavoriteDao.isFavorite(imdbId), isTrue);

      await FavoriteDao.deleteFavorite(imdbId);
      expect(await FavoriteDao.isFavorite(imdbId), isFalse);
    });

    test('getMostFrequentGenre ignores null/No Info and splits by comma',
        () async {
      await FavoriteDao.insertFavorite(
        imdbId: 'ttA',
        title: 'A',
        poster: 'http://p',
        genre: 'Sci-Fi, Action',
      );
      await FavoriteDao.insertFavorite(
        imdbId: 'ttB',
        title: 'B',
        poster: 'http://p',
        genre: 'Action',
      );
      await FavoriteDao.insertFavorite(
        imdbId: 'ttC',
        title: 'C',
        poster: 'http://p',
        genre: 'No Info',
      );
      await FavoriteDao.insertFavorite(
        imdbId: 'ttD',
        title: 'D',
        poster: 'http://p',
        genre: null,
      );

      final most = await FavoriteDao.getMostFrequentGenre();
      expect(most, 'Action'); // Action appears twice
    });

    test('streamAllFavorites orders by updatedAt desc', () async {
      // Insert via DAO
      await FavoriteDao.insertFavorite(
        imdbId: 'ttOld',
        title: 'Old',
        poster: 'http://p',
        genre: 'Drama',
      );
      await FavoriteDao.insertFavorite(
        imdbId: 'ttNew',
        title: 'New',
        poster: 'http://p',
        genre: 'Drama',
      );

      // FakeFirestore may not materialize serverTimestamp consistently for ordering,
      // so force deterministic timestamps after insert.
      await favCol().doc('ttOld').set({
        'updatedAt': Timestamp.fromMillisecondsSinceEpoch(1000),
      }, SetOptions(merge: true));

      await favCol().doc('ttNew').set({
        'updatedAt': Timestamp.fromMillisecondsSinceEpoch(2000),
      }, SetOptions(merge: true));

      final list = await FavoriteDao.streamAllFavorites().first;
      expect(list.first['imdb_id'], 'ttNew');
      expect(list.last['imdb_id'], 'ttOld');
    });
  });
}
