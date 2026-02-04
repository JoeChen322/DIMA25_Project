import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:lumi_list/database/favorite.dart';
import 'package:lumi_list/database/seelater.dart';
import 'package:lumi_list/database/personal_rate.dart';

void main() {
  // 初始化 FFI 数据库驱动，这是在电脑上运行测试的关键
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;

  group('数据库 DAO 层整合测试', () {
    const String mockId = 'tt1375666'; // Inception 的 ID
    const String mockTitle = 'Inception';

    // 每个测试运行前，可以确保数据库是干净的
    setUp(() async {
      // 可以在此处添加清理逻辑
    });

    // --- 测试 Favorite 表 ---
    test('验证 FavoriteDao 的增删改查', () async {
      // 1. 初始状态应不在收藏夹
      bool isFav = await FavoriteDao.isFavorite(mockId);
      expect(isFav, isFalse);

      // 2. 插入数据
      await FavoriteDao.insertFavorite(
        imdbId: mockId,
        title: mockTitle,
        poster: 'https://example.com/p.jpg',
      );

      // 3. 验证状态更新
      isFav = await FavoriteDao.isFavorite(mockId);
      expect(isFav, isTrue);

      // 4. 删除数据
      await FavoriteDao.deleteFavorite(mockId);
      isFav = await FavoriteDao.isFavorite(mockId);
      expect(isFav, isFalse);
    });

    // --- 测试 See Later 表 ---
    test('验证 SeeLaterDao 的持久化逻辑', () async {
      // 模拟进入详情页并点击 "Later" 按钮的操作
      await SeeLaterDao.insertSeeLater(
        imdbId: mockId,
        title: mockTitle,
        poster: 'https://example.com/p.jpg',
      );

      final isLater = await SeeLaterDao.isSeeLater(mockId);
      expect(isLater, isTrue);
    });

    // --- 测试评分表 (Personal Ratings) ---
    test('验证评分的插入与更新', () async {
      // 1. 第一次评分
      await PersonalRateDao.insertOrUpdateRate(
        imdbId: mockId,
        title: mockTitle,
        rating: 4,
      );
      int? score = await PersonalRateDao.getRating(mockId);
      expect(score, 4);

      // 2. 更新评分（覆盖测试）
      await PersonalRateDao.insertOrUpdateRate(
        imdbId: mockId,
        title: mockTitle,
        rating: 5,
      );
      score = await PersonalRateDao.getRating(mockId);
      expect(score, 5); // 验证 ConflictAlgorithm.replace 生效
    });
  });
}