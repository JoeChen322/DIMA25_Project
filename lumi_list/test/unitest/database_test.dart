import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:lumi_list/database/favorite.dart';
import 'package:lumi_list/database/seelater.dart';
import 'package:lumi_list/database/personal_rate.dart';
import 'package:lumi_list/database/app_database.dart';

void main() {
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;

  group('Database DAO unitest', () {
    const String mockId = 'tt1375668'; // Inception 的 ID
    const String mockTitle = 'Inception';

    setUp(() async {
      final dbPath = await databaseFactory.getDatabasesPath();
      final path = '$dbPath/lumilist.db';
      if (await databaseFactory.databaseExists(path)) {
        await databaseFactory.deleteDatabase(path);
      }
  await AppDatabase.database;
    });

    // ---  Favorite ---
    test('CRUD of Favorite DAO', () async {
      // 1.default is not favorite
      bool isFav = await FavoriteDao.isFavorite(mockId);
      expect(isFav, isFalse);

      // 2. insert favorite
      await FavoriteDao.insertFavorite(
        imdbId: mockId,
        title: mockTitle,
        poster: 'https://example.com/p.jpg',
      );

      // 3. update favorite status
      isFav = await FavoriteDao.isFavorite(mockId);
      expect(isFav, isTrue);

      // 4. delete favorite
      await FavoriteDao.deleteFavorite(mockId);
      isFav = await FavoriteDao.isFavorite(mockId);
      expect(isFav, isFalse);
    });

    test('CRUD of SeeLater Dao', () async {
      await SeeLaterDao.insertSeeLater(
        imdbId: mockId,
        title: mockTitle,
        poster: 'https://example.com/p.jpg',
      );

      final isLater = await SeeLaterDao.isSeeLater(mockId);
      expect(isLater, isTrue);
    });

    // --- Personal Ratings---
    test('CRUD of PersonalRate Dao', () async {
      // 1. first insert
      await PersonalRateDao.insertOrUpdateRate(
        imdbId: mockId,
        title: mockTitle,
        rating: 4,
      );
      int? score = await PersonalRateDao.getRating(mockId);
      expect(score, 4);

      // 2. update rating
      await PersonalRateDao.insertOrUpdateRate(
        imdbId: mockId,
        title: mockTitle,
        rating: 5,
      );
      score = await PersonalRateDao.getRating(mockId);
      expect(score, 5); 
    });
  });
}