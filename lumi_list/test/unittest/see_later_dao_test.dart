import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:lumi_list/database/seelater.dart';

void main() {
  group('SeeLaterDao (FakeFirestore)', () {
    late FakeFirebaseFirestore fakeDb;
    const uid = 'uid_test_123';

    CollectionReference<Map<String, dynamic>> laterCol() =>
        fakeDb.collection('users').doc(uid).collection('watch_later');

    setUp(() {
      fakeDb = FakeFirebaseFirestore();
      SeeLaterDao.db = fakeDb;
      SeeLaterDao.uidProvider = () => uid;
    });

    test('insertSeeLater + isSeeLater + deleteSeeLater', () async {
      const imdbId = 'tt2';
      await SeeLaterDao.insertSeeLater(
        imdbId: imdbId,
        title: 'Movie 2',
        poster: 'http://p2',
      );

      expect(await SeeLaterDao.isSeeLater(imdbId), isTrue);

      await SeeLaterDao.deleteSeeLater(imdbId);
      expect(await SeeLaterDao.isSeeLater(imdbId), isFalse);
    });

    test('streamSeeLater orders by updatedAt desc', () async {
      await SeeLaterDao.insertSeeLater(
          imdbId: 'ttOld', title: 'Old', poster: 'p');
      await SeeLaterDao.insertSeeLater(
          imdbId: 'ttNew', title: 'New', poster: 'p');

      await laterCol().doc('ttOld').set({
        'updatedAt': Timestamp.fromMillisecondsSinceEpoch(1000),
      }, SetOptions(merge: true));

      await laterCol().doc('ttNew').set({
        'updatedAt': Timestamp.fromMillisecondsSinceEpoch(2000),
      }, SetOptions(merge: true));

      final list = await SeeLaterDao.streamSeeLater().first;
      expect(list.first['imdb_id'], 'ttNew');
      expect(list.last['imdb_id'], 'ttOld');
    });
  });
}
