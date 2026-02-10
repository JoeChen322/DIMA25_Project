import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:lumi_list/database/personal_rate.dart';

void main() {
  group('PersonalRateDao (FakeFirestore)', () {
    late FakeFirebaseFirestore fakeDb;
    const uid = 'uid_test_123';

    CollectionReference<Map<String, dynamic>> rateCol() =>
        fakeDb.collection('users').doc(uid).collection('personal_ratings');

    setUp(() {
      fakeDb = FakeFirebaseFirestore();
      PersonalRateDao.db = fakeDb;
      PersonalRateDao.uidProvider = () => uid;
    });

    test('insertOrUpdateRate + getRating + deleteRating', () async {
      const imdbId = 'tt3';

      await PersonalRateDao.insertOrUpdateRate(
        imdbId: imdbId,
        title: 'Movie 3',
        rating: 8,
      );

      final r = await PersonalRateDao.getRating(imdbId);
      expect(r, 8);

      await PersonalRateDao.deleteRating(imdbId);
      expect(await PersonalRateDao.getRating(imdbId), isNull);
    });

    test('streamAllRatings orders by timestamp desc', () async {
      await PersonalRateDao.insertOrUpdateRate(
          imdbId: 'ttOld', title: 'Old', rating: 1);
      await PersonalRateDao.insertOrUpdateRate(
          imdbId: 'ttNew', title: 'New', rating: 2);

      // Force deterministic ordering
      await rateCol().doc('ttOld').set({
        'timestamp': Timestamp.fromMillisecondsSinceEpoch(1000),
      }, SetOptions(merge: true));

      await rateCol().doc('ttNew').set({
        'timestamp': Timestamp.fromMillisecondsSinceEpoch(2000),
      }, SetOptions(merge: true));

      final list = await PersonalRateDao.streamAllRatings().first;
      expect(list.first['imdb_id'], 'ttNew');
      expect(list.last['imdb_id'], 'ttOld');
    });
  });
}
